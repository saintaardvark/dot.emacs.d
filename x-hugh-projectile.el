;; x-hugh-projectile --- start here!

;;; Commentary:

;;; Code:

;; (add-hook 'chef-mode-hook 'projectile-mode)
(projectile-global-mode)

;; (projectile-register-project-type
;;  'chef
;;  '("Berksfile")           ; marker files
;;  "bundle exec rails server"             ; compile command
;;  "chef exec rspec"                      ; test command
;;  "kitchen test")
                                        ; run command

;; Copy-pasta...there must be a better way to do this.

(defun x-hugh-projectile-test-suffix (project-type)
  "Find default test files suffix based on PROJECT-TYPE."
  (cond
   ((member project-type '(emacs-cask)) "-test")
   ((member project-type '(rails-rspec ruby-rspec)) "_spec")
   ((member project-type '(rails-test ruby-test lein-test boot-clj go)) "_test")
   ((member project-type '(scons)) "test")
   ((member project-type '(maven symfony)) "Test")
   ((member project-type '(gradle gradlew grails)) "Spec")
   ;; And now chef
   ((member project-type '(chef)) "_spec")))

(setq projectile-test-suffix-function 'x-hugh-projectile-test-suffix)

(global-set-key (kbd "C-c p p") 'helm-projectile-switch-project)

;; http://endlessparentheses.com/improving-projectile-with-extra-commands.html
(setq projectile-switch-project-action
      #'projectile-commander)

;; Ermergerd:
;; `projectile-mode' Minor Mode Bindings Starting With C-c p x:
;; key             binding
;; ---             -------

;; C-c p x e       projectile-run-eshell
;; C-c p x s       projectile-run-shell
;; C-c p x t       projectile-run-term

(provide 'x-hugh-projectile)
;;; x-hugh-projectile ends here
