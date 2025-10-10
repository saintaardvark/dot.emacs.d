;;; -*- lexical-binding: t -*-
;;; x-hugh-markdown --- My functions for markdown

;;; Commentary:
;;; Might as well put them some place...

;;; Code:


(use-package markdown-mode
  :ensure t
  :mode ((".*md$" . markdown-mode)
         ("\\.mdwn\\'" . markdown-mode)
	 (".*mdx$" . markdown-mode)))

(defun x-hugh-rf-markdown-footnote (&optional imgplease)
  "Add a footnote in Markdown mode at the *end* of the buffer.

Uses numbers for links. Linkify the region if region active. Prefix means make it an image."
  (interactive "p")
  (let ((link (read-string "Link: "))
        (link-number (x-hugh-rf-get-next-link-number)))
    (x-hugh-rf-markdown-add-link-at-end-of-buffer link link-number)
    (if (region-active-p)
        (x-hugh-rf-markdown-add-markdown-link-text link-number "" imgplease)
      (x-hugh-rf-markdown-add-markdown-link-text link-number (read-string "Description: ") imgplease))))

(defun x-hugh-rf-markdown-add-markdown-link-text (link-number &optional description imgplease)
  "REFACTOR: Add markdown link in body to LINK, LINK-NUMBER, description DESCRIPTION using FIRST-PREFIX.

If IMGPLEASE provided, make an image markdown link."
  (if (region-active-p)
      (x-hugh-rf-markdown-surround-region)
    ;; else insert description, maybe image.
    ;; FIXME: This doesn't account for the case where we want to
    ;; turn a region into an image link.
    (if (not (equal imgplease 4))
        (insert "!"))
    (insert (format "[%s]" description)))
  (insert (format "[%s]" link-number)))

(defun x-hugh-rf-markdown-add-link-at-end-of-buffer (link link-number)
  "Refactor: add link to LINK at end of buffer using LINK-NUMBER."
  (let ((current-line (line-number-at-pos))
        (last-line (line-number-at-pos (point-max))))
    (save-excursion
      (when (< (- last-line current-line) 1)
        (insert "\n"))
      (goto-char (point-max))
      (forward-line)
      (if (not (looking-at (rx bol)))
          (progn
            (insert "\n")
            (forward-line)))
      (insert (format "[%d]: %s" link-number link)))))

(defun x-hugh-rf-get-next-link-number ()
  "Figure out the number for the next link."
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (beginning-of-line)
    (if (looking-at (rx "[" (group (one-or-more digit)) "]:"))
        (progn
          (message (match-string 1))
          (eval (+ 1 (string-to-number (match-string 1)))))
                                        ; else:
      (if (search-backward-regexp (rx bol "[") (point-min) t)
          (progn
            (if (looking-at (rx "[" (group (one-or-more digit)) "]:"))
                (progn
                  (message (match-string 1))
                  (eval (+ 1 (string-to-number (match-string 1)))))
              (eval 0)))
        (eval 0)))))

(defun x-hugh-rf-markdown-surround-region ()
  "Surround region with square brackets."
  (let ((pos1 (region-beginning))
        (pos2 (+ (region-end) 1)))
    (goto-char pos1)
    (insert "[")
    (goto-char pos2)
    (insert "]")))

;; FIXME: Does not work for wrapping region
;; FIXME: Copy-pasta from blog code. Refactor into method for wrapping regions.
(defun x-hugh-markdown-code-block ()
  "Insert markdown code block, ready to be filled in.

Simple...but it works!"
  (interactive)
  (if (region-active-p)
      (x-hugh-surround-region-plus-newlines "```" "```")
    (insert "```\n\n```"))
  (forward-line -1))

(provide 'x-hugh-markdown)
;;; x-hugh-markdown.el ends here
