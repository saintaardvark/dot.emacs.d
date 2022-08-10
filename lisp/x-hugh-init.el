;; x-hugh-init --- start here!

;;; Commentary:

;;; Code:

;; This first one needs to be `require`; it loads the `use-package`
;; package.  After that, we can use `(use-package)`.  Clear as mud?
(require 'x-hugh-elpa)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :ensure t
  :config
  (exec-path-from-shell-initialize))

;; I'm moving away from custom vars, because it's a righteous pain to
;; debug when something goes wrong.  For most things, custom vars can
;; be put in use-package stanzas; for the rest, I'll put them here.
;; For discussion and background, see:
;; https://www.reddit.com/r/emacs/comments/9rrhy8/emacsers_with_beautiful_initel_files_what_about/
;; FIXME: Have better name for this.
(use-package x-hugh-random)

;; Custom file next
(setq custom-file "~/.emacs.d/x-hugh-custom.el")
(load custom-file 'noerror)

;; Add melpa
;; FIXME: Melpa not going https for some reason
(use-package package
  :config
  (progn
    (let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                        (not (gnutls-available-p))))
           (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
      (add-to-list 'package-archives (cons "melpa" url) t))
    (package-initialize)))

;; Set up path
(if (file-exists-p "/usr/local/bin")
    (push "/usr/local/bin" exec-path))
(if (file-exists-p "~/bin")
    (push "~/bin" exec-path))
(exec-path-from-shell-copy-env "PATH")

;; Trying this as a way of pointing Emacs in the right direction.
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")

;; And now everything else

(use-package x-hugh-mouse)
(use-package x-hugh-navi)
(use-package x-hugh-functions)
(use-package x-hugh-blog)
(use-package x-hugh-ace)
(use-package x-hugh-appearance)
;; (use-package x-hugh-confluence)
(use-package x-hugh-org)
;; (use-package x-hugh-cfengine)
(use-package x-hugh-helm)
(use-package x-hugh-swiper)
(use-package x-hugh-reference)
(use-package x-hugh-modes)
(use-package x-hugh-text)
(use-package x-hugh-email)
(use-package x-hugh-markdown)
(use-package x-hugh-folding)

(use-package x-hugh-passwords)

;; Devel
(use-package x-hugh-lsp)
(use-package x-hugh-magit)
(use-package x-hugh-projectile)
;; Try turning off company mode & see how I feel.
;; (use-package x-hugh-company)
(use-package x-hugh-yasnippet)
(use-package x-hugh-gh)
(use-package x-hugh-smartparens)
(use-package x-hugh-docker)

;; Languages
(use-package x-hugh-golang)
(use-package x-hugh-python)
(use-package x-hugh-shell)
;; (use-package x-hugh-ruby)
(use-package x-hugh-terraform)
(use-package x-hugh-typescript)


;; (use-package cfg
;;   :custom (cfg-chef-cookbook-directory "/Users/hubrown/gh/Chef"))

;; Hydra comes before keymap.
(use-package x-hugh-hydra)
;; Keymaps come last.  Put a comment in other files about what
;; keymappings are set, but put the actual mapping in here.
(use-package x-hugh-keymap)
;; Any startup things (server-start), etc.
(use-package x-hugh-finally)

(provide 'x-hugh-init)

;;; x-hugh-init.el ends here
