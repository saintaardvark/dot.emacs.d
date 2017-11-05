;; x-hugh-03-org.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-mode settings.

; My goddamn path to org
;(setq load-path  (cons (expand-file-name "~/.emacs.d/org") load-path))
;lo(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(global-set-key (kbd "C-M-r") 'org-capture)
(global-set-key (kbd "<f12>") 'org-agenda)

(add-hook 'org-after-todo-state-change-hook
	  'x-hugh-org-schedule-todo-item)

(defun x-hugh-org-schedule-todo-item ()
  "Prompt for date to actually do something marked TODO."
  (when (string= org-state "TODO")
    (org-schedule 1)))

(setq org-agenda-custom-commands
      '(
	("P" "Done last year" ((tags "CLOSED<=\"<2014-01-01>\"")))
	("p" "My custom agenda"
	 ((org-agenda-list nil nil 1)
;;;	  (todo "TODO")
	  (stuck "")
	  (todo "Waiting"
		((org-agenda-overriding-header "\Waiting:\n--------\n")))
	  (todo "NBIJ"
		((org-agenda-overriding-header "\Next beer in Jerusalem:\n-----------------------\n")))
	  (search "TODO -{SCHEDULED}"
		((org-agenda-overriding-header "Not scheduled:\n")))))))

(defun x-hugh-find-rt-ticket-number-from-rt-email ()
  "Find a ticket number from rt-email.

Used in a few different places; time to break it out."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward "Subject: ")
    (if (search-forward-regexp "\\[rt.chibi.ubc.ca #\\([0-9]+\\)\\]\\(.*\\)$" (line-end-position) t)
	(match-string 1))))

(defun x-hugh-find-rt-ticket-subject-from-rt-email ()
  "Find a ticket subject from rt-email.

Used in a few different places; time to break it out."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward "Subject: ")
    (if (search-forward-regexp "\\[rt.chibi.ubc.ca #\\([0-9]+\\)\\]\\(.*\\)$" (line-end-position) t)
	(match-string 2))))

(defun x-hugh-insert-rt-ticket-into-org-from-rt-email (&optional arg)
  "Insert an RT ticket into Org and clock in while editing a reply to that email.
Faster than waiting for rt-browser to update.

If argument provided, do NOT clock in.
"
  (interactive "P")
  (let ((id (x-hugh-find-rt-ticket-number-from-rt-email))
	(subject (x-hugh-find-rt-ticket-subject-from-rt-email)))
	(x-hugh-insert-rt-ticket-into-org-generic id subject arg)
	    (org-clock-in)))

(defun x-hugh-insert-rt-ticket-into-org-generic (id subject &optional arg)
  "Generic way of inserting an org entry for an RT ticket (if necessary).

If arg provided, do NOT clock in.
"
 (interactive "P")
 (save-excursion
   (set-buffer (find-file-noselect "~/chibi/all.org"))
   (goto-char (point-min))
   (if (search-forward-regexp  (format "^\\*\\* .*RT #%s.*$" id) (point-max) t)
       (message "Already in org!")
     (progn
       (goto-char (point-max))
       (if (bolp)
	   ()
	 (insert "\n"))
       (insert (format "** RT #%s --%s\n" id subject))))
   (unless arg
     (org-clock-in))))

(defun x-hugh-insert-rt-ticket-into-org (&optional point arg)
  "A Small but Useful(tm) function to insert an RT ticket into Org.

If POINT is nil then called on (point).  If called with arg, check in as well."
  (interactive "P")
  (when (not point)
    (setq point (point)))
  ;; (let ((id (rt-liber-browser-ticket-id-at-point)))
  (setq point (point))
  (let ((ticket (get-text-property point 'rt-ticket)))
    (setq subject (cdr (assoc "Subject" ticket)))
    (setq id (rt-liber-browser-ticket-id-at-point))
    (save-excursion
      (set-buffer (find-file-noselect "~/chibi/all.org"))
      (goto-char (point-min))
      (if (search-forward-regexp  (format "^\\*\\* .*RT #%s.*$" id) (point-max) t)
	  (message "Already in org!")
	(progn
	  (goto-char (point-max))
	  (if (bolp)
	      ()
	    (insert "\n"))
	  (insert (format "** RT #%s -- %s\n" id subject))))
      (if arg
	  (org-clock-in)))))

(defun x-hugh-clocked-into-rt-ticket ()
  "A Small but Useful(tm) function to see if I'm clocked into an RT ticket.

Depends on regular expressions, which of course puts me in a state of sin."
  (interactive)
  (if (equal nil org-clock-current-task)
      ()
    (when (string-match "\\(RT #[0-9]+\\)" org-clock-current-task)
     (eval (format "%s" (match-string 1 org-clock-current-task))))))

(defun x-hugh-clocked-into-rt-ticket-number-only ()
  "A Small but Useful(tm) function to see if I'm clocked into an RT ticket.

Depends on regular expressions, which of course puts me in a state of sin."
  (interactive)
  (if (equal nil org-clock-current-task)
      ()
    (if (string-match "RT #\\([0-9]+\\)" org-clock-current-task)
	(format "%s" (match-string 1 org-clock-current-task))
      ())))

(defun x-hugh-open-org-file-for-rt-ticket ()
  "A Small but Useful(tm) function to open the notes file for a ticket."
  (interactive)
  (find-file (format "~/git/rt_%s/notes.org" (x-hugh-clocked-into-rt-ticket-number-only))))

(defun x-hugh-insert-rt-ticket-commit-comment ()
  "A Small but Useful(tm) function to insert a comment referencing an RT ticket.

Uses the currently-clocked in task as default."
  (interactive)
  (insert-string (format "see %s for details." (x-hugh-clocked-into-rt-ticket))))

(defun x-hugh-schedule-rt-ticket-for-today-from-rt-email (&optional arg)
  "Schedule an RT ticket for today while editing that email.  Optional arg sets prio to A.

Can be called from Mutt as well."
  (interactive "P")
  (x-hugh-insert-rt-ticket-into-org-from-rt-email)
  (let ((id (x-hugh-find-rt-ticket-number-from-rt-email))
	(subject (x-hugh-find-rt-ticket-subject-from-rt-email)))
	(x-hugh-schedule-rt-ticket-for-today-generic id subject arg)))

(defun x-hugh-schedule-rt-ticket-for-today-generic (id subject &optional arg)
  "Generic way to schedule an RT ticket for today.  Optional arg sets prio to A."
  (interactive "P")
 (save-excursion
   (set-buffer (find-file-noselect "~/chibi/all.org"))
   (goto-char (point-min))
   (if (search-forward-regexp  (format "^\\*\\* .*RT #%s.*$" id) (point-max) t)
       (progn
	 (org-schedule 1 ".")))
   (if arg
       (org-priority-up))))


;; (defun x-hugh-mail-buffer-to-rt ()
;;   "A Small but Useful(tm) function to email a buffer to RT.

;; A good start, even if it does make Baby RMS cry."
;;   (interactive)
;;   (save-excursion
;;     (kill-region (point-min) (point-max))
;;     (yank)
;;     (compose-mail)
;;     (goto-char (point-max))
;;     (yank)))

(defun org-column-view-uses-fixed-width-face ()
;; copy from org-faces.el
(when (fboundp 'set-face-attribute)
    ;; Make sure that a fixed-width face is used when we have a column
    ;; table.
    (set-face-attribute 'org-column nil
                        :height (face-attribute 'default :height)
                        :family (face-attribute 'default :family))))

 (when (and (fboundp 'daemonp) (daemonp))
  (add-hook 'org-mode-hook 'org-column-view-uses-fixed-width-face))

(org-babel-do-load-languages
 'org-babel-load-languages
  '( (perl . t)
     (ruby . t)
     (sh . t)
     (python . t)
     (emacs-lisp . t)
   ))

(defun x-hugh-resolve-rt-ticket-after-org-rt-done ()
  "Resolve an RT ticket after the org entry is marked done.

Meant to be called from org-after-todo-state-change-hook.
Originally I had used x-hugh-clocked-into-rt-ticket-number-only
to try and figure out the ticket number, but I'd forgotten that
a) by the time this hook runs, we're no longer clocked into
anything (if we were before), and b) I might want to run this
while not clocked into anything. So I duplicate the extraction of
ticket number that's in x-hugh-clocked, which FIXME."
  (interactive)
  (when (string-equal org-state "DONE")
    ; x-hugh-clocked-into-rt-ticket-number-only -- not quite, but close.
    (when (looking-at ".*RT #\\([0-9]+\\)")
      (message "I'm gonna try to close this ticket!")
	(x-hugh-rt-resolve-without-mercy-noninteractive (format "%s" (match-string 1 org-clock-current-task))))))

(add-hook 'org-after-todo-state-change-hook 'x-hugh-resolve-rt-ticket-after-org-rt-done)

;; https://stackoverflow.com/questions/14193975/strike-through-headlines-for-done-tasks-in-org
(setq org-fontify-done-headline t)
(custom-set-faces
 '(org-done ((t (:foreground "PaleGreen"
                 :weight normal
                 :strike-through t))))
 '(org-headline-done
            ((((class color) (min-colors 16) (background dark))
               (:foreground "LightSalmon" :strike-through t)))))

(defun x-hugh-org-clock-in-starting-now-dammit ()
  "Clock in with starting time of right now, no matter what org-clock-continuously says."
  (interactive)
  (let ((org-clock-continuously nil))
    ;; if buffer Agenda, then org-agenda-clock-in.
    (if (string= (buffer-name) "*Org Agenda*")
	(org-agenda-clock-in)
      (org-clock-in))))

(defun x-hugh-org-daily-report ()
  "ZOMG shoulda done this long ago!  FIXME: Not done yet; some
pseudocode in here.  Meant to leave the report to be yanked, but
probably simpler just to insert at point wherever you are."
  (interactive)
  (insert-string "Hi Paul -- here's what I've worked on today.  Let me know if you have any questions.

Thanks,
Hugh

")
  (save-excursion
    (goto-char (point-min))
    (search-forward "Subject:")
    (insert-string (format " Activity report -- %s" (format-time-string "%A %B %d, %Y"))))
  (save-excursion
    (org-clock-report)
    (search-forward ":scope file")
    (backward-kill-word 1)
    (insert-string "agenda")
    (insert-string " :block today")
    (insert-string " :narrow 60!")
    (org-dblock-update)
    (goto-char (point-min))
    (search-forward "#+BEGIN")
    (let ((beg (line-beginning-position)))
      (forward-line 2)
      (delete-region beg (point)))
    (search-forward "#+END")
    (let ((beg (line-beginning-position)))
      (forward-line 1)
      (delete-region beg (point)))))

(defun x-hugh-org-yearly-report ()
  "Yearly report.  FIXME: Not done yet."
  (interactive)
  (let ((org-time-clocksum-format "%d:%02d"))
    (org-clock-report)
    (search-forward ":scope file")
    (backward-kill-word 1)
    (insert-string "agenda")
    (insert-string " :block 2014 :narrow 60!")
    (org-dblock-update)))


(defun x-hugh-org-new-day-in-notes ()
  "Start a new day in a notes file."
  (interactive)
  (goto-char (point-max))
  (org-insert-heading)
  (let ((current-prefix-arg '(16)))
    (call-interactively 'org-time-stamp-inactive))
  (align-newline-and-indent)
  (insert "- "))

(defun x-hugh-org-publish-books-org()
  "Publish books.org as HTML on website."
  (interactive)
  (save-excursion
    (find-file "/home/aardvark/orgmode/books.org")
    (org-html-export-as-html)
    (write-region nil nil "/l2:/home/aardvark/public_html/random/books.html")
    (kill-buffer)))

(defun x-hugh-org-export-password-file()
  "Export the password file in HTML to /dev/shm."
  (interactive)
  (save-excursion
    (org-html-export-as-html)
    (write-region nil nil "/dev/shm/passwords.html")
    ;; Optionally: could do something like:
    ;; (let (printer-name "ML-1750")
    ;;   (print-buffer))
    ;; Note: not yet working.
    (kill-buffer)))

(provide 'x-hugh-org)
