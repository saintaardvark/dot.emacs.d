;; x-hugh-init --- start here!

;;; Commentary:

;;; Code:

;; FIXME: Turn off customizatoins: https://www.reddit.com/r/emacs/comments/9rrhy8/emacsers_with_beautiful_initel_files_what_about/


;; Do this so that we can add directories to .emacs.d and have them load.
;; For example:  with this stanza, we can do (require 'w3m-load), which is
;; at ~/.emacs/w3m/w3m-load.el.
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir "~/.emacs.d/")
	   (default-directory my-lisp-dir))
      (setq load-path (cons my-lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

;; OMG this is brilliant
;; But! I need to clone https://github.com/jodonnell/emacs/blob/master/auto-cask.el
;; (require 'auto-cask)
;; (auto-cask/setup "~/.emacs.d")

;; Need to use require here -- after this, use-package is loaded.
;; FIXME: Is there a way around this?
(require 'cask "~/.cask/cask.el")
(cask-initialize)

(use-package pallet
  :config
  (pallet-mode t))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :ensure t
  :config
  (exec-path-from-shell-initialize))

;; Custom file first.
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

;; And now everything else

(use-package x-hugh-random)
(use-package x-hugh-navi)
(use-package x-hugh-functions)
(use-package x-hugh-blog)
(use-package x-hugh-appearance)
;; (use-package x-hugh-confluence)
(use-package x-hugh-org)
;; (use-package x-hugh-cfengine)
(use-package x-hugh-helm)
(use-package x-hugh-reference)
(use-package x-hugh-modes)
(use-package x-hugh-text)
(use-package x-hugh-passwords)

;; Devel
(use-package x-hugh-magit)
(use-package x-hugh-projectile)
(use-package x-hugh-company)
(use-package x-hugh-yasnippet)
(use-package x-hugh-gh)
(use-package x-hugh-smartparens)

;; Languages
(use-package x-hugh-golang)
(use-package x-hugh-python)
(use-package x-hugh-shell)
;; (use-package x-hugh-ruby)
;; (use-package cfg)

;; Hydra comes before keymap.
(use-package x-hugh-hydra)
;; Keymaps come last.  Put a comment in other files about what
;; keymappings are set, but put the actual mapping in here.
(use-package x-hugh-keymap)
;; Any startup things (server-start), etc.
(use-package x-hugh-finally)

(provide 'x-hugh-init)

;;; x-hugh-init ends here
