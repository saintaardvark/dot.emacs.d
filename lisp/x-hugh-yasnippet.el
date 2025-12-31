;;; -*- lexical-binding: t; -*-
;;; x-hugh-yasnippet --- Provide yasnippet

;;; Commentary:

(setq x-hugh-snippets-dir "~/.emacs.d/snippets")

;;; Code:
(use-package yasnippet
  :ensure t
  :init
  (setq yas-snippet-dirs
	'("~/.emacs.d/snippets"))
  :custom
  ;; These two lines make Python snippets work w/r/t indentation.
  ;; https://emacs.stackexchange.com/questions/66878/yasnippet-snippets-indention-not-correct-for-python-functions
  (yas-indent-line 'fixed)
  (yas-wrap-around-region 'nil)
  :config
  (yas-global-mode 1)
 )

;; https://www.reddit.com/r/emacs/comments/6ogn6c/indentation_in_yasnippet/
;; TODO: Figure out how to add this as a :hook stanza in use-package
(add-hook 'python-mode-hook '(lambda () (set (make-local-variable 'yas-indent-line) 'fixed)))

;; https://www.emacswiki.org/emacs/Yasnippet#toc4
;; not yet working.
(defun shk-yas/helm-prompt (prompt choices &optional display-fn)
  "Use helm to select a snippet. Put this into `yas-prompt-functions.'"
  (interactive)
  (setq display-fn (or display-fn 'identity))
  (if (require 'helm-config)
      (let (tmpsource cands result rmap)
        (setq cands (mapcar (lambda (x) (funcall display-fn x)) choices))
        (setq rmap (mapcar (lambda (x) (cons (funcall display-fn x) x)) choices))
        (setq tmpsource
              (list
               (cons 'name prompt)
               (cons 'candidates cands)
               '(action . (("Expand" . (lambda (selection) selection))))
               ))
        (setq result (helm-other-buffer '(tmpsource) "*helm-select-yasnippet"))
        (if (null result)
            (signal 'quit "user quit!")
          (cdr (assoc result rmap))))
    nil))

(provide 'x-hugh-yasnippet)
;;; x-hugh-yasnippet.el ends here
