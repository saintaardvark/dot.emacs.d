;; x-hugh-projectile --- start here!

;;; Commentary:

;;; Code:

(use-package projectile
  ;; https://emacs.stackexchange.com/questions/32634/how-can-the-list-of-projects-used-by-projectile-be-manually-updated
  ;; FIXME: Not sure what's going wrong.  Evaluating the progn works,
  ;; but not in with the rest of the use-package function.
  :ensure t
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (progn
    (mapc #'projectile-add-known-project
	  (mapcar #'file-name-as-directory (magit-list-repos)))
    ;; Optionally write to persistent `projectile-known-projects-file'
    (projectile-save-known-projects))
  ;; FIXME -- I like the helm-projectile, but I *really* want C-c p s for
  ;; a shell.
  :custom
  ;; http://endlessparentheses.com/improving-projectile-with-extra-commands.html
  ;; FIXME: this might be the source of the other-window problem
  (projectile-switch-project-action #'projectile-vc)
  )

;; FIXME: Not sure what's going on, but for some reason my list of
;; known projects isn't getting loaded when projectile initializes.
;; To get around this manually, I'm adding this line:
;;
(projectile-load-known-projects)

;; ;; TODO: Add shell as an option for projectile-commander (which is
;; ;; run after C-c p p)

;; TODO: Implement this helm-other-window fix:
;; https://emacs.stackexchange.com/questions/17072/open-file-in-a-specific-window

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

;; TODO: Not working; suspect swallowed by projectile keymap.
;; TODO: Somehow get helm projectile while still have nice keyboard shortcut for shell
;; (global-set-key (kbd "C-c p p") 'helm-projectile-switch-project)

;; Ermergerd:
;; `projectile-mode' Minor Mode Bindings Starting With C-c p x:
;; key             binding
;; ---             -------

;; C-c p x e       projectile-run-eshell
;; C-c p x s       projectile-run-shell
;; C-c p x t       projectile-run-term

(provide 'x-hugh-projectile)
;;; x-hugh-projectile ends here
