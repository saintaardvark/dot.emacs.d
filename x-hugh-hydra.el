;;; x-hugh-hydra --- Hydra stuff

;;; Commentary:

;;; Code:

(defhydra hydra-zoom (global-map "<f2>")
  "zoom"
  ("g" text-scale-increase "in")
  ("l" text-scale-decrease "out"))

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
  ("g" x-hugh-open-git-repo "Open git repo")
  ("m" (magit-status "~/.dotfiles") "Open .dotfiles in magit")
  ("r" x-hugh-open-password-file "Open password file")
  ("s" x-hugh-reload-dot-emacs "Reload .emacs"))


(provide 'x-hugh-hydra)
;;; x-hugh-hydra.el ends here
