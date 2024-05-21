;; x-hugh-org -- org settings

;;; Commentary:
;;; I (heart) org-mode.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-mode settings.

(defgroup x-hugh-org nil
  "Settings for working with org."
  :group 'tools)

(defcustom x-hugh-org/journal-file "~/orgmode/journal.org"
  "Where to store journal file."
  :type 'string
  :group 'x-hugh-org)

(defcustom x-hugh-org/misc-file "~/orgmode/misc.org"
  "Where to store misc notes."
  :type 'string
  :group 'x-hugh-org)

(defcustom x-hugh-org/fun-project-file "~/orgmode/fun_projects/fun_projects.org"
  "Where to store fun projects."
  :type 'string
  :group 'x-hugh-org)

(defcustom x-hugh-org/reading-file "~/orgmode/reading.org"
  "Where to store reading prompts."
  :type 'string
  :group 'x-hugh-org)

;; FIXME: This hook is not working yet.
;; https://www.reddit.com/r/orgmode/comments/6n7dk7/q_refreshing_agenda_after_capturing_a_task/dk91lbk/
(defun nebucatnetzer:org-agenda-redo ()
  "Refresh the org agenda if the buffer for it exists."
  (interactive)
  (when (get-buffer "*Org Agenda*")
    (with-current-buffer "*Org Agenda*"
      (org-agenda-maybe-redo)
      (message "[org agenda] refreshed!"))))

;; Needed before use-package org.
(use-package f
  :ensure t)

(use-package org
  ;; FIXME: getting an error with this next bit; not sure what i'm doing wrong
  ;; :mode ("\\.org$" . org-mode)
  :custom ((org-log-done t)
           (org-agenda-columns-add-appointments-to-effort-sum t)
	   (org-agenda-files (f-files "~/orgmode"
				      (lambda (f)
					;; (string= (f-ext f) "org"))
					;; Ref: https://github.com/rejeep/f.el#f-filename
					;; While I'm getting things sorted out
				      (string= (f-filename f) "dad.org"))
				      'recursive))
           (org-agenda-log-mode-items (quote (clock)))
           (org-agenda-restore-windows-after-quit t)
           (org-agenda-skip-scheduled-if-done t)
           (org-agenda-span (quote day))
           (org-agenda-start-with-clockreport-mode t)
           (org-agenda-start-with-follow-mode t)
           (org-agenda-start-with-log-mode t)
	   (org-agenda-skip-entry-if 'todo '("Reference"))
           (org-capture-templates
            (quote
             (("l" "Log" item
               (file+olp+datetree x-hugh-org/journal-file))
              ("t" "TODO" entry
               ;; (file x-hugh-org/misc-file)
	       ;; Sigh...put everything in Dad file for now.
               (file "~/orgmode/dad.org")
               "** TODO [#A] %?")
              ("d" "Dad TODO" entry
               (file "~/orgmode/dad.org")
               "* TODO [#B] %?")
              ("q" "Question" entry
               (file x-hugh-org/misc-file)
               "** Question [#A] %?")
              ("f" "Fun project" entry
               (file x-hugh-org/fun-project-file)
               "** Fun project: %?")
              ("r" "Reading" entry
               (file x-hugh-org/reading-file)
               "** Reading [#A] %?")
	      )))
           (org-clock-continuously nil)
           (org-clock-into-drawer t)
           (org-default-notes-file x-hugh-org/misc-file)
           (org-default-priority 65)
           (org-duration-format (quote h:mm))
	   (org-hide-emphasis-markers t)
           (org-log-done (quote time))
           (org-log-into-drawer t)
           (org-modules
            (quote
             (org-bbdb org-bibtex org-docview org-gnus org-habit org-info org-irc org-mhe org-rmail org-w3m)))
	   (org-refile-targets '((org-agenda-files :maxlevel . 3)))
	   (org-startup-indented t)
           (org-stuck-projects
            (quote
             ("+PROJECT/-MAYBE-DONE"
              ("TODO" "NBIJ" "Waiting" "NEXT" "NEXTACTION")
              nil ""))))
  ;; Prevents org-mode grabbing C-'
  ;; https://superuser.com/questions/828713/how-to-override-a-keybinding-in-emacs-org-mode
  :bind (:map org-mode-map ("C-'" . nil))
  :hook (('org-capture-after-finalize-hook 'nebucatnetzer:org-agenda-redo)
	 ('org-capture-mode-hook 'x-hugh-indent-buffer)
	 ('org-mode-hook 'org-indent-mode))
  )

;; The settings in this section come from
;; https://zzamboni.org/post/beautifying-org-mode-in-emacs/.  Trying
;; them out to see how they look.
;;
;; BEGIN ZZAMBONI

(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(let* ((variable-tuple
        (cond ((x-list-fonts "Ubuntu")         '(:font "Ubuntu"))
              ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
              ((x-list-fonts "Open Sans")       '(:Font "Open Sans"))
              ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
              ((x-list-fonts "Verdana")         '(:font "Verdana"))
              ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
              (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
       (base-font-color     (face-foreground 'default nil 'default))
       (headline           `(:inherit default :weight bold :foreground ,base-font-color)))

  (custom-theme-set-faces
   'user
   `(org-level-8 ((t (,@headline ,@variable-tuple))))
   `(org-level-7 ((t (,@headline ,@variable-tuple))))
   `(org-level-6 ((t (,@headline ,@variable-tuple))))
   `(org-level-5 ((t (,@headline ,@variable-tuple))))
   `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
   `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.25))))
   `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.5))))
   `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.75))))
   `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))))

;; END ZZAMBONI

(use-package ox-gfm
  :ensure t)

(use-package ox-slack
  :ensure t)

(use-package ox-twbs
  :ensure t)

;; Needed for some HTML exports
(use-package htmlize
  :ensure t)

(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(global-set-key (kbd "C-M-r") 'org-capture)
(global-set-key (kbd "<f12>") 'org-agenda)

;; Enable this if I start using Org mode to schedule things again.
;; (add-hook 'org-after-todo-state-change-hook
;; 	  'x-hugh-org-schedule-todo-item)

(defun x-hugh-get-current-log-file()
  "Return the name of the current orgmode log file."
  (interactive)
  ;; FIXME: Placeholder.
  ;; FIXME: Calculate year
  ;; FIXMEEEE: Have fixmee-mode turned on by default
  ;; FIXMEEEE: Set fixmee mode to use another key prifix
  "/Users/hubrown/orgmode/log_2018.org")

(defun x-hugh-org-schedule-todo-item ()
  "Prompt for date to actually do something marked TODO."
  (when (string= org-state "TODO")
    (org-schedule 1)))

;; (setq org-agenda-custom-commands
;;       '(
;; 	("P" "Done last year" ((tags "CLOSED<=\"<2014-01-01>\"")))
;; 	("p" "My custom agenda"
;; 	 ((org-agenda-list nil nil 1)
;; ;;;	  (todo "TODO")
;; 	  (stuck "")
;; 	  (todo "Waiting"
;; 		((org-agenda-overriding-header "\Waiting:\n--------\n")))
;; 	  (todo "NBIJ"
;; 		((org-agenda-overriding-header "\Next beer in Jerusalem:\n-----------------------\n")))
;; 	  (search "TODO -{SCHEDULED}"
;; 		((org-agenda-overriding-header "Not scheduled:\n")))))))

(defun org-column-view-uses-fixed-width-face ()
  ;; copy from org-faces.el
  (when (fboundp 'set-face-attribute)
    ;; Make sure that a fixed-width face is used when we have a column
    ;; table.
    (set-face-attribute 'org-column nil
                        :height (face-attribute 'default :height)
                        :family (face-attribute 'default :family))))

(when (and (fboundp 'daemonp) (daemonp))
  (add-hook 'org-mode-hook 'org-column-view-uses-fixed-width-face))

;; (org-babel-do-load-languages
;;  'org-babel-load-languages
;;   '( (perl . t)
;;      (ruby . t)
;;      (sh . t)
;;      (python . t)
;;      (emacs-lisp . t)
;;    ))

;; https://stackoverflow.com/questions/14193975/strike-through-headlines-for-done-tasks-in-org
(setq org-fontify-done-headline t)
(custom-set-faces
 '(org-done ((t (:foreground "PaleGreen"
                             :weight normal
                             :strike-through t))))
 '(org-headline-done
   ((((class color) (min-colors 16) (background dark))
     (:foreground "LightSalmon" :strike-through t)))))

(defun x-hugh-org-clock-in-starting-now-dammit ()
  "Clock in with starting time of right now, no matter what org-clock-continuously says."
  (interactive)
  (let ((org-clock-continuously nil))
    ;; if buffer Agenda, then org-agenda-clock-in.
    (if (string= (buffer-name) "*Org Agenda*")
	(org-agenda-clock-in)
      (org-clock-in))))

(defun x-hugh-org-daily-report ()
  "ZOMG shoulda done this long ago!  FIXME: Not done yet; some
pseudocode in here.  Meant to leave the report to be yanked, but
probably simpler just to insert at point wherever you are."
  (interactive)
  (insert-string "Hi Paul -- here's what I've worked on today.  Let me know if you have any questions.

Thanks,
Hugh

")
  (save-excursion
    (goto-char (point-min))
    (search-forward "Subject:")
    (insert-string (format " Activity report -- %s" (format-time-string "%A %B %d, %Y"))))
  (save-excursion
    (org-clock-report)
    (search-forward ":scope file")
    (backward-kill-word 1)
    (insert-string "agenda")
    (insert-string " :block today")
    (insert-string " :narrow 60!")
    (org-dblock-update)
    (goto-char (point-min))
    (search-forward "#+BEGIN")
    (let ((beg (line-beginning-position)))
      (forward-line 2)
      (delete-region beg (point)))
    (search-forward "#+END")
    (let ((beg (line-beginning-position)))
      (forward-line 1)
      (delete-region beg (point)))))

(defun x-hugh-org-yearly-report ()
  "Yearly report.  FIXME: Not done yet."
  (interactive)
  (let ((org-time-clocksum-format "%d:%02d"))
    (org-clock-report)
    (search-forward ":scope file")
    (backward-kill-word 1)
    (insert-string "agenda")
    (insert-string " :block 2014 :narrow 60!")
    (org-dblock-update)))

(defun x-hugh-org-new-day-in-notes ()
  "Start a new day in a notes file."
  (interactive)
  (goto-char (point-max))
  (org-insert-heading)
  (let ((current-prefix-arg '(16)))
    (call-interactively 'org-time-stamp-inactive))
  (align-newline-and-indent)
  (insert "- "))

(defun x-hugh-org-publish-books-org ()
  "Publish books.org as HTML on website."
  (interactive)
  (save-excursion
    ;; renamed to "books.org.txt" in order to keep entries from
    ;; showing up in the agenda view.
    (find-file "/home/aardvark/orgmode/books.org.txt")
    (org-html-export-as-html)
    (write-region nil nil "/ssh:l2:/home/aardvark/public_html/random/books.html")
    (kill-buffer)))

(defun x-hugh-org-publish-fun-projects ()
  "Publish fun_projects.org as HTML on website."
  (interactive)
  (save-excursion
    (find-file "/home/aardvark/orgmode/fun_projects/fun_projects.org")
    (org-html-export-as-html)
    (write-region nil nil "/ssh:l2:/home/aardvark/public_html/random/fun_projects.html")
    (kill-buffer)))

(defun x-hugh-org-export-password-file ()
  "Export the password file in HTML to /dev/shm."
  (interactive)
  (save-excursion
    (org-html-export-as-html)
    (write-region nil nil "/dev/shm/passwords.html")
    ;; Optionally: could do something like:
    ;; (let (printer-name "ML-1750")
    ;;   (print-buffer))
    ;; Note: not yet working.
    (kill-buffer)))

;; Hm, does not work yet: leaves me in capture template with nothing
;; filled in.
(defun x-hugh-org-log-headline-in-journal ()
  "Log text of current headline in journal."
  (interactive)
  (save-excursion
    (let ((entry (org-entry-get nil "ITEM")))
      (org-capture-string "hello world" "l")
      (message (format "Logged entry: %s" entry)))))

;; FIXME: Hm, not working as expected.
(defun x-hugh-org-toggle-heading-save-excursion ()
  "Wrap org-toggle-heading with save-excursion."
  (interactive)
  (org-toggle-heading)
  (move-end-of-line nil))

(provide 'x-hugh-org)
;;; x-hugh-org.el ends here
