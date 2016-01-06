;;; x-hugh-markdown --- My functions for markdown


;;; Commentary:
;;; Might as well put them some place...

;;; Code:

(defun x-hugh-rf-markdown-footnote (&optional imgplease)
  "Add a footnote in Markdown mode at the *end* of the buffer.

Uses numbers for links. Linkify the region if region active. Prefix means make it an image."
  (interactive "p")
  (let ((link (read-string "Link: "))
        (link-number (x-hugh-rf-get-next-link-number))
        (first-prefix
         (if (equal imgplease 1)
             (setq first-prefix "[")
           (setq first-prefix "!["))))
    (x-hugh-rf-markdown-add-link-at-end-of-buffer link link-number)
    (if (region-active-p)
        (x-hugh-rf-markdown-add-markdown-link-text link-number "" first-prefix)
      (x-hugh-rf-markdown-add-markdown-link-text link-number (read-string "Description: ") first-prefix))))

(defun x-hugh-rf-markdown-add-markdown-link-text (link-number &optional description first-prefix)
  "Refactor: Add markdown link in body to LINK, LINK-NUMBER, description DESCRIPTION using FIRST-PREFIX."
  (if (region-active-p)
      (progn
        (let ((pos1 (region-beginning))
              (pos2 (+ (region-end) 1)))
          (goto-char pos1)
          (insert "[")
          (goto-char pos2)
          (insert "]")))
    (insert (format "%s%s]" first-prefix description)))
  (insert (format "[%d]" link-number)))

(defun x-hugh-rf-markdown-surround-region ())

(defun x-hugh-rf-markdown-add-link-at-end-of-buffer (link link-number)
  "Refactor: add link to LINK at end of buffer using LINK-NUMBER."
  (let ((current-line (line-number-at-pos))
        (last-line (line-number-at-pos (point-max))))
    (save-excursion
      (if (> (- last-line current-line) 1)
          ()
        (insert "\n"))
      (goto-char (point-max))
      (if (search-backward-regexp (rx bol "[") (point-min) t)
          ())
      (forward-line)
      (if (looking-at (rx bol))
          ()
        (insert "\n")
        (forward-line))
      (insert (format "[%d]: %s" link-number link)))))

(defun x-hugh-rf-get-next-link-number ()
  "Figure out the number for the next link."
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (beginning-of-line)
    (if (looking-at "\\[\\([0-9]+\\)]:")
        (progn
          (message (match-string 1))
          (eval (+ 1 (string-to-number (match-string 1)))))
                                        ; else:
      (if (search-backward-regexp (rx bol "[") (point-min) t)
          (progn
            (if (looking-at "^\\[\\([0-9]+\\)]:")
                (progn
                  (message (match-string 1))
                  (eval (+ 1 (string-to-number (match-string 1)))))
              (eval 0)))
        (eval 0)))))

(provide 'x-hugh-markdown)
;;; x-hugh-markdown.el ends here
