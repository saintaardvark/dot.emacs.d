;; x-hugh-projectile --- start here!

;;; Commentary:

;;; Code:

;; Not exactly sure this is the right place, but it'll do for now
(defconst x-hugh-preferred-repo-dir
    (let ((tempvar(getenv "PREFERRED_REPO_DIR")))
    (if (eq tempvar nil)
	"~/dev"
      tempvar))
  "Preferred repo dir; copied from env var PREFERRED_REPO_DIR.")

(defun x-hugh-open-preferred-repo-dir ()
  "Open preferred repo dir in dired."
  (interactive)
  (dired x-hugh-preferred-repo-dir))

(defun x-hugh-open-preferred-repo-dir-scratch-repos ()
  "Open preferred repo dir in dired, but just the scratch repos."
  (interactive)
  (dired (format "%s/*scratch" x-hugh-preferred-repo-dir)))

(defun x-hugh-list-scratch-projects ()
  "Return list of scratch projects."
  (interactive)
  (directory-files x-hugh-preferred-repo-dir t "\\\\*scratch"))

(defun x-hugh-projectile-switch-to-scratch-project ()
  "Switch to one of my scratch projects."
  (interactive)
  (projectile-completing-read
    "Switch to project: " (x-hugh-list-scratch-projects)
    :action (lambda (project)
	      (projectile-switch-project-by-name project))))

;; Putting it here to make sure Projectile can use it
(use-package ripgrep
  :ensure t)

(defun x-hugh-update-projectile-known-projects-list ()
  "Update projectile's list of known projects.

Handy if I add more projects through git clone, say."
  (interactive)
  (mapc #'projectile-add-known-project
	(mapcar #'file-name-as-directory (magit-list-repos))))

(use-package projectile
  ;; https://emacs.stackexchange.com/questions/32634/how-can-the-list-of-projects-used-by-projectile-be-manually-updated
  ;; FIXME: Not sure what's going wrong.  Evaluating the progn works,
  ;; but not in with the rest of the use-package function.
  :ensure t
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (progn
    (x-hugh-update-projectile-known-projects-list)
    )
  ;; Optionally write to persistent `projectile-known-projects-file'
  ;; FIXME: This was causing problems, so I've removed it.
  ;; FIXME -- I like the helm-projectile, but I *really* want C-c p s for
  ;; a shell.
  :custom
  ;; http://endlessparentheses.com/improving-projectile-with-extra-commands.html
  ;; FIXME: this might be the source of the other-window problem
  (projectile-switch-project-action #'projectile-vc)
  ;; FIXME: Not sure what's going on, but for some reason my list of
  ;; known projects isn't getting loaded when projectile initializes.
  ;; To get around this manually, I'm adding this line:
  :config (projectile-load-known-projects)
  )

;; Good lord...ran into problems with projectile today:
;; - not caching new projects
;; - (wrong-type-argument hash-table-p nil) when running projectile-current-project-files
;; turns out the solution is to call projectile-global-mode --
;; docstring for which says it's deprecated, and to use projectile-mode instead.
;; https://github.com/bbatsov/projectile/issues/496
;;
;; "Yes, this variable is initialized when projectile-mode gets
;; started - otherwise it will be nil (the root of your problem). I
;; didn't imagine anyone would be using projectile without
;; projectile-mode, so I guess there's some room for improvement."
;; - bbatsov, writer of projectile-mode

(projectile-mode)

;; can confirm this works.  August 23, 2022

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
;;; x-hugh-projectile.el ends here
