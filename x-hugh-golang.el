;;; x-hugh-go --- stuff related to go editing

;;; Commentary:

;;; Code:

(go-eldoc-setup)

(defun go-mode-setup ()
  "Wrapper for a bunch of Golang settings."
  (setq compile-command "go build -v && go test -v && go vet && golint && errcheck")
  (go-eldoc-setup)
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)
  (local-set-key (kbd "M-.") 'godef-jump))

(add-hook 'go-mode-hook 'go-mode-setup)
(add-to-list 'load-path (concat (getenv "GOPATH")  "/src/github.com/golang/lint/misc/emacs"))

(provide 'x-hugh-golang)



(provide 'x-hugh-go)
;;; x-hugh-go.el ends here.
