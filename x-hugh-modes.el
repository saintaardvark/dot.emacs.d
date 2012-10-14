;; Modes/requires.
;; Required packages and their settings.

;; Use post for Mutt.
(require 'post nil 'noerror)
(add-to-list 'auto-mode-alist '("mutt.*$" . post-mode))

;; Use scp for tramp.
(require 'tramp nil 'noerror)
(setq tramp-default-method "scp")

;; Load ssh.
(require 'ssh nil 'noerror)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Random
(require 'erc		nil 'noerror)
(require 'uniquify	nil 'noerror)
(require 'xclip		nil 'noerror)
(require 'filladapt	nil 'noerror)
(require 'linum		nil 'noerror)
(require 'midnight	nil 'noerror)
(iswitchb-mode 1)

; Not sure how handy this is going to be...
(autoload 'map-lines "map-lines"
           "Map COMMAND over lines matching REGEX."
           t)

;; Magit ROX.
;; FIXME: Move magit to modes.
(setq load-path  (cons (expand-file-name "~/.emacs.d/magit/") load-path))
(require 'magit nil 'noerror)

(add-hook 'twiki-org-load-hook (longlines-mode))

;; Perl
(require 'perldoc nil 'noerror)
(defalias 'perl-mode 'cperl-mode)
(require 'perltidy nil 'noerror)

(require 'browse-kill-ring nil 'noerror)

;; Workgroups.
;; FIXME: Move to modes/submodule
(add-to-list 'load-path "~/src/workgroups.el/")
;; (add-to-list 'load-path "~/.emacs.d/workgroups/")
(require 'workgroups)
(setq wg-prefix-key (kbd "C-c w"))
(workgroups-mode 1)
;(wg-load "~/.emacs.d/saved_workgroups")


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
;; LongLines mode: http://www.emacswiki.org/emacs-en/LongLines
;;

(autoload 'longlines-mode "longlines" "LongLines Mode." t)

(eval-after-load "longlines"
  '(progn
     (defvar longlines-mode-was-active nil)
     (make-variable-buffer-local 'longlines-mode-was-active)

     (defun longlines-suspend ()
       (if longlines-mode
           (progn
             (setq longlines-mode-was-active t)
             (longlines-mode 0))))

     (defun longlines-restore ()
       (if longlines-mode-was-active
           (progn
             (setq longlines-mode-was-active nil)
             (longlines-mode 1))))

     ;; longlines doesn't play well with ediff, so suspend it during diffs
     (defadvice ediff-make-temp-file (before make-temp-file-suspend-ll
                                             activate compile preactivate)
       "Suspend longlines when running ediff."
       (with-current-buffer (ad-get-arg 0)
         (longlines-suspend)))


     (add-hook 'ediff-cleanup-hook
               '(lambda ()
                  (dolist (tmp-buf (list ediff-buffer-A
                                         ediff-buffer-B
                                         ediff-buffer-C))
                    (if (buffer-live-p tmp-buf)
                        (with-current-buffer tmp-buf
                          (longlines-restore))))))))


;; tidy up diffs when closing the file
(defun kill-associated-diff-buf ()
  (let ((buf (get-buffer (concat "*Assoc file diff: "
                             (buffer-name)
                             "*"))))
    (when (bufferp buf)
      (kill-buffer buf))))

(add-hook 'kill-buffer-hook 'kill-associated-diff-buf)


(setq w3m-p (executable-find "w3m"))
(if w3m-p
    (require 'w3m-load) nil 'noerror)

;; FIXME: Move to modes.
(setq load-path (cons "~/.emacs.d/twittering-mode" load-path))
(require 'twittering-mode)

;; RT Liberation

;; (add-to-list 'load-path "/home/hugh/src/rt-liberation/")
;; (require 'rt-liberation nil 'noerror)
;; (require 'rt-liberation-gnus)
;; (setq rt-liber-rt-binary "/usr/bin/rt")
;; (setq rt-liber-rt-version "3.6.5")
;; (setq rt-liber-gnus-comment-address "rt-comment@rt.chibi.ubc.ca"
;;       rt-liber-gnus-address         "rt@chibi.ubc.ca"
;;       rt-liber-gnus-subject-name    "rt.chibi.ubc.ca"
;;       rt-liber-user-name	    "hugh"
;;       rt-liber-gnus-answer-headers  '(("Gcc" . "nnml:Send-Mail")
;; 				      ("X-Ethics" . "Use GNU"))
;;       rt-liber-gnus-signature       "Thanks,Hugh")

;; (setq user-mail-address "hbrown@chibi.ubc.ca")

(provide 'x-hugh-modes)
