;; Modes/requires.
;; Required packages and their settings.

;; Use post for Mutt.
(require 'post nil 'noerror)
;; Tell it manually to just use goddamn server-edit, not
;; save-buffers-kill-emacs.

;; If you look at where post-finish gets defined, it's looking to see
;; if server-edit is fboundp to anything; if not, it falls through to
;; save-buffers-kill-emacs.  However, I think what's happening is that
;; server-edit is not bound to anything until after post is loaded --
;; which is seriously fucking with my use of Mutt and having an Emacs
;; daemon hanging around all the time.  This is new behaviour as of
;; 24.2; not sure what is different.  This is ugly but it works.

(fset 'post-finish 'server-edit)

(add-to-list 'auto-mode-alist '("mutt.*$" . post-mode))

;; Use scp for tramp.
(require 'tramp nil 'noerror)
(setq tramp-default-method "scp")

;; Load ssh.
(require 'ssh nil 'noerror)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Random
;; (require 'erc		nil 'noerror)
(require 'uniquify	nil 'noerror)
(require 'xclip		nil 'noerror)
(require 'filladapt	nil 'noerror)
(require 'linum		nil 'noerror)
(require 'midnight	nil 'noerror)
(require 'markdown-mode	nil 'noerror)
(add-to-list 'auto-mode-alist '(".*md$" . markdown-mode))
;; (iswitchb-mode 1)
(when (not (string= system-name "herobrine.saintaardvarkthecarpeted.com"))
  (progn
    (require 'helm-config nil 'noerror)
    (helm-mode 1)
    ;; (global-set-key (kbd "M-x")     'helm-M-x)
    (global-set-key (kbd "M-y")     'helm-show-kill-ring)
    (global-set-key (kbd "C-x b")   'helm-mini)
    (global-set-key (kbd "C-x C-f") 'helm-find-files)))


; Not sure how handy this is going to be...
(autoload 'map-lines "map-lines"
           "Map COMMAND over lines matching REGEX."
           t)

;; Magit ROX.
;; We need cl-lib if less than 24.  This check taken from post.el.
(if (< (string-to-number (substring (emacs-version)
				    (string-match "[0-9]+\.[0-9]"
						  (emacs-version) 5))) 24)
    (load-file "~/.emacs.d/cl-lib-0.3.el"))
(setq load-path  (cons (expand-file-name "~/.emacs.d/git-modes/") load-path))
(require 'git-commit-mode nil 'noerror)
(setq load-path  (cons (expand-file-name "~/.emacs.d/magit/") load-path))
(require 'magit nil 'noerror)

(require 'markdown-mode nil 'noerror)

;(add-hook 'twiki-org-load-hook (longlines-mode))

;; Perl
(require 'perldoc nil 'noerror)
(defalias 'perl-mode 'cperl-mode)
(require 'perltidy nil 'noerror)

(require 'browse-kill-ring nil 'noerror)

;; Workgroups.
(require 'workgroups2)
;; Can't move this to keymap; needed before workgroups-mode is loaded.
(setq wg-prefix-key (kbd "C-c w"))
(global-set-key (kbd "C-c w s") 'wg-save-session)
(workgroups-mode 1)
(wg-reload-session)

(defun x-hugh-wg-show-workgroups ()
  "Display workgroups."
  (interactive)
  (wg-fontified-message
    (wg-workgroup-list-display)))

(defadvice
  wg-switch-to-workgroup-right (after x-hugh-advice-wgshow-workgroups)
  "Display workgroups after switching."
  (x-hugh-wg-show-workgroups))

(defadvice
  wg-switch-to-workgroup-at-index (after x-hugh-advice-wgshow-workgroups)
  "Display workgroups after switching."
  (x-hugh-wg-show-workgroups))

(defadvice
  wg-switch-to-workgroup-left (after x-hugh-advice-wgshow-workgroups)
  "Display workgroups after switching."
  (x-hugh-wg-show-workgroups))

(ad-activate 'wg-switch-to-workgroup-right)
(ad-activate 'wg-switch-to-workgroup-left)
(ad-activate 'wg-switch-to-workgroup-at-index)
;;
;; Apache mode.
;;

(autoload 'apache-mode "apache-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.htaccess\\'"   . apache-mode))
(add-to-list 'auto-mode-alist '("httpd\\.conf\\'"  . apache-mode))
(add-to-list 'auto-mode-alist '("srm\\.conf\\'"    . apache-mode))
(add-to-list 'auto-mode-alist '("access\\.conf\\'" . apache-mode))
(add-to-list 'auto-mode-alist '("sites-\\(available\\|enabled\\)/" . apache-mode))

;;
;; LongLines mode: http://www.emacswiki.org/emacs-en/LongLines.
;; Note: Replaced by visual-line-mode
;; (https://github.com/djcb/mu/issues/116). Not sure how the hook will
;; work.
;;

;; (autoload 'longlines-mode "longlines" "LongLines Mode." t)
(autoload 'visual-line-mode "visual-line" "Visual line mode." t)

;; (eval-after-load "longlines"
;;   '(progn
;;      (defvar longlines-mode-was-active nil)
;;      (make-variable-buffer-local 'longlines-mode-was-active)

;;      (defun longlines-suspend ()
;;        (if longlines-mode
;;            (progn
;;              (setq longlines-mode-was-active t)
;;              (longlines-mode 0))))

;;      (defun longlines-restore ()
;;        (if longlines-mode-was-active
;;            (progn
;;              (setq longlines-mode-was-active nil)
;;              (longlines-mode 1))))

;;      ;; longlines doesn't play well with ediff, so suspend it during diffs
;;      (defadvice ediff-make-temp-file (before make-temp-file-suspend-ll
;;                                              activate compile preactivate)
;;        "Suspend longlines when running ediff."
;;        (with-current-buffer (ad-get-arg 0)
;;          (longlines-suspend)))


;;      (add-hook 'ediff-cleanup-hook
;;                '(lambda ()
;;                   (dolist (tmp-buf (list ediff-buffer-A
;;                                          ediff-buffer-B
;;                                          ediff-buffer-C))
;;                     (if (buffer-live-p tmp-buf)
;;                         (with-current-buffer tmp-buf
;;                           (longlines-restore))))))))


;; tidy up diffs when closing the file
(defun kill-associated-diff-buf ()
  (let ((buf (get-buffer (concat "*Assoc file diff: "
                             (buffer-name)
                             "*"))))
    (when (bufferp buf)
      (kill-buffer buf))))

(add-hook 'kill-buffer-hook 'kill-associated-diff-buf)


;; (setq w3m-p (executable-find "w3m"))
;; (if w3m-p
;;     (require 'w3m-load) nil 'noerror)


;; RT Liberation

(add-to-list 'load-path "~/.emacs.d/rt-liberation/")
(require 'rt-liberation nil 'noerror)
(require 'rt-liberation-gnus nil 'noerror)
(setq rt-liber-rt-binary "/usr/bin/rt")
(setq rt-liber-rt-version "3.8.11")
(setq rt-liber-gnus-comment-address "rt-comment@rt.chibi.ubc.ca"
      rt-liber-gnus-address         "rt@chibi.ubc.ca"
      rt-liber-gnus-subject-name    "rt.chibi.ubc.ca"
      rt-liber-user-name	    "hugh"
      rt-liber-gnus-answer-headers  '(("Gcc" . "nnml:Send-Mail")
				      ("X-Ethics" . "Use GNU"))
      rt-liber-gnus-signature       "Thanks,Hugh")


;; Cfengine mode comes w/Emacs 24.
(add-to-list 'auto-mode-alist '("\\.cf\\'" . cfengine3-mode))

(require 'boxquote)
(defun x-hugh-boxquote-yank-and-indent ()
  "My attempt to combine boxquote-yank and indent.

The car/cdr bits are from the docstring for boxquote-points.  It's a bit silly to run it twice, but it was simple."
  (interactive)
  (save-excursion
    (if (region-active-p)
	(boxquote-region (region-beginning) (region-end))
      (boxquote-yank))
    (forward-line)
    ;; boxquote-points gives you the first point of the boxquote
    ;; formatting, and the last line of the stuff being quoted.  We
    ;; have to add six to get the *end* of the boxquote formatting.
    (indent-region (car (boxquote-points)) (+ 6 (cdr (boxquote-points))))))

;; Sigh...it's fun, but it takes up a lot of real estate.
;; ;; Because it's fun.
;; (require 'nyan-mode)
;; ;; And now turn it on.
;; (nyan-mode)

;; Flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

;; Smart-mode line
;; (require 'smart-mode-line)
;; (sml/setup)

;; Try creating my own mode for .cfg files.
;; What I want right now: handiness of commenting in Nagios config files, but no
;; complaints from flycheck about syntax errors.
;; More generally, there's probably a Nagios mode I should be using...
(define-derived-mode x-hugh-cfg-mode sh-mode "My Cfg mode"
  "A mode for Cfg files."
  (sh-set-shell "bash"))
(add-to-list 'auto-mode-alist '("\\.cfg\\'" . x-hugh-cfg-mode))

(require 'yasnippet nil 'noerror)
(provide 'x-hugh-modes)
;;; x-hugh-modes ends here
