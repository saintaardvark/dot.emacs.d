;;; x-hugh-reference --- reference material

;;; Commentary:
;;; Code that can be used as reference or templates

;; Reference material.

;; From Xah Lee's Emacs Lisp Idioms page
;; http://xahlee.org/emacs/elisp_idioms.html
;;
;; For selecting between matching characters:
;;
;; (defun select-inside-quotes ()
;;   "Select text between double straight quotes
;; on each side of cursor."
;;   (interactive)
;;   (let (p1 p2)
;;     (skip-chars-backward "^\"")
;;     (setq p1 (point))
;;     (skip-chars-forward "^\"")
;;     (setq p2 (point))

;;     (goto-char p1)
;;     (push-mark p2)
;;     (setq mark-active t)
;;   )
;; )

;; Working with the region:

;; (defun dosomething-region (p1 p2)
;;   "Prints region starting and ending positions."
;;   (interactive "r")
;;   (message "Region starts: %d, end at: %d" p1 p2)
;; )

;; Working on region or current word:

;; (defun downcase-word-or-region ()
;;   "Downcase current word or region."
;; (interactive)
;; (let (pos1 pos2 bds)
;;   (if (region-active-p)
;;      (setq pos1 (region-beginning) pos2 (region-end))
;;     (progn
;;       (setq bds (bounds-of-thing-at-point 'symbol))
;;       (setq pos1 (car bds) pos2 (cdr bds))))

;;   ;; now, pos1 and pos2 are the starting and ending positions of the
;;   ;; current word, or current text selection if exist.
;;   (downcase-region pos1 pos2)
;;   ))

;; "When you have a string, and you need to do more than just getting
;; substring or number of chars, put it in a temp buffer. Here's a
;; example:"

;; ;; suppose myStr is a var whose value is a string
;; (setq myStr "some string here you need to process")
;; (setq myStrNew
;;       (with-temp-buffer
;;         (insert myStr)

;;         ;; code to manipulate your string as buffer text
;;         ;; \u2026

;;         (buffer-string) ; get result
;;         ))

;; idiom for string replacement within a region
;; (save-restriction
;;   (narrow-to-region pos1 pos2)

;;   (goto-char (point-min))
;;   (while (search-forward "myStr1" nil t) (replace-match "myReplaceStr1"))
;;   ;; repeat for other string pairs
;; )

(provide 'x-hugh-reference)

