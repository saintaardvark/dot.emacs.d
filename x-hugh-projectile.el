;; x-hugh-projectile --- start here!

;;; Commentary:

;;; Code:

(projectile-mode)

(use-package projectile
  ;; https://emacs.stackexchange.com/questions/32634/how-can-the-list-of-projects-used-by-projectile-be-manually-updated
  ;; FIXME: Not sure what's going wrong.  Evaluating the progn works,
  ;; but not in with the rest of the use-package function.
  :init
  (progn
    (mapc #'projectile-add-known-project
	  (mapcar #'file-name-as-directory (magit-list-repos)))
    ;; Optionally write to persistent `projectile-known-projects-file'
    (projectile-save-known-projects))
   ;; FIXME -- I like the helm-projectile, but I *really* want C-c p s for
  ;; a shell.
)

;; FIXME -- Can't remember why I have this here.  Do I need it?
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)


;; ;; TODO: Add shell as an option for projectile-commander (which is
;; ;; run after C-c p p)

;; ;; TODO: Implement this helm-other-window fix:
;; ;; https://emacs.stackexchange.com/questions/17072/open-file-in-a-specific-window

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

;; TODO: Not working; suspect swallowed by projectile keymap.
;; TODO: Somehow get helm projectile while still have nice keyboard shortcut for shell
;; (global-set-key (kbd "C-c p p") 'helm-projectile-switch-project)

;; http://endlessparentheses.com/improving-projectile-with-extra-commands.html
;;
;; NOTE: Originally, I had this set to projectile-vc, which opens
;; magit.  Nice!  But it would always split the window it was on,
;; which became very annoying.
;; https://github.com/bbatsov/projectile/issues/1624 seemed to
;; describe the error; however, I have a newer version than the one
;; that had the fix (1.6.0), so I'm not sure what's going on.  I'll
;; dig into this another time.
;; April 28, 2022
(setq projectile-switch-project-action
      #'projectile-dired)

;; Ermergerd:
;; `projectile-mode' Minor Mode Bindings Starting With C-c p x:
;; key             binding
;; ---             -------

;; C-c p x e       projectile-run-eshell
;; C-c p x s       projectile-run-shell
;; C-c p x t       projectile-run-term

(provide 'x-hugh-projectile)
;;; x-hugh-projectile ends here
