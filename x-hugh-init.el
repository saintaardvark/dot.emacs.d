;; x-hugh-init --- start here!

;;; Commentary:

;;; Code:

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
(require 'cask "~/.cask/cask.el")
(cask-initialize)
(require 'pallet)
(pallet-mode t)

;; (when (memq window-system '(mac ns))
;;   (exec-path-from-shell-initialize))

;; Is this redundant?
(setq load-path  (cons (expand-file-name "~/.emacs.d/") load-path))

;; Custom file first.
(setq custom-file "~/.emacs.d/x-hugh-custom.el")
(load custom-file 'noerror)

;; Add melpa
(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; Set up path
(if (file-exists-p "/usr/local/bin")
    (push "/usr/local/bin" exec-path))
(if (file-exists-p "~/bin")
    (push "~/bin" exec-path))
(exec-path-from-shell-copy-env "PATH")

;; And now everything else

(require 'x-hugh-random)
(require 'x-hugh-functions)
(require 'x-hugh-blog)
(require 'x-hugh-appearance)
;; (require 'x-hugh-confluence)
(require 'x-hugh-org)
;; (require 'x-hugh-cfengine)
(require 'x-hugh-helm)
(require 'x-hugh-reference)
(require 'x-hugh-modes)
(require 'x-hugh-yasnippet)
(require 'x-hugh-text)
(require 'x-hugh-passwords)

;; Devel
(require 'x-hugh-magit)
(require 'x-hugh-projectile)
(require 'x-hugh-company)
(require 'x-hugh-gh)
(require 'x-hugh-smartparens)

;; Languages
(require 'x-hugh-golang)
(require 'x-hugh-python)
(require 'x-hugh-shell)
(require 'x-hugh-ruby)
(require 'cfg)

;; Hydra comes before keymap.
(require 'x-hugh-hydra)
;; Keymaps come last.  Put a comment in other files about what
;; keymappings are set, but put the actual mapping in here.
(require 'x-hugh-keymap)
;; Any startup things (server-start), etc.
(require 'x-hugh-finally)

(provide 'x-hugh-init)

;;; x-hugh-init ends here
