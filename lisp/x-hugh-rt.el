;;; -*- lexical-binding: t -*-
;;; x-hugh-rt --- My Request Tracker stuff

;;; Commentary:
;;; Might as well put them some place...

;;; Code:

;; Some RT/Org stuff I'm working on
(defun x-hugh-ticket-into-org (&optional point)
  "A Small but Useful(tm) function to insert an RT ticket into Org.

If POINT is nil then called on (point).  If called with arg, check in as well."
  (interactive "P")
  (when (not point)
    (setq point (point)))
  ;; (let ((id (rt-liber-browser-ticket-id-at-point)))
  (setq point (point))
  (let ((ticket (get-text-property point 'rt-ticket)))
    ;; FIXME: Should change previous to let*, and change the setq to be part of them.
    (setq subject (cdr (assoc "Subject" ticket)))
    (setq id (rt-liber-browser-ticket-id-at-point))
    (with-current-buffer "all.org"
      (goto-char (point-min))
      (if (search-forward-regexp  (format "^\\*\\* .*RT #%s.*$" id) (point-max) t)
	  (message "Already in org!")
	(progn
	  (goto-char (point-max))
	  (if (bolp)
	      ()
	    (insert "\n"))
	  (insert (format "** RT #%s -- %s\n" id subject))))
      ;; FIXME: Not taking arg in defun!
      (if arg
	  (org-clock-in)))))

(defun x-hugh-email-rt (&optional arg ticket)
  "A Small but Useful(tm) function to email RT about a particular ticket. Universal argument to make it Bcc."
  (interactive "P\nnTicket: ")
  (save-excursion
    (goto-char (point-min))
    (if arg
	(search-forward "Bcc:")
      (search-forward "To:"))
    (insert " rtc")
    (search-forward "Subject:")
    (insert (format " [rt.chibi.ubc.ca #%d] " ticket))))

(defun x-hugh-new-rt-email ()
  "A Small but Useful(tm) function to send an email to RT for a new ticket."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward "To:")
    (insert " help@chibi.ubc.ca")))

(defun x-hugh-email-rt-dwim (&optional arg)
  "A Small but Useful(tm) function to email RT about a particular ticket. Universal argument to send to rt instead of rt-comment.

  Will do its best to figure out the ticket number on its own, and prompt if needed; and will send a Bcc: if it looks like there's already a To: address."
  (interactive "P\n")
  (if arg
      (setq sendto "rt")
    (setq sendto "rtc"))
  (save-excursion
    (goto-char (point-min))
    (search-forward "To:")
    (if (search-forward-regexp "\\w" (line-end-position) t)
	(progn
	  (search-forward "Bcc:")
	  (insert (format " %s" sendto)))
      (insert (format " %s" sendto)))
    (search-forward "Subject:")
    (if (search-forward "[rt.chibi.ubc.ca #" (line-end-position) t)
	()
      (insert
       (format " [rt.chibi.ubc.ca #%s] "
	       (read-string "Ticket: " nil nil (format "%s" (x-hugh-clocked-into-rt-ticket-number-only))))))))

(defun x-hugh-show-rt-tickets-queue (searchqueue)
  "Show list of tickets owned by me and status open or new."
  (interactive "sQueue: ")
  (rt-liber-browse-query
   (rt-liber-compile-query
    (and (queue searchqueue)
	 (not (status "resolved"))))))

(defun x-hugh-show-rt-tickets ()
  "Show list of tickets owned by me and status open or new."
  (interactive)
  (rt-liber-browse-query
   (rt-liber-compile-query
    (and (owner "hugh")
	 (or (status "open")
	     (status "new"))))))

(defun x-hugh-show-rt-tickets-2 ()
  "Show list of tickets, status open or new, owned by anyone."
  (interactive)
  (rt-liber-browse-query
   (rt-liber-compile-query
    (or (status "open")
	(status "new")))))

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

(defun x-hugh-insert-wiki-rt-link (ticket)
  (interactive "nTicket: ")
  (insert (format "[[RT #%d|http://rt.chibi.ubc.ca/Ticket/Display.html?id=%d]]" ticket ticket)))

(defun x-hugh-insert-wiki-rt-link-as-detailed-in (ticket)
  (interactive "nTicket: ")
  (insert (format "As detailed in [[RT #%d|http://rt.chibi.ubc.ca/Ticket/Display.html?id=%d]]," ticket ticket)))


(defun x-hugh-rt-resolve-without-mercy-interactive (ticket)
  "Resolve an RT ticket without hesitation.

Do it, monkey boy!"
  (interactive "sTicket: ")
  (start-process "nomercy" "rt-resolve-without-mercy" "~/bin/rt-resolve-without-mercy.sh" ticket))

;; FIXME: Too stupid right now to figure out how to do the right
;; thing: only prompting if there's no ticket supplied.
(defun x-hugh-rt-resolve-without-mercy-noninteractive (ticket)
  "Resolve an RT ticket without hesitation.

Do it, monkey boy!"
  (start-process "nomercy" "rt-resolve-without-mercy" "~/bin/rt-resolve-without-mercy.sh" ticket))

(defun x-hugh-rt-get-already-existing-ticket-subject (ticket)
  "Get the subject from an already-existing ticket."
  (interactive "sTicket: ")
  (insert (shell-command-to-string (format "~/bin/rt-get-ticket-subjectline.sh %s" ticket))))

;; FIXME: This should be in org.
;; FIXME: This is a duplicate of x-hugh-rt-get-already-existing-ticket-subject.
(defun x-hugh-org-autofill-rt-entry (ticket)
  "Autofill Org RT entry from an already-existing ticket."
  (interactive "sTicket: ")
  (insert (format "RT #%s -- %s" ticket (shell-command-to-string (format "~/bin/rt-get-ticket-subjectline.sh %s" ticket)))))

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

(provide 'x-hugh-rt)
;;; x-hugh-rt.el ends here
