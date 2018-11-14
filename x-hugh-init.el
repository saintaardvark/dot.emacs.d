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
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Set up path
(if (file-exists-p "/usr/local/bin")
    (push "/usr/local/bin" exec-path))
(if (file-exists-p "~/bin")
    (push "~/bin" exec-path))
(exec-path-from-shell-copy-env "PATH")

;; And now everything else

(require 'x-hugh-random)
(require 'x-hugh-navi)
(require 'x-hugh-functions)
(require 'x-hugh-blog)
(require 'x-hugh-appearance)
;; (require 'x-hugh-confluence)
(require 'x-hugh-org)
;; (require 'x-hugh-cfengine)
(require 'x-hugh-helm)
(require 'x-hugh-reference)
(require 'x-hugh-modes)
(require 'x-hugh-text)
(require 'x-hugh-passwords)

;; Devel
(require 'x-hugh-magit)
(require 'x-hugh-projectile)
(require 'x-hugh-company)
(require 'x-hugh-yasnippet)
(require 'x-hugh-gh)
(require 'x-hugh-smartparens)

;; Languages
(require 'x-hugh-golang)
(require 'x-hugh-python)
(require 'x-hugh-shell)
;; (require 'x-hugh-ruby)
;; (require 'cfg)

;; Hydra comes before keymap.
(require 'x-hugh-hydra)
;; Keymaps come last.  Put a comment in other files about what
;; keymappings are set, but put the actual mapping in here.
(require 'x-hugh-keymap)
;; Any startup things (server-start), etc.
(require 'x-hugh-finally)

(provide 'x-hugh-init)

;;; x-hugh-init ends here
