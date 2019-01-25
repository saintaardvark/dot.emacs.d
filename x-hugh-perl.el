;; x-hugh-perl --- Perl stuff

;;; Commentary:
;; Perl stuff/ settings.

;;; Code:

;; Perl
(use-package perldoc)
(defalias 'perl-mode 'cperl-mode)
;; 8 spaces for tab, the way God intended
(setq nperl-indent-level 8)
(setq cperl-indent-level 8)

(provide 'x-hugh-perl)
;;; x-hugh-perl ends here
