;;; x-hugh-erc --- ERC settings

;;; Commentary:
;;; Those pants look good on you.

;;; Code:

(setq erc-hide-list (quote ("JOIN" "PART" "QUIT")))
(setq erc-nick "SaintAardvark")

(setq erc-autojoin-channels-alist '(("irc.freenode.net"
				     "#emacs"
				     "#chef"
				     )))

(provide 'x-hugh-erc)
;;; x-hugh-erc ends here
