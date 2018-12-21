;;; x-hugh-custom --- My custom file.

;;; Commentary:
;; flycheck, get off my back.

;;; Code:

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Man-notify-method (quote bully))
 '(backup-directory-alist (quote (("." . "~/.emacs.d/backups/"))))
 '(battery-mode-line-format "[Battery time: %t]")
 '(c-basic-offset 8)
 '(calendar-offset 0)
 '(case-fold-search t)
 '(cfg-chef-cookbook-directory "/Users/hubrown/gh/Chef")
 '(coffee-tab-width 2)
 '(comint-password-prompt-regexp
   "\\(^ *\\|\\( SMB\\|'s\\|Bad\\|CVS\\|Enter\\(?: \\(?:\\(?:sam\\|th\\)e\\)\\)?\\|Kerberos\\|LDAP\\|New\\|Old\\|Repeat\\|SUDO\\|UNIX\\|Vault\\|\\[sudo]\\|enter\\(?: \\(?:\\(?:sam\\|th\\)e\\)\\)?\\|login\\|new\\|old\\) +\\)\\(?:\\(?:adgangskode\\|contrase\\(?:\\(?:ny\\|ñ\\)a\\)\\|geslo\\|h\\(?:\\(?:asł\\|esl\\)o\\)\\|iphasiwedi\\|jelszó\\|l\\(?:ozinka\\|ösenord\\)\\|m\\(?:ot de passe\\|ật khẩu\\)\\|pa\\(?:rola\\|s\\(?:ahitza\\|s\\(?: phrase\\|code\\|ord\\|phrase\\|wor[dt]\\)\\|vorto\\)\\)\\|s\\(?:alasana\\|enha\\|laptažodis\\)\\|wachtwoord\\|лозинка\\|пароль\\|ססמה\\|كلمة السر\\|गुप्तशब्द\\|शब्दकूट\\|গুপ্তশব্দ\\|পাসওয়ার্ড\\|ਪਾਸਵਰਡ\\|પાસવર્ડ\\|ପ୍ରବେଶ ସଙ୍କେତ\\|கடவுச்சொல்\\|సంకేతపదము\\|ಗುಪ್ತಪದ\\|അടയാളവാക്ക്\\|රහස්පදය\\|ពាក្យសម្ងាត់\\|パスワード\\|密[码碼]\\|암호\\)\\|Response\\)\\(?:\\(?:, try\\)? *again\\| (empty for no passphrase)\\| (again)\\)?\\(?: for [^:：៖]+\\)?[:：៖]\\s *\\'")
 ;; ARGHH: This ends up turning off auto-fill-mode in Emacs.  (tableflip)
 ;; '(comment-auto-fill-only-comments t)
 '(compilation-scroll-output (quote first-error))
 '(cperl-indent-level 8)
 '(current-language-environment "English")
 '(custom-enabled-themes (quote (solarized-dark)))
 '(custom-safe-themes
   (quote
    ("a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "e16a771a13a202ee6e276d06098bc77f008b73bbac4d526f160faa2d76c1dd0e" "6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" default)))
 '(delete-selection-mode nil)
 '(dired-dwim-target t)
 '(dired-recursive-copies (quote always))
 '(dired-recursive-deletes (quote top))
 '(display-battery-mode nil)
 '(ediff-merge-split-window-function (quote split-window-horizontally))
 '(ediff-split-window-function (quote split-window-horizontally))
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(elpy-modules
   (quote
    (elpy-module-company elpy-module-eldoc elpy-module-pyvenv elpy-module-yasnippet elpy-module-sane-defaults)))
 '(eshell-visual-commands
   (quote
    ("vi" "screen" "top" "less" "more" "lynx" "ncftp" "pine" "tin" "trn" "elm" "ssh")))
 '(explicit-shell-file-name "/bin/bash")
 '(find-grep-options "-qi")
 '(flyspell-auto-correct-binding [67108904])
 '(git-commit-summary-max-length 90)
 '(global-flycheck-mode nil)
 '(global-font-lock-mode t nil (font-lock))
 '(indent-tabs-mode nil)
 '(iswitchb-prompt-newbuffer nil)
 '(js-indent-level 2)
 '(kill-read-only-ok t)
 '(magithub-enabled-by-default nil)
 '(mouse-wheel-mode nil)
 '(mouse-yank-at-point t)
 '(ns-command-modifier nil)
 '(package-selected-packages
   (quote
    (wc-mode skewer-mode web-beautify ag gited company-go go-autocomplete go-eldoc golint magithub go-mode go-projectile frame-cmds use-package solarized-theme smex smartparens exec-path-from-shell counsel aggressive-indent)))
 '(perl-indent-level 8)
 '(post-email-address "aardvark@saintaardvarkthecarpeted.com")
 '(post-should-prompt-for-attachment (quote Never))
 '(python-indent-guess-indent-offset t)
 '(require-final-newline t)
 '(safe-local-variable-values
   (quote
    ((eval add-hook
           (quote before-save-hook)
           (lambda nil
             (delete-trailing-whitespace)
             nil))
     (mangle-whitespace . t)
     (rm-trailing-spaces . t))))
 '(select-active-regions t)
 '(select-enable-clipboard t)
 '(send-mail-function (quote sendmail-send-it))
 '(setq c-basic-offset)
 '(show-paren-mode 1)
 '(sp-navigate-close-if-unbalanced t)
 '(spell-command "ispell" t)
 '(standard-indent 8)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify))
 '(uniquify-min-dir-content 2)
 '(user-mail-address "aardvark@saintaardvarkthecarpeted.com")
 '(vc-follow-symlinks nil)
 '(w3m-use-cookies t)
 '(wg-morph-on nil)
 '(win-switch-idle-time 1.25))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fixmee-notice-face ((t (:background "gray88" :foreground "dark red" :underline nil :slant italic :weight bold)))))

;;; x-hugh-custom ends here.
