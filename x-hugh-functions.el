;; My random functions.

(defun x-hugh-reload-dot-emacs ()
  (interactive)
  (load-file "~/.emacs"))
(defun x-hugh-edit-dot-emacs ()
  (interactive)
  (find-file "~/.emacs"))

(defun x-hugh-delete-to-sig ()
  "Delete from point to signature.

Rewritten as defun."
  (interactive)
    (let ((beg (point)))
      (save-excursion
	(post-goto-signature)
	(kill-region beg (point)))))

(defun x-hugh-tag-quote-dwim (tag)
  "DWIM to insert/surround thing-at-point/region with <tag> pair.

Needs tag as argument. Meant to be called from interactive defuns
with the required tag.  Rewritten as defun using Xah Lee's
idiom for working on region or current word."
  (let ((pos1 'nil)
	(pos2 'nil)
	(bds 'nil)
	(taglength (+ 1 (length tag))))
    (if (region-active-p)
	(setq pos1 (region-beginning) pos2 (region-end))
      (progn
	(setq bds (bounds-of-thing-at-point 'symbol))
	(setq pos1 (car bds) pos2 (cdr bds))
	(if (eq bds nil)
	    (setq pos1 (point) pos2 (point)))))
    ;; now, pos1 and pos2 are the starting and ending positions of the
    ;; current word, or current text selection if exist.
    (goto-char (- pos1 1))
    (insert-string (format "\n%s" tag))
    ; go to pos2 + 1 char past + 12 chars (length of "\n<verbatim> string)
    (goto-char (+ pos2 taglength))
    (insert-string (format "\n%s\n" tag))
    (if (eq pos1 pos2)
	(goto-char (- (point) (+ 1 taglength))))))

(defun x-hugh-wiki-verbatim-quote ()
  "Quote region/thing-at-point with verbatim tags, or just insert a pair."
  (interactive)
  (x-hugh-tag-quote-dwim "<verbatim>"))

(defun x-hugh-wiki-blockquote-quote ()
  "Quote region/thing-at-point with blockquote tags, or just insert a pair."
  (interactive)
  (x-hugh-tag-quote-dwim "<blockquote>"))


(defun x-hugh-email-rt (&optional arg ticket)
  "A Small but Useful(tm) function to email RT about a particular ticket. Universal argument to make it Bcc."
  (interactive "P\nnTicket: ")
  (save-excursion
    (goto-char (point-min))
    (if arg
	(search-forward "Bcc:")
      (search-forward "To:"))
    (insert-string " rtc")
    (search-forward "Subject:")
    (insert-string (format " [rt.chibi.ubc.ca #%d] " ticket))))

(defun x-hugh-email-rt-dwim ()
  "A Small but Useful(tm) function to email RT about a particular ticket.
  Will do its best to figure out the ticket number on its own, and prompt if needed; and will send a Bcc: if it looks like there's already a To: address."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward "To:")
    (if (search-forward "@" (line-end-position) t)
	(progn
	  (search-forward "Bcc:")
	  (insert-string " rtc"))
      (insert-string " rtc"))
    (search-forward "Subject:")
    (if (search-forward "[rt.chibi.ubc.ca #" (line-end-position) t)
	()
      (insert-string (format " [rt.chibi.ubc.ca #%s] " (read-string "Ticket: "))))))

; Not ideal, but a good start.
; TODO:
;	Insert appropriate mode header.
;	Account for shebang.
;	Don't duplicate already-existing headers.
(defun x-hugh-insert-headers ()
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (let
	((beg (point)))
      (insert-string "-*-shell-script-*-")
      (forward-line 1) (comment-region beg (point)))
    (vc-insert-headers)))

(fset 'x-hugh-paragraph-ptag-enclose
   "<p>\C-[}\C-b</p>")

;; Gah, this is awful
(fset 'x-hugh-yank-and-uncomment-region
   [?\C-y ?\C-x ?\C-x ?\M-x ?u ?n ?c ?o ?m ?m ?e ?n ?t ?- ?r ?e tab return ?\C-x ?\C-x])
(defun x-hugh-show-rt-tickets ()
  "Show list of tickets owned by me and status open or new."
  (interactive)
  (rt-liber-browse-query
   (rt-liber-compile-query
    (and (owner "hugh")
	 (or (status "open")
	     (status "new"))))))

(defun x-hugh-show-rt-tickets-2 ()
  "Show list of tickets owned by me and status open or new."
  (interactive)
  (rt-liber-browse-query
   (rt-liber-compile-query
    (or (status "open")
	(status "new")))))

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
	     (save-excursion
	       (set-buffer "*Shell Command Output*")
	       (let ((beg (point-min))
		     (end (- (point-max) 1)))
		 (buffer-substring beg end))))))

(defun x-hugh-wikipedia-over-dns (query)
  "A Small but Useful(tm) function to query Wikipedia over DNS.

See https://dgl.cx/2008/10/wikipedia-summary-dns for details."
  (interactive "sWikipedia: ")
  (let ((query (read-from-minibuffer "Wikipedia: " )))
    (message (format "%s.wp.dg.cx" query))
    (dig (format "%s.wp.dg.cx" query) "txt" "+short")))

(defun x-hugh-wikipedia-over-dns-improved (query)
  "A Small but Useful(tm) function to query Wikipedia over DNS.

Improved a bit: we grab the contents of the output buffer and use
it as input for message.  FIXME:  Still need to kill the buffer.

See https://dgl.cx/2008/10/wikipedia-summary-dns for details.
"
  (interactive "sWikipedia: ")
  (message (format "%s.wp.dg.cx" query))
    (save-excursion
      (set-buffer (dig-invoke (format "%s.wp.dg.cx" query) "txt" "+short"))
      (message "%s: %s" query (let ((beg (point-min))
				    (end (- (point-max) 1)))
				(buffer-substring beg end)))))

(defun x-hugh-hello-world ()
  (interactive)
  (message "Hello, world!"))

(defun x-hugh-figl ()
  (interactive)
  (find-grep-dired))

(defun x-hugh-open-chibi-account-file ()
  (interactive)
  (find-file "~/chibi/chibi-acc.gpg"))


(defun x-hugh-figl (regex)
  "A Small but Useful(tm) shortcut for find-grep-dired, like my figl alias."

  (interactive "sRegex: ")
  (find-grep-dired "." regex))
(global-set-key "\C-cf" 'x-hugh-figl)


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
  (let ((command (read-input "Command to execute: ")))
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

(defun x-hugh-chronicle-new-blog-entry (title)
  "A Small but Useful(tm) function to make a new blog entry in Chronicle."
  (interactive "sTitle: ")
  (setq filename (replace-regexp-in-string "[^a-zA-Z0-9]" "_" (downcase title)))
  (message filename)
  (find-file (concat "/home/aardvark/blog/input/" (format-time-string "%Y-%m") "/" filename ".mdwn"))
  (insert (format "Title: %s\n" title))
  (insert (format "Date: %s\n" (format-time-string "%a %b %d %R:%S %Z %Y")))
  (insert (format "Tags: \n\n")))

(defun x-hugh-chronicle-list-tags ()
  "A Small but Useful9tm) function to list the tags available for Chronicle."
  (interactive)
  (with-output-to-temp-buffer "*Blog tags*"
    (with-current-buffer "*Blog tags*"
      (insert-directory "/home/aardvark/blog/output/tags" "-CF"))))

(defun x-hugh-chronicle-add-tag ()
  (interactive)
;; This turns out to be surprisingly simple
  (insert
   (completing-read "Tag: "
		    (directory-files "/home/aardvark/blog/output/tags"))))

(defun x-hugh-boxquote-yank-and-indent ()
  "My attempt to combine boxquote-yank and indent.
The car/cdr bits are from the docstring for boxquote-points.  It's a bit silly to run it twice, but it was simple."
  (interactive)
  (save-excursion
    (boxquote-yank)
    (next-line)
    (indent-region (car (boxquote-points)) (cdr (boxquote-points)))))

;; Some RT/Org stuff I'm working on
(defun x-hugh-ticket-into-org (&optional point)
  "A Small but Useful(tm) function to insert an RT ticket into Org.

If POINT is nil then called on (point)."
  (interactive)
  (when (not point)
    (setq point (point)))
  ;; (let ((id (rt-liber-browser-ticket-id-at-point)))
  (setq point (point))
  (let ((ticket (get-text-property point 'rt-ticket)))
    (setq subject (cdr (assoc "Subject" ticket)))
    (setq id (rt-liber-browser-ticket-id-at-point))
    (save-excursion
      (set-buffer "all.org")
      (goto-char (point-max))
      (insert (format "** RT #%s -- %s" id subject)))))

(defun x-hugh-get-rt-ticket-subject ()
  "Get RT ticket subject."
  (interactive)
  (setq point (point))
  (let ((subject (cdr (assoc "Subject" (get-text-property point 'rt-ticket)))))
    (message "RT #666 -- %s" subject)))

(defun x-hugh-get-text-properties ()
  "List text properties."
  (interactive)
  (setq point (point))
  (message "%s" (text-properties-at point)))

(defun x-hugh-markdown-footnote (&optional imgplease)
  "Add a footnote in Markdown mode at the *end* of the buffer.

Uses numbers for links. Linkify the region if region active. Prefix means make it an image."
  (interactive "p")
  (let ((current-line (line-number-at-pos))
	(last-line (line-number-at-pos (point-max)))
	(link (read-string "Link: "))
	(link-number (x-hugh-get-next-link-number))
	(first-prefix
	 (if (equal imgplease 1)
	     (setq first-prefix "[")
	   (setq first-prefix "!["))))
    (save-excursion
      (if (> (- last-line current-line) 1)
	  ()
	(insert-string "\n"))
      (goto-char (point-max))
      (if (search-backward-regexp (rx bol "[") (point-min) t)
	  ())
      (forward-line)
      (if (looking-at (rx bol))
	  ()
	(insert-string "\n")
	(forward-line))
      (insert-string (format "[%d]: %s" link-number link)))
    (if (region-active-p)
	(progn
	  (setq pos1 (region-beginning) pos2 (region-end))
	  (goto-char pos1)
	  (insert-string "[")
	  (goto-char pos2)
	  (insert-string (format "][%d]" link-number)))
      (insert-string (format "%s%s][%d]" first-prefix (read-string "Description: ") link-number)))))

(defun x-hugh-get-next-link-number ()
  "Figure out the number for the next link."
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (beginning-of-line)
    (if (looking-at "\\[\\([0-9]+\\)]:")
	(progn
	  (message (match-string 1))
	  (eval (+ 1 (string-to-number (match-string 1)))))
      ; else:
      (if (search-backward-regexp (rx bol "[") (point-min) t)
	  (progn
	    (if (looking-at "\\[\\([0-9]+\\)]:")
		(progn
		  (message (match-string 1))
		  (eval (+ 1 (string-to-number (match-string 1)))))
	      ()))
	(eval 0)))))

(defun x-hugh-wiki-attach-file-to-wiki-page (filename)
  "This is my way of doing things."
  (interactive "fAttach file: ")
  ;; doubled slash, but this makes it clear
  (let* ((page-name (file-name-nondirectory (file-name-sans-extension (buffer-file-name))))
	  (local-attachments-dir (format "%s/attachments/%s" (file-name-directory (buffer-file-name)) page-name))
	   (attachment-file (file-name-nondirectory filename))
	    (attachment-url (format "http://saintaardvarkthecarpeted.com/attachments/%s/%s" page-name attachment-file)))
    (make-directory local-attachments-dir 1)
    (copy-file filename local-attachments-dir 1)
    (insert-string (format "[[%s|%s]]" attachment-file attachment-url))))


(fset 'x-hugh-fix-epub-pdf-paragraph-breaks
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([67108896 19 32 60 47 112 62 13 24 24 134217765 60 47 112 62 return return 33 60 47 112 62 24 24 134217830 134217830 134217830 6 6 134217765 60 112 32 99 108 97 115 115 61 34 99 97 108 105 98 114 101 49 34 62 return return 33 24 24 19 60 47 112 62 13 return backspace 14 1] 0 "%d")) arg)))


(provide 'x-hugh-functions)
