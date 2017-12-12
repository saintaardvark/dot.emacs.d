;;; x-hugh-golang --- stuff related to go editing

;;; Commentary:

;;; Code:

(exec-path-from-shell-copy-env "GOPATH")

(go-eldoc-setup)

;; FIXME: Figure out how to get goimports running here
(defun go-mode-setup ()
  "Wrapper for a bunch of Golang settings."
  (add-hook 'before-save-hook 'gofmt-before-save)
  (local-set-key (kbd "M-.") 'godef-jump)
  (set (make-local-variable 'company-backends) '(company-go))
  (setq compile-command "go build -v && go test -v && go vet && golint && errcheck")
  (setq indent-tabs-mode 1)
  (setq tab-width 4))

(add-to-list 'load-path (concat (getenv "GOPATH")  "/src/github.com/golang/lint/misc/emacs"))

(defun x-hugh-golang-insert-log-debug()
  "Insert log.Printf(\"[DEBUG])"
  (interactive)
  (insert "log.Printf(\"[DEBUG] \")")
  (backward-char 2))

(add-hook 'go-mode-hook 'go-mode-setup)

(provide 'x-hugh-golang)
;;; x-hugh-golang ends here
