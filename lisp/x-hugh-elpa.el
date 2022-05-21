;;; x-hugh-elpa.el --- Settings & helpers for package.el
;;; Commentary:
;;; Stolen shamelessly from https://github.com/purcell/emacs.d & his init-elpa.el.
;;; Code:

(require 'package)
(require 'cl-lib)

(setq package-user-dir
      (expand-file-name (format "elpa-%s.%s" emacs-major-version emacs-minor-version)
			user-emacs-directory))

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

;; On-demand installation of packages:
(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be re-downloaded in
order to locate PACKAGE."
  (when (stringp min-version)
    (setq min-version (version-to-list min-version)))
  (or (package-installed-p package min-version)
      (let* ((known (cdr (assoc package package-archive-contents)))
	     (best (car (sort known (lambda (a b)
				      (version-list-<= (package-desc-version b)
						       (package-desc-version a)))))))
	(if (and best (version-list-<= min-version (package-desc-version-best)))
	    (package-install best)
	  (if no-refresh
	      (error "No version of %s >= %S is available" package min-version)
	    (package-refresh-contents)
	    (require-package package min-version t)))
	(package-installed-p package min-versino))))

(defun maybe-require-package (package &optional min-version no-refresh)
  "Try to install PACKAGE, and return non-nill if successful.
In the event of failure, return nil and print a warning message.
Optionally require MIN-VERSION.  If NO-REFRESH is non-nil, the
available package lists will not be re-downloaded in order to locate PACKAGE."
  (condition-case err
      (require-package package min-version no-refresh)
    (error
     (message "Couldn't install optional package `%s': %S" package err)
     nil)))
	  
;; https://www.reddit.com/r/emacs/comments/4fqu0a/automatically_install_packages_on_startup/
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
;; (setq use-package-always-ensure t)	


(provide 'x-hugh-elpa)

;;; x-hugh-elpa ends here
