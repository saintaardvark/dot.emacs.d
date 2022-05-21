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

;; Note: This all talks about clicks, when in fact it's about
;; toggling which function gets called.

;; Originally, I'd set up navi so that a single click would navigate
;; somewhere, and a double click would change the method of navigation
;; (from char to word to line). :
;; (defvar navi-single-click-cmd 'navi-call-navigation-method)
;; (defvar navi-double-click-cmd 'navi-rotate-method)
;;
;; However, I've come to realize that I mainly navigate using either
;; character or line, Thus, single click navigates by character;
;; double click navigates by line.
(defvar navi-single-click-cmd 'avy-goto-char)
(defvar navi-double-click-cmd 'avy-goto-line)

;; FIXME: We're using double-click-time here; should set a variable for this.
;; https://stackoverflow.com/questions/4923723/emacs-how-to-bind-a-key-tapped-twice
(defvar navi-click-timer nil
  "Pending single-click event.")

(defun navi-click-cmd ()
  "Either kick off a single click, or a double click."
  (interactive)
  (if navi-click-timer
      (progn
        (cancel-timer navi-click-timer)
        (setq navi-click-timer nil)
        (call-interactively navi-double-click-cmd))
    (setq navi-click-timer (run-at-time (when double-click-time
                                            (/ 100.0 double-click-time))
                                      nil
                                      'navi-call-single-click))))

;; FIXME: I'd really like it if I could do the same kind of
;; do-one-thing-unless-i-repeat-the-command approach for the control
;; key:

;; Ctrl [whatever] - usual C-[whatever]
;; Ctrl-Ctrl - Meta
;;
;; Would save me from alt/option pinky.  Wonder if that's possible
;; from w/in emacs or need to go to OS.  Maybe C-c would do it?  DOH
;; -- Keep forgetting that C-[ does this!  Not quite as convenient,
;; but will do.

(defun navi-call-single-click ()
  "Spawn the single click."
  (setq navi-click-timer nil)
  (call-interactively navi-single-click-cmd))

(provide 'x-hugh-navi)
;;; x-hugh-navi.el ends here
