;;; x-hugh-golang --- stuff related to go editing

;;; Commentary:

;;; Code:

(exec-path-from-shell-copy-env "GOPATH")
(exec-path-from-shell-copy-env "GOROOT")
(setenv "GO111MODULE" "auto")		; Will this fix gopls borking in streamline-ssh?

(use-package go-eldoc
  :ensure t
  :config (go-eldoc-setup)
  )


;; FIXME: Flycheck + go vet has a very annoying error in golang mode
;; that doesn't seem to have been fixed.  Full details at
;; https://github.com/flycheck/flycheck/issues/1659, but in the
;; meantime you'll want to turn off flycheck in golang.

;; FIXME: One more problem with flycheck: seems to break when checking
;; imports when lsp is turned on.  Maybe relevant:
;; https://github.com/emacs-lsp/lsp-mode/issues/2207

;; FIXME: gocode not on laptop, causing flashing when it tries to run.
;; Probably an autocomplete/company thing.  However, looks like it's
;; no longer maintained: https://github.com/nsf/gocode :blobfish:

;; FIXME: Figure out how to get goimports running here
(defun go-mode-setup ()
  "Wrapper for a bunch of Golang settings."
  (add-hook 'before-save-hook 'gofmt-before-save)
  ;; (local-set-key (kbd "M-.") 'godef-jump)
  (company-mode)
  (setq flycheck-checkers (remove "go-vet" flycheck-checkers))
  (set (make-local-variable 'company-backends) '(company-go))
  (setq compile-command "")
  (setq indent-tabs-mode 1)
  (setq tab-width 4)
  (eglot-ensure))

(add-to-list 'load-path (concat (getenv "GOPATH")  "/src/github.com/golang/lint/misc/emacs"))

(add-hook 'go-mode-hook 'go-mode-setup)

(provide 'x-hugh-golang)
;;; x-hugh-golang.el ends here
