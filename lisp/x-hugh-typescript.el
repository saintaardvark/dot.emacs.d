;;; -*- lexical-binding: t -*-
;;; x-hugh-typescript --- stuff related to go editing

;;; Commentary:

;;; Code:

;; TODO: Break out to x-hugh-node or some such

(use-package "nvm"
  :ensure t)

(use-package "tide"
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

;; Require web mode when editing tsx files.
;;
;; TODO: So far, my approach to separating elisp files has been
;; something like "one per package".  However, this file is a perfect
;; example of a case where it'd make a lot of sense to have "one per
;; task" -- x-hugh-web.el, for example, which would hold Typescript,
;; Javascript, HTML and other webby things.
;;
;; Note that at least part of what prompts that comment is the use of
;; flycheck up ahead.  Really, where *should* that go?  Should it be
;; in x-hugh-flycheck?  In here?  Obviously, these two files still
;; work as config files even if the settings are split up -- but then
;; I need to keep ordering in mind.
;;
;; *stops before badly implementing a dependency graph for elisp
;; *packages*


(use-package web-mode
  :custom
  (web-mode-code-indent-offset 2)
  (web-mode-markup-indent-offset 2))
;; TODO: Put these next two bits into the use-package stanza
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (setup-tide-mode))))

;; enable typescript-tslint checker
(flycheck-add-mode 'typescript-tslint 'web-mode)

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
;; NOTE: This fucks with existing projects; leaving here for
;; reference, but this is not a good thing to turn on globally.
;; (add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

;; Again, more Javascript stuff.
;; comint-mode appears wonderful.  Source: https://www.emacswiki.org/emacs/NodeJs
(defun node-repl ()
  (interactive)
  (setenv "NODE_NO_READLINE" "1") ;avoid fancy terminal codes
  (pop-to-buffer (make-comint "node-repl" "node" nil "--interactive")))

(provide 'x-hugh-typescript)
;;; x-hugh-typescript.el ends here
