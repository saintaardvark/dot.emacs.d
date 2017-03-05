;;; x-hugh-functions --- My functions

;;; Commentary:
;;; Might as well put them some place...

;;; Code:

(defun x-hugh-reload-dot-emacs ()
  "Reload .emacs."
  (interactive)
  (load-file "~/.emacs"))

;; FIXME: Look at initial-input arg for completing-read in order to
;; populate the initial file to x-hugh-something.
(defun x-hugh-edit-dot-emacs (arg)
  "Edit .emacs.d/x-hugh-* files.

If ARG is given, open in other window."
  (interactive "P")
  (let ((path (file-truename "~/.emacs.d/")))
    (if (eq arg 'nil)
        (find-file (completing-read "File: "
                                    (directory-files path t "x-hugh-")
                                    nil nil (concat path "x-hugh-")))
      (find-file-other-window (completing-read "File: "
                                               (directory-files path t "x-hugh-")
                                               nil nil (concat path "x-hugh-"))))))

(defun x-hugh-company-coming ()
  "Clean up email."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "Saint Aardvark the Carpeted" nil t)
      (replace-match "Hugh Brown" nil nil))
    (goto-char (point-min))
    (while (re-search-forward "disturbed my sleep to write" nil t)
      (replace-match "wrote" nil nil))
    (goto-char (point-min))
    (flush-lines "Because the plural of Anecdote is Myth" nil t)))

(defun x-hugh-zap (arg char)
  "Wrapper around zap-to-char so does *not* including character."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (read-char "Zap to char: " t)))
  (zap-to-char arg char)
  (insert-char char)
  (backward-char))

(defun x-hugh-delete-to-sig ()
  "Delete from point to signature.

Rewritten as defun."
  (interactive)
  (let ((beg (point)))
    (save-excursion
      (post-goto-signature)
      (kill-region beg (point)))))

(defun x-hugh-insert-date ()
  (interactive)
  (insert (format-time-string "%b %d, %Y")))

;;; It's clumsy, I'm sure, but it works!
(defun x-hugh-wordcount ()
  "A Small but Useful(tm) function to count the words in the buffer.

It works, but it's also a learning exercise."
  (interactive)
  ;; (save-excursion
  ;;   ((mark-whole-buffer)
  ;;    (shell-command-on-region "wc -w"))))
  (let ((beg (point-min))
	(end (point-max)))
    ;; This just prints the exit code; not what I weant
    ;;  (message "%d words" (shell-command-on-region beg end "wc -w"))
    ;;
    ;; This puts the output into *Shell Command Output*, also not what I want
    ;;  (shell-command-on-region beg end "wc -w"))
    ;;
    ;; This works, but it would be better to use a temporary buffer here.
    (shell-command-on-region beg end "wc -w")
    (message "%s words"
	     (with-current-buffer "*Shell Command Output*"
	       (let ((beg (point-min))
		     (end (- (point-max) 1)))
		 (buffer-substring beg end))))))

;; FIXME: Set password file as var somewhere.
(defun x-hugh-open-password-file ()
  (interactive)
  (find-file "~/passwords.gpg"))

(defun x-hugh-open-password-file-maybe-matching-string (&optional arg)
  "Open the password file. If arg, only list lines matching string."
  (interactive "p")
  (save-excursion
    (find-file "~/passwords.gpg")
    (when (arg)
	(progn
	  (list-matching-lines
	   (read-from-minibuffer "String to look for (case-insensitive): "))
	  (kill-buffer (get-file-buffer "~/passwords.gpg"))))))

(defun x-hugh-figl (regex)
  "A Small but Useful(tm) shortcut for find-grep-dired, like my figl alias."
  (interactive "sRegex: ")
  (find-grep-dired "." regex))

(defun mrc-dired-do-command (command)
  "Run COMMAND on marked files. Any files not already open will be opened.
After this command has been run, any buffers it's modified will remain
open and unsaved.
From
http://superuser.com/questions/176627/in-emacs-dired-how-can-i-run-a-command-on-multiple-marked-files"
  (interactive "CRun on marked files M-x ")
  (save-window-excursion
    (mapc (lambda (filename)
            (find-file filename)
            (call-interactively command))
          (dired-get-marked-files))))

(defun x-hugh-dired-do-shred ()
  "Run shred on marked files. This will erase them."
  (interactive)
  (yes-or-no-p "Do you REALLY want to shred these files forever? ")
  (save-window-excursion
    (dired-do-async-shell-command "shred -zu" nil (dired-get-marked-files))))

(add-hook 'dired-mode-hook '(lambda () (local-set-key "z" 'x-hugh-dired-do-shred)))

;;; Random things I've stolen from other people; remove if they end up
;;; not being used.

(defun totd ()
  (interactive)
  (with-output-to-temp-buffer "*Tip of the day*"
    (let* ((commands (loop for s being the symbols
                           when (commandp s) collect s))
           (command (nth (random (length commands)) commands)))
      (princ
       (concat "Your tip for the day is:\n"
               "========================\n\n"
               (describe-function command)
               "\n\nInvoke with:\n\n"
               (with-temp-buffer
                 (where-is command t)
                 (buffer-string)))))))

;;
;; A simple utility function.
;;
;; Steve Kemp
;;
(defun replace-region-command-output()
  "Replace the current region with the output of running a command upon it."
  (interactive)
  (let ((command (read-string "Command to execute: ")))
    (if (> (length command) 1)
        (shell-command-on-region (region-beginning) (region-end) command t t)
      (message "No command.  Ignoring"))))

;;; Stolen shamelessly from http://hg.gomaa.us/dotfiles/file/88f948716919/.emacs.d/ag-functions.el
;;; His whole damn way of organizing dotfiles is worth looking at...

(defun diff-buffer-with-associated-file ()
  "View the differences between BUFFER and its associated file.
This requires the external program \"diff\" to be in your `exec-path'.
Returns nil if no differences found, 't otherwise."
  (interactive)
  (let ((buf-filename buffer-file-name)
        (buffer (current-buffer)))
    (unless buf-filename
      (error "Buffer %s has no associated file" buffer))
    (let ((diff-buf (get-buffer-create
                     (concat "*Assoc file diff: "
                             (buffer-name)
                             "*"))))
      (with-current-buffer diff-buf
        (setq buffer-read-only nil)
        (erase-buffer))
      (let ((tempfile (make-temp-file "buffer-to-file-diff-")))
        (unwind-protect
            (progn
              (with-current-buffer buffer
                (write-region (point-min) (point-max) tempfile nil 'nomessage))
              (if (zerop
                   (apply #'call-process "diff" nil diff-buf nil
                          (append
                           (when (and (boundp 'ediff-custom-diff-options)
                                      (stringp ediff-custom-diff-options))
                             (list ediff-custom-diff-options))
                           (list buf-filename tempfile))))
                  (progn
                    (message "No differences found")
                    nil)
                (progn
                  (with-current-buffer diff-buf
                    (goto-char (point-min))
                    (if (fboundp 'diff-mode)
                        (diff-mode)
                      (fundamental-mode)))
                  (display-buffer diff-buf)
                  t)))
          (when (file-exists-p tempfile)
            (delete-file tempfile)))))))

; Use Perl's Text::Autoformat module; select the text first.

(defun doom-run-text-autoformat-on-region (start end)
  "Format the region using Text::Autoformat."
  (interactive "r")
  (let ((command
	 (format
	  "perl -MText::Autoformat -e'autoformat {right=> %d, all=>1}'"
	  fill-column)) )
    (shell-command-on-region start end command nil t "*error*")
    ))
; I never use this.
; (global-set-key "\C-cf" 'doom-run-text-autoformat-on-region)

(defun x-hugh-boxquote-yank-and-indent ()
  "My attempt to combine boxquote-yank and indent.
The car/cdr bits are from the docstring for boxquote-points.  It's a bit silly to run it twice, but it was simple."
  (interactive)
  (save-excursion
    (boxquote-yank)
    (next-line)
    (indent-region (car (boxquote-points)) (cdr (boxquote-points)))))

(defun x-hugh-unixify-buffer ()
  "Convert from whatever (ie, DOS) to unix-undecided.

I can never remember how to do this."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix)
  (save-buffer))

(defun x-hugh-die-outlook-die ()
  "Decode HTML mail when replying.  Not quite perfect, but close."
  (interactive)
  (save-excursion
    (post-goto-body)
    (search-forward-regexp "^>")
    (let ((beg (point)))
      (goto-char (point-max))
      (search-backward-regexp ">")
      (end-of-line)
      (shell-command-on-region beg (point) "/usr/bin/w3m -T text/html" t t)
      (flush-lines (rx bol ">" (zero-or-more blank) eol))
      (flush-lines (rx bol (zero-or-more blank) eol))
      (post-goto-signature)
      (post-quote-region beg (point)))))

;; From http://stackoverflow.com/questions/23588549/emacs-copy-region-line-and-comment-at-the-same-time

(defun x-hugh-copy-and-comment-region (beg end &optional arg)
  "Duplicate the region and comment-out the copied text.
See `comment-region' for behavior of a prefix arg."
  (interactive "r\nP")
  (copy-region-as-kill beg end)
  (goto-char end)
  (yank)
  (comment-region beg end arg)
  (forward-line))

;; not yet working
(defun x-hugh-copy-and-comment-line ()
  "Comment current line, and insert uncommented copy below.

FIXME: Need to figure out how to put point at right column."
  (interactive)
  (save-excursion
    (let ((beg (line-beginning-position))
          (end (line-end-position)))
      (kill-ring-save beg end)
      (comment-region beg end)
      (move-beginning-of-line 2)
      (yank)))
  (forward-line))

(defun x-hugh-copy-line-to-next-line ()
  "Comment current line to next line."
  (interactive)
  (save-excursion
    (let ((beg (line-beginning-position))
          (end (line-end-position)))
      (kill-ring-save beg end)
      (move-beginning-of-line 2)
      (yank)))
  (forward-line))

;; stoleon from http://emacswiki.org/emacs/TransposeWindows
(defun x-hugh-transpose-windows (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

;; Awesome.  From https://stackoverflow.com/questions/234963/re-open-scratch-buffer-in-emacs --
;; bury *scratch* buffer instead of kill it

(defadvice kill-buffer (around kill-buffer-around-advice activate)
  (let ((buffer-to-kill (ad-get-arg 0)))
    (if (equal buffer-to-kill "*scratch*")
        (bury-buffer)
      ad-do-it)))

(defun x-hugh-ssh-mode-hook ()
  "Hook for ssh-mode."
  (ssh-directory-tracking-mode t))

(defun x-hugh-toggle-nag-about-keys ()
  "Toggle nagging about key navigation."
  (interactive)
  (if (not (boundp 'x-hugh-nag-about-keys-flag))
      ;; Our first time through.
      (setq x-hugh-nag-about-keys-flag 0))
  (if (eq x-hugh-nag-about-keys-flag 0)
      (progn
	(message "I haven't been nagging. That's about to change!")
	(setq x-hugh-nag-about-keys-flag 1)
	(global-set-key "\C-n" 'x-hugh-nag-about-keys)
	(global-set-key "\C-p" 'x-hugh-nag-about-keys)
	(global-set-key "\C-f" 'x-hugh-nag-about-keys)
	(global-set-key "\C-b" 'x-hugh-nag-about-keys)
	(global-set-key "\C-xo" 'x-hugh-nag-about-keys))
    (message "I will totally stop nagging now.")
    (setq x-hugh-nag-about-keys-flag 0)
    (global-set-key "\C-n" 'next-line)
    (global-set-key "\C-p" 'previous-line)
    (global-set-key "\C-f" 'forward-char)
    (global-set-key "\C-b" 'backward-char)
    (global-set-key "\C-xo" 'other-window)))

(defun x-hugh-nag-about-keys ()
  "Nag about keys."
  (interactive)
  (sleep-for 0 (% (random) 2000))
  (message "Wrong!"))

;;; http://apple.stackexchange.com/questions/85222/configure-emacs-to-cut-and-copy-text-to-mac-os-x-clipboard/127082#127082
(defun pbpaste ()
  (interactive)
  (call-process-region (point) (if mark-active (mark) (point)) "pbpaste" t t))

;; From http://stackoverflow.com/questions/5925485/emacs-lisp-macro-stepper.  WOW.
(defun macroexpand-point (sexp)
  (interactive (list (sexp-at-point)))
  (with-output-to-temp-buffer "*el-macroexpansion*"
    (pp (macroexpand sexp)))
  (with-current-buffer "*el-macroexpansion*" (emacs-lisp-mode)))

;; Stolen from http://emacsredux.com/blog/2013/03/28/indent-defun/
(defun indent-defun ()
  "Indent the current defun."
  (interactive)
  (save-excursion
    (mark-defun)
    (indent-region (region-beginning) (region-end))))
;; Stolen from http://emacsredux.com/blog/2013/03/28/indent-defun/

(defun x-hugh-indent-buffer ()
  "Indent the whole buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

;; Let's see if there's a way to get Emacs to save files with a remote signal.
;; Use case: call from TK before running, so we don't get "Can't find these files" error.
;; See help for save-some-buffers.
;; emacsclient -e '(save-buffers-kill-emacs t)'

(defun x-hugh-chef-node-runner ()
  "Change chef run to one where attrs can be specified."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward "let(:chef_run)")
    (let ((beg point))
      )
    (goto-char (beginning-of-line))))

;; FIXME: Should be using indirect buffer here (is that the right term?
(defun x-hugh-add-to-venus (url title)
  "Add a URL to planet.ini."
  (interactive "sURL: \nsTitle: ")
  (find-file "/home/aardvark/venus/planet.ini")
  (goto-char (point-max))
  (insert (format "\n[%s]\nname = %s\n" url title))
  (save-buffer)
  (x-hugh-git-commit-and-push-without-mercy)
  (kill-buffer))

;; http://emacs.stackexchange.com/a/10080
(defun crontab-e ()
    (interactive)
    (with-editor-async-shell-command "crontab -e"))

(provide 'x-hugh-functions)
;;; x-hugh-functions ends here
