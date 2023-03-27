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
    (insert (format "%s/browse/"x-hugh-jira-url))))

(provide 'x-hugh-jira)

;;; x-hugh-jira ends here
