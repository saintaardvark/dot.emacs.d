;; x-hugh-smartparens --- smartparens settings

;;; Commentary:

;;; Code:


(defmacro x-hugh-sp-add-hook-to-modes (modes)
  "Ensure that smart-parens mode is added to each of (MODES) mode-hook."
  (dolist (mode modes)
    (let ((hooksymbol (intern (concat mode "-mode-hook"))))
      (add-hook hooksymbol #'smartparens-mode))))

(x-hugh-sp-add-hook-to-modes ("emacs-lisp"
                              "go"
                              "json"
                              "markdown"
                              "ruby"
                              "python"
                              "shell"
                              "terraform"
                              "toml"
                              "yaml"))

(provide 'x-hugh-smartparens)
;;; x-hugh-smartparens ends here
