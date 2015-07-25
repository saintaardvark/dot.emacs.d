;; Do this so that we can add directories to .emacs.d and have them load.
;; For example:  with this stanza, we can do (require 'w3m-load), which is
;; at ~/.emacs/w3m/w3m-load.el.
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir "~/.emacs.d/")
	   (default-directory my-lisp-dir))
      (setq load-path (cons my-lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

;; OMG this is brilliant
;; (require 'auto-cask)
;; (auto-cask/setup "~/.emacs.d")
(require 'cask "~/.cask/cask.el")
(cask-initialize)
(require 'pallet)
(pallet-mode t)

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; Is this redundant?
(setq load-path  (cons (expand-file-name "~/.emacs.d/") load-path))
;; Try moving x-hugh-settings first; trying to get x-hugh-custom.el,
;; which is loaded in there, loaded first -- which'll let the theme
;; loading in x-hugh-custom, as it's in the Cask directory.
(require 'x-hugh-settings)
(require 'x-hugh-packages)
(require 'x-hugh-text)
(require 'x-hugh-modes)
(require 'x-hugh-functions)
(require 'x-hugh-appearance)
;; (require 'x-hugh-confluence)
(require 'x-hugh-org)
;; (require 'x-hugh-cfengine)
(require 'x-hugh-helm)
(require 'x-hugh-reference)
(require 'x-hugh-keymap)
;; Any startup things (server-start), etc.
(require 'x-hugh-finally)

(provide 'x-hugh-init)
