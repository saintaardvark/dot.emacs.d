;;; -*- lexical-binding: t -*-
;;; x-hugh-functions --- My functions

;;; Commentary:
;;; Might as well put them some place...

;;; Code:

(defun x-hugh-edit-completing-read (arg dir prefix)
  "Edit files matching a particular pattern.

If ARG is given, open in other window.
If DIR is given, propose files from that directory.
If PREFIX is given, open files matching that prefix."
  (interactive "P")
  (let ((path (file-truename dir)))
    (if (eq arg 'nil)
        (find-file (completing-read "File: "
                                    (directory-files path t prefix)
                                    nil nil (concat path prefix)))
      (find-file-other-window (completing-read "File: "
                                               (directory-files path t prefix)
                                               nil nil (concat path prefix))))))

(defun x-hugh-reload-dot-emacs ()
  "Reload .emacs."
  (interactive)
  (load-file "~/.emacs"))

(defun x-hugh-edit-dot-emacs (arg)
  "Better way to edit bashrc files, now that I've split them up.

If ARG is provided, open in other window."
  (interactive "P")
  (x-hugh-edit-completing-read arg "~/.emacs.d/lisp/" "x-hugh-"))

;;; It's clumsy, I'm sure, but it works!
(defun x-hugh-wordcount ()
  "A Small but Useful(tm) function to count the words in the buffer.

It works, but it's also a learning exercise."
  (interactive)
  (let ((beg (point-min))
	(end (point-max)))
    ;; This works, but it would be better to use a temporary buffer here.
    (shell-command-on-region beg end "wc -w")
    (message "%s words"
	     (with-current-buffer "*Shell Command Output*"
	       (let ((beg (point-min))
		     (end (- (point-max) 1)))
		 (buffer-substring beg end))))))

(defun mrc-dired-do-command (command)
  "Run COMMAND on marked files.  Any files not already open will be opened.
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
  "Run shred on marked files.  This will erase them."
  (interactive)
  (yes-or-no-p "Do you REALLY want to shred these files forever? ")
  (save-window-excursion
    (dired-do-async-shell-command "shred -zu" nil (dired-get-marked-files))))

(add-hook 'dired-mode-hook '(lambda () (local-set-key "z" 'x-hugh-dired-do-shred)))

;;; Random things I've stolen from other people; remove if they end up
;;; not being used.

(defun totd ()
  "Display tip o' the day."
  (interactive)
  (with-output-to-temp-buffer "*Tip of the day*"
    (let* ((commands (cl-loop for s being the symbols
                              when (commandp s) collect s))
           (command (nth (random (length commands)) commands)))
      (princ
       (concat "Your tip for the day is:\n"
               "========================\n\n"
               (describe-function command)
               "\n\nInvoke with:\n\n"
               (with-temp-buffer
                 (where-is command t)
                 (buffer-string))
	       "\n\nVersion: "
	       (emacs-version)
	       "\n\n🌈✨🚀  WELCOME TO EMACS – THE MOTHER OF ALL EDITORS  🚀✨🌈
  🦄🌟  EXTEND, TWEAK, SCRIPT, REPEAT — UNICORN POWER!  🌟🦄
  🐉⚡  UNLEASH THE FURY OF LISP & DOUBLE YOUR PRODUCTIVITY  ⚡🐉")))))

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
This requires the external program \"diff\" to be in symbol `exec-path'.
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

(defun x-hugh-boxquote-yank-and-indent ()
  "My attempt to combine boxquote-yank and indent.

The car/cdr bits are from the docstring for boxquote-points.
It's a bit silly to run it twice, but it was simple."
  (interactive)
  (save-excursion
    (if (region-active-p)
	(boxquote-region (region-beginning) (region-end))
      (boxquote-yank))
    (forward-line)
    ;; boxquote-points gives you the first point of the boxquote
    ;; formatting, and the last line of the stuff being quoted.  We
    ;; have to add six to get the *end* of the boxquote formatting.
    (indent-region (car (boxquote-points)) (+ 6 (cdr (boxquote-points))))))

(defun x-hugh-unixify-buffer ()
  "Convert from whatever (ie, DOS) to unix-undecided.

I can never remember how to do this."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix)
  (save-buffer))

;; From http://stackoverflow.com/questions/23588549/emacs-copy-region-line-and-comment-at-the-same-time

(defun x-hugh-copy-and-comment-region (beg end &optional arg)
  "Duplicate the region marked by BEG and END and comment-out the copied text.

If ARG provided, this will be provided as the prefix to the call
to `comment-region'; see that function's docstring for what that
will do."
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

;; Awesome.  From https://stackoverflow.com/questions/234963/re-open-scratch-buffer-in-emacs --
;; bury *scratch* buffer instead of kill it
(defadvice kill-buffer (around kill-buffer-around-advice activate)
  "Don't kill *scratch* buffer.  Just don't."
  (let ((buffer-to-kill (ad-get-arg 0)))
    (if (equal buffer-to-kill "*scratch*")
        (bury-buffer)
      ad-do-it)))

(defun x-hugh-ssh-mode-hook ()
  "Hook for ssh-mode."
  (ssh-directory-tracking-mode t))

;;; http://apple.stackexchange.com/questions/85222/configure-emacs-to-cut-and-copy-text-to-mac-os-x-clipboard/127082#127082
(defun pbpaste ()
  "Emacs wrapper for pbpaste."
  (interactive)
  (call-process-region (point) (if mark-active (mark) (point)) "pbpaste" t t))

;; From http://stackoverflow.com/questions/5925485/emacs-lisp-macro-stepper.  WOW.
;; FIXME: Move this to x-hugh-elisp.
;; FIXME: Have this be a smaller buffer - just big enough to hold the expansion
;; FIXME: Have "q" in this buffer kill it
(defun macroexpand-point (sexp)
  "Expand SEXP at point.  Wonderful for debugging."
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

;; http://emacs.stackexchange.com/a/10080
;; FIXME: Have this kill the buffer after it's done: https://stackoverflow.com/questions/34857843/kill-emacss-async-shell-command-buffer-if-command-is-terminated
(defun crontab-e ()
  "Edit crontab within Emacs."
  (interactive)
  (with-editor-async-shell-command "crontab -e"))

(defun x-hugh-generate-password ()
  "Generate a new password and insert at point."
  (interactive)
  (insert (replace-regexp-in-string "\n\\'" ""
                                    (shell-command-to-string "pwgen 12 1"))))

(defun x-hugh-surround-region-plus-newlines (beg end)
  "Wrap a region in BEG and END characters, plus newlines on either side .

If region looks like this:

REGION

and this is called:

\(x-hugh-surround-region-plus-newlines \"```\" \"```\")

then the result will be:

```
REGION
```"
  (save-excursion
    (let ((pos1 (region-beginning))
          (pos2 (region-end)))
      (goto-char pos2)
      (insert (format "\n%s" end))
      (insert "\n")
      (goto-char pos1)
      (insert beg)
      (insert "\n"))))

(defun x-hugh-korect-speling (korecshun)
  "Add abbrev to turn mispeld \"word-at-point\" into KORECSHUN."
  (interactive "sKorekshun: ")
  (let ((mispeld (downcase (word-at-point))))
    (define-abbrev global-abbrev-table korecshun mispeld)
    (write-abbrev-file abbrev-file-name)))

;; Source: https://www.emacswiki.org/emacs/UnfillRegion
(defun unfill-region (beg end)
  "Unfill region from BEG to END, joining text paragraphs into single logical line.

This is useful, e.g., for use with `visual-line-mode'."
  (interactive "*r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))

;; Potential replacement for which_ticket-no_fzf.sh
(defun extract-dns-entries ()
  "Extract the last 500 lines from journal.org containing 'DNS-' and strip the prefix.
Return a list of strings."
  (with-temp-buffer
    (insert-file-contents "~/orgmode/journal.org")
    (goto-char (point-max))
    (forward-line -500)
    (let ((lines (buffer-substring (point) (point-max))))
      (cl-remove-if-not
       (lambda (line)
         (and (string-match "DNS-" line)
              (replace-regexp-in-string ".*DNS-" "DNS-" line)))
       (split-string lines "\n")))))

(defun x-hugh-pick-a-ticket ()
  "Pick a ticket that's recorded in the journal; handy for branches, repeated logs, etc.

This depends on ~/bin/which_ticket-no_fzf.sh, which should be replaced by some simple elisp.
"
  (interactive)
  (let ((options (run-shell-script-and-capture-output-as-list (expand-file-name "~/bin/which_ticket-no_fzf.sh"))))
    (helm :sources (helm-build-sync-source "Select an Option"
                     :candidates options
                     :action (lambda (selected)
                               (setq selected (if (stringp selected) selected nil))
                               (if selected
                                   (progn
                                     (message "You selected: %s" selected)
                                     selected)
                                 (error "No selection made.")))
                     :volatile t))))

(provide 'x-hugh-functions)
;;; x-hugh-functions.el ends here
