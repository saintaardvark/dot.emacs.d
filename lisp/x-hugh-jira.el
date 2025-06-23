;;; -*- lexical-binding: t -*-
;;; x-hugh-jira --- some helpful JIRA stuff

;;; Commentary:

;;; Code:

;; I may be missing something, but after browing through the elisp
;; manual I wasn't able to find a way to have a fallbck value for a
;; variable/constant.  This applies to argument defaults for a
;; function as well.

(defconst x-hugh-jira-url
  (let ((tempvar(getenv "JIRA_URL")))
    (if (eq tempvar nil)
	"NOT_SET"
      tempvar))
  "URL for JIRA server; copied from environment variable.")

(defun x-hugh-jira-test ()
  "Test."
  (interactive)
  (message (format "URL: %s" x-hugh-jira-url)))

(defun x-hugh-expand-jira ()
  "Expand JIRA URL for a ticket.

Expects to be called at point immediately after ticket, eg:

DNS-123[and now call this function]"
  (interactive)
  (save-excursion
    (backward-word 2)
    (insert (format "%s/browse/" x-hugh-jira-url))))

(defun x-hugh-make-link-out-of-ticket (beg end)
  "Refactored version that's better."
  (interactive "r")
  (save-excursion
    (let ((ticket (buffer-substring-no-properties beg end)))
      (cond ((eq major-mode 'org-mode)
	     (progn (delete-region beg end)
		    (org-insert-link nil (format "%s/browse/%s" x-hugh-jira-url ticket) ticket)))
	    ((eq major-mode 'markdown-mode)
	     (progn (delete-region beg end)
		    ;; I'm surprised there isn't a markdown-insert-link function...
		    (insert (format "[%s][%s/browse/%s]" ticket x-hugh-jira-url ticket))))
	    (t (message (format "I don't know how to make a link in %s!" major-mode)))))))

(defun x-hugh-maybe-better-make-link-out-of-ticket (ticket)
  "Refactored version that's better."
  (interactive "sTicket DNS-")
  (save-excursion
    
    (let* ((bounds (bounds-of-thing-at-point 'word))
	   (beg (car bounds))
	   (end (cdr bounds))
	   (ticket (buffer-substring-no-properties (car bounds) (cdr bounds))))
      (cond ((eq major-mode 'org-mode)
	     (progn (delete-region beg end)
		    (org-insert-link nil (format "%s/browse/%s" x-hugh-jira-url ticket) ticket)))
	    ((eq major-mode 'markdown-mode)
	     (progn (delete-region beg end)
		    ;; I'm surprised there isn't a markdown-insert-link function...
		    (insert (format "[%s][%s/browse/%s]" ticket x-hugh-jira-url ticket))))
	    (t (message (format "I don't know how to make a link in %s!" major-mode)))))))

            
;; DNS-[[https://wyvernspace.atlassian.net/browse/123][123]]

(defun x-hugh-make-markdown-link-out-of-ticket (beg end)
  "Make org link out of ticket number."
  (interactive "r")
  (save-excursion
    (let ((ticket (buffer-substring-no-properties beg end)))
      (goto-char beg)
      (insert "[")
      (goto-char end)
      (insert (format "](https://wyvernspace.atlassian.net/browse/%s)"ticket)))))

(provide 'x-hugh-jira)

;;; x-hugh-jira ends here
