;;; x-hugh-golang --- stuff related to go editing

;;; Commentary:

;;; Code:

(exec-path-from-shell-copy-env "GOPATH")

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



(provide 'x-hugh-golang)
;;; x-hugh-golang ends here
