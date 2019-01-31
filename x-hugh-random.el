;;; x-hugh-random --- where I keep random things.

;;; Commentary:
;;; I really should sort all this out better.

;;; Code:

;; Random settings.

;; FIXME: Organize a bit
;; - setq in one region, alphebetized

;; Variables:

;; FIXME: Pick between these two backup schemes
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/")))
;; Save all tempfiles in $TMPDIR/emacs$UID/
;; See https://www.emacswiki.org/emacs/AutoSave
(defconst emacs-tmp-dir (format "%s/%s%s/" temporary-file-directory "emacs" (user-uid)))
(setq backup-directory-alist
      `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,emacs-tmp-dir t)))
(setq auto-save-list-file-prefix
      emacs-tmp-dir)

;; Now the rest in alphabetical order
(setq c-basic-offset 8)
(setq calendar-offset 0)
(setq case-fold-search t)
(setq ediff-mergel-split-window-function 'split-window-horizontally)
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq epg-gpg-program (executable-find "gpg"))
(setq find-grep-options "-qi")
(setq global-flycheck-mode nil)
(setq global-font-lock-mode t)
(setq indent-tabs-mode nil)
(setq iswitchb-prompt-newbuffer nil)
(setq kill-read-only-ok t)
(setq js-indent-level 2)
(setq require-final-newline t)
(setq safe-local-variable-values
      '((eval add-hook 'before-save-hook
              (lambda nil
		(delete-trailing-whitespace)
		nil))
	(mangle-whitespace . t)
	(rm-trailing-spaces . t)))

;; From http://www.emacswiki.org/emacs/CopyAndPaste
(setq select-active-regions t) ;  active region sets primary X11 selection
(setq select-enable-clipboard t)
(setq send-mail-function 'sendmail-send-it)
(setq c-basic-offset 8)
(setq standard-indent 8)
(setq user-mail-address "aardvark@saintaardvarkthecarpeted.com")

(put 'narrow-to-region 'disabled nil)
(fset 'yes-or-no-p 'y-or-n-p) ; enable one letter y/n answers to yes/no

;; Sigh...causing too many problems with git repo
;; (add-hook 'write-file-hooks 'delete-trailing-whitespace)

(use-package comint
  :custom (comint-password-prompt-regexp
           "\\(^ *\\|\\( SMB\\|'s\\|Bad\\|CVS\\|Enter\\(?: \\(?:\\(?:sam\\|th\\)e\\)\\)?\\|Kerberos\\|LDAP\\|New\\|Old\\|Repeat\\|SUDO\\|UNIX\\|Vault\\|\\[sudo]\\|enter\\(?: \\(?:\\(?:sam\\|th\\)e\\)\\)?\\|login\\|new\\|old\\) +\\)\\(?:\\(?:adgangskode\\|contrase\\(?:\\(?:ny\\|ñ\\)a\\)\\|geslo\\|h\\(?:\\(?:asł\\|esl\\)o\\)\\|iphasiwedi\\|jelszó\\|l\\(?:ozinka\\|ösenord\\)\\|m\\(?:ot de passe\\|ật khẩu\\)\\|pa\\(?:rola\\|s\\(?:ahitza\\|s\\(?: phrase\\|code\\|ord\\|phrase\\|wor[dt]\\)\\|vorto\\)\\)\\|s\\(?:alasana\\|enha\\|laptažodis\\)\\|wachtwoord\\|лозинка\\|пароль\\|ססמה\\|كلمة السر\\|गुप्तशब्द\\|शब्दकूट\\|গুপ্তশব্দ\\|পাসওয়ার্ড\\|ਪਾਸਵਰਡ\\|પાસવર્ડ\\|ପ୍ରବେଶ ସଙ୍କେତ\\|கடவுச்சொல்\\|సంకేతపదము\\|ಗುಪ್ತಪದ\\|അടയാളവാക്ക്\\|රහස්පදය\\|ពាក្យសម្ងាត់\\|パスワード\\|密[码碼]\\|암호\\)\\|Response\\)\\(?:\\(?:, try\\)? *again\\| (empty for no passphrase)\\| (again)\\)?\\(?: for [^:：៖]+\\)?[:：៖]\\s *\\'")
  :config (add-hook 'comint-output-filter-functions
                    'comint-watch-for-password-prompt))

;; From http://pragmaticemacs.com/emacs/dont-kill-buffer-kill-this-buffer-instead/
(defun jcs-kill-a-buffer (askp)
  "Just kill this damn buffer! If ASKP provided, ask which buffer to kill."
  (interactive "P")
  (if askp
      (kill-buffer (funcall completing-read-function
                            "Kill buffer: "
                            (mapcar #'buffer-name (buffer-list))))
    (kill-this-buffer)))

;; Chrome extension for editing stuff in Emacs
(use-package edit-server
  :custom (edit-server-new-frame nil)
  :config (edit-server-start))

(defun kill-associated-diff-buf ()
  "Tidy up diffs when closing the file."
  (let ((buf (get-buffer
              (concat "*Assoc file diff: " (buffer-name)
                      "*"))))
    (when (bufferp buf)
      (kill-buffer buf))))

(add-hook 'kill-buffer-hook 'kill-associated-diff-buf)

(provide 'x-hugh-random)

;;; x-hugh-random ends here
