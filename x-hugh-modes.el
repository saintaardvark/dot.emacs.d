;; x-hugh-modes --- Modes/requires.

;;; Commentary:
;; Required packages and their settings.

;;; Code:

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
(add-hook 'post-mode '(lambda () (abbrev-mode 1)))


;; Use scp for tramp.
(require 'tramp nil 'noerror)
(setq tramp-default-method "scp")

;; Load ssh.
(require 'ssh nil 'noerror)

;; Shell script stuff
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Random
(require 'erc		nil 'noerror)
(require 'uniquify	nil 'noerror)
(require 'xclip		nil 'noerror)
(require 'filladapt	nil 'noerror)
(require 'linum		nil 'noerror)
(require 'midnight	nil 'noerror)

;; Markdown 
(require 'markdown-mode	nil 'noerror)
(add-to-list 'auto-mode-alist '(".*md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.mdwn\\'" . markdown-mode))


; Not sure how handy this is going to be...
(autoload 'map-lines "map-lines"
           "Map COMMAND over lines matching REGEX."
           t)

;; Perl
(require 'perldoc nil 'noerror)
(defalias 'perl-mode 'cperl-mode)
(require 'perltidy nil 'noerror)
;; 8 spaces for tab, the way God intended
;;(setq perl-indent-level 8)

;; Text mode
(add-hook 'text-mode-hook '(lambda () (auto-fill-mode 1)))
(add-hook 'text-mode-hook '(lambda () (abbrev-mode 1)))
(add-hook 'text-mode-hook '(lambda () (flyspell-mode 1)))

;; Diff mode
(add-hook 'diff-mode 'font-lock-mode)


(require 'browse-kill-ring nil 'noerror)

;;
;; Apache mode.
;;

(autoload 'apache-mode "apache-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.htaccess\\'"   . apache-mode))
(add-to-list 'auto-mode-alist '("httpd\\.conf\\'"  . apache-mode))
(add-to-list 'auto-mode-alist '("srm\\.conf\\'"    . apache-mode))
(add-to-list 'auto-mode-alist '("access\\.conf\\'" . apache-mode))
(add-to-list 'auto-mode-alist '("sites-\\(available\\|enabled\\)/" . apache-mode))


;; Longlines mode
(autoload 'visual-line-mode "visual-line" "Visual line mode." t)

(defun kill-associated-diff-buf ()
  "Tidy up diffs when closing the file."
  (let ((buf (get-buffer (concat "*Assoc file diff: "
                             (buffer-name)
                             "*"))))
    (when (bufferp buf)
      (kill-buffer buf))))

(add-hook 'kill-buffer-hook 'kill-associated-diff-buf)


;; RT Liberation

;; (add-to-list 'load-path "~/.emacs.d/rt-liberation/")
;; (require 'rt-liberation nil 'noerror)
;; (require 'rt-liberation-gnus nil 'noerror)
;; (setq rt-liber-rt-binary "/usr/bin/rt")
;; (setq rt-liber-rt-version "3.8.11")
;; (setq rt-liber-gnus-comment-address "rt-comment@rt.chibi.ubc.ca"
;;       rt-liber-gnus-address         "rt@chibi.ubc.ca"
;;       rt-liber-gnus-subject-name    "rt.chibi.ubc.ca"
;;       rt-liber-user-name	    "hugh"
;;       rt-liber-gnus-answer-headers  '(("Gcc" . "nnml:Send-Mail")
;; 				      ("X-Ethics" . "Use GNU"))
;;       rt-liber-gnus-signature       "Thanks,Hugh")

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

(require 'yasnippet nil 'noerror)

;; For ANSI colourization in compilation buffers.
;; https://stackoverflow.com/questions/13397737/ansi-coloring-in-compilation-mode/20788581#20788581
(ignore-errors
  (require 'ansi-color)
  (defun my-colorize-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))

;; Man, I always forget about winner-mode...
(winner-mode 1)

;; jinja
(add-to-list 'auto-mode-alist '("\\.j2\\'"   . jinja2-mode))

;; Noice!
;; https://emacs.stackexchange.com/questions/202/close-all-dired-buffers
(setq-default ibuffer-saved-filter-groups
              `(("Default"
                 ;; I create a group call Dired, which contains all buffer in dired-mode
                 ("Dired" (mode . dired-mode))
                 ("Temporary" (name . "\*.*\*"))
                 )))

(add-hook 'ibuffer-mode-hook #'(ibuffer-switch-to-saved-filter-groups "Default"))

(provide 'x-hugh-modes)
;;; x-hugh-modes ends here
