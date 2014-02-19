;; x-hugh-03-org.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-mode settings.

(setq load-path  (cons (expand-file-name "~/.emacs.d/org/lisp") load-path))
(require 'org-install nil 'noerror)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(add-hook 'org-after-todo-state-change-hook
	  'x-hugh-org-schedule-todo-item)

(defun x-hugh-org-schedule-todo-item ()
  "Prompt for date to actually do something marked TODO."
  (when (string= state "TODO")
    (org-schedule)))

(setq org-agenda-custom-commands
      '(
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

(defun x-hugh-insert-rt-ticket-into-org (ticket)
  (interactive "nTicket: ")
  (org-insert-heading-after-current)
  (insert-string (format "RT #%d -- " ticket)))

(setq org-fontify-done-headline t)
(custom-set-faces
 '(org-done ((t (:foreground "PaleGreen"
                 :weight normal
                 :strike-through t))))
 '(org-headline-done
            ((((class color) (min-colors 16) (background dark))
               (:foreground "LightSalmon" :strike-through t)))))

(provide 'x-hugh-org)
