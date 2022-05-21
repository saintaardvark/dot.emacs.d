;; x-hugh-init --- start here!

;;; Commentary:

;;; Code:

;; https://emacs.stackexchange.com/questions/60560/error-retrieving-https-elpa-gnu-org-packages-archive-contents-error-http-400
;; "It is a race bug int Emacs and newer versions of GNU TLS that
;; showed up in Emacs v26.1 but is fixed in Emacs v27. A simple
;; temporary fix is just to turn of TLS 1.3 support in Emacs v26.1 and
;; the race conditions goes away. It is not a good solution, as we
;; need TLS 3.1, but it will do until the propper sollution is
;; implemented. As discussed in the original bug report. See
;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=34341#19".
(if (version< emacs-version "27.0")
    (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

;; FIXME: See note in first_run.sh, and figure out what went wrong.
;; At the very least, this is copy-pasta of code above.
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir "~/.emacs.d/.cask")
	   (default-directory my-lisp-dir))
      (setq load-path (cons my-lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

;; TODO: Figure out a way to make this work in the terminal
;; (setq frame-background-mode 'dark)

;; OMG this is brilliant
;; But! I need to clone https://github.com/jodonnell/emacs/blob/master/auto-cask.el
;; (require 'auto-cask)
;; (auto-cask/setup "~/.emacs.d")

;; Need to use require here -- after this, use-package is loaded.
;; FIXME: Is there a way around this?
(require 'cask "~/.cask/cask.el")
;; (cask-initialize)

(use-package pallet
  :config
  (pallet-mode t))

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
(use-package x-hugh-appearance)
;; (use-package x-hugh-confluence)
(use-package x-hugh-org)
;; (use-package x-hugh-cfengine)
(use-package x-hugh-helm)
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

;;; x-hugh-init ends here
