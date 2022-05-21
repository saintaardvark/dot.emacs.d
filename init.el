;;; Stolen shamelessly from http://hg.gomaa.us/dotfiles.
;;; His whole damn way of organizing dotfiles is pretty cool.




;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/"))))


(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/modes")
;; (add-to-list 'load-path "~/.emacs.d/.cask/27.2")
; single entry point
(require 'x-hugh-init)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

