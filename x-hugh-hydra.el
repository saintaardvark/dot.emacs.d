;;; x-hugh-hydra --- Hydra stuff

;;; Commentary:

;;; Code:

(defhydra hydra-zoom (global-map "<f2>")
  "zoom"
  ("g" (enlarge-font 1) "in")
  ("l" (enlarge-font -1) "out")
  ("0" (text-scale-set 0) "reset")
  ("j" winner-undo "winner-undo")
  ("k" winner-redo "winner-redo"))

(defhydra hydra-apropos (:color blue
                         :hint nil)
  "
_a_propos        _c_ommand
_d_ocumentation  _l_ibrary
_v_ariable       _u_ser-option
^ ^          valu_e_"
  ("a" apropos)
  ("d" apropos-documentation)
  ("v" apropos-variable)
  ("c" apropos-command)
  ("l" apropos-library)
  ("u" apropos-user-option)
  ("e" apropos-value))

(defhydra hydra-puppet (:color blue
                        :hint nil)
  "
_a_ccesscontrol
_m_aps dired
m_o_nitoring
_s_jc maps file
"
  ("a" (dired "~/gh/Puppet/accesscontrol/manifests"))
  ("m" (dired "~/gh/Puppet/puppet-core/external_node/maps"))
  ("o" (dired "~/gh/Puppet/puppet-core/monitoring/manifests"))
  ("s" (find-file "~/gh/Puppet/puppet-core/external_node/maps/sjc.opendns.com")))

(defhydra hydra-window (:color amaranth)
  "window"
  ("h" windmove-left)
  ("j" windmove-down)
  ("k" windmove-up)
  ("l" windmove-right)
  ("v" (lambda ()
         (interactive)
         (split-window-right)
         (windmove-right))
   "vert")
  ("x" (lambda ()
         (interactive)
         (split-window-below)
         (windmove-down))
   "horz")
  ("t" transpose-frame "'")
  ("o" delete-other-windows "one" :color blue)
  ("a" ace-window "ace")
  ("s" ace-swap-window "swap")
  ("d" ace-delete-window "del")
  ("i" ace-maximize-window "ace-one" :color blue)
  ("b" ido-switch-buffer "buf")
  ("m" headlong-bookmark-jump "bmk")
  ("-" balance-windows "balance")
  (">" end-of-buffer "end-of-buffer")
  ("<" beginning-of-buffer "beg-of-buffer")
  ("/" isearch-forward "search-forward" :color blue)
  ("\\" isearch-backward "search-backward" :color blue)
  ("q" nil "cancel"))

(defhydra hydra-personal-files (:exit t)
  "personal files"
  ("a" (lambda ()
	 (interactive)
	 (find-file "/home/aardvark/saintaardvarkthecarpeted.com/astronomy.mdwn"))
	 "astronomy page")
  ("b" x-hugh-edit-dot-bashrc ".bashrc")
  ("d" x-hugh-die-outlook-die "die, Outlook, die")
  ("e" x-hugh-edit-dot-emacs  ".emacs")
  ("f" x-hugh-figl  "figl")
  ("g" x-hugh-open-git-repo "Open git repo")
  ("l" (find-file "~/orgmode/log_2016.org") "Open logfile")
  ("m" (magit-status "~/.dotfiles") "Open .dotfiles in magit")
  ("o" (dired "/backup/music/ogg") "Music")
  ("r" x-hugh-open-password-file-maybe-matching-string "Search password file")
  ("s" (find-file "~/.ssh/config") "Open .ssh/config")
  ("t" x-hugh-company-coming))

(defhydra hydra-puppet-chef (:exit t)
  "Cheffing Puppet"
  ("f" (x-hugh-copy-puppet-to-chef "file") "file")
  ("l" (x-hugh-copy-puppet-to-chef "link") "link")
  ("p" (x-hugh-copy-puppet-to-chef "package") "package"))

;; FIXME: Add a hydra for shell.  Or maybe just a keyboard shortcut.
(provide 'x-hugh-hydra)
;;; x-hugh-hydra.el ends here
