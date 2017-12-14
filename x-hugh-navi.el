;;; x-hugh-navi --- A Small but Useful(tm) way of navigating things

;;; Commentary:
;;; Oh, wow!

;;; Code:

(defvar navi-list-of-navigation-methods
  '("char" "word-1" "line")
  "List of navigation methods for navi.

These will be used to call avy-goto-[thing] functions.  If it
needs to be more generic than that, I can just have function
names here.")

(defun navi-rotate-method ()
  "Rotate list of navigation methods and print out what we just switched to."
  (interactive)
  (setq navi-list-of-navigation-methods
        (-rotate -1 navi-list-of-navigation-methods))
  (message (car navi-list-of-navigation-methods)))

(defun navi-call-navigation-method ()
  "Call the current navigation method."
  (interactive)
  (let ((f (intern (format "avy-goto-%s" (car navi-list-of-navigation-methods)))))
    (call-interactively f)))

;; (navi-call-navigation-method)

(provide 'x-hugh-navi)
;;; x-hugh-navi.el ends here
