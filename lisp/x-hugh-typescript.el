;;; x-hugh-typescript --- stuff related to go editing

;;; Commentary:

;;; Code:

;; TODO: Break out to x-hugh-node or some such

(use-package "nvm"
  :ensure t)

;; TODO: use-package
(defun setup-tide-mode ()
  "Set up tide mode for the developer."
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. you have to
  ;; install it separately via package-install
  ;; `m-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
;; NOTE: This fucks with existing projects; leaving here for
;; reference, but this is not a good thing to turn on globally.
; (add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

(provide 'x-hugh-typescript)
;;; x-hugh-typescript ends here
