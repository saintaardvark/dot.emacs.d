;;; x-hugh-blog --- My blogging code

;;; Commentary:

;;; Code:

(defun x-hugh-chronicle-new-blog-entry (title)
  "A Small but Useful(tm) function to make a new blog entry in Chronicle."
  (interactive "sTitle: ")
  (setq filename (replace-regexp-in-string "[^a-zA-Z0-9]" "_" (downcase title)))
  (message filename)
  (find-file (concat "/home/aardvark/blog/input/" (format-time-string "%Y-%m") "/" filename ".mdwn"))
  (insert (format "Title: %s\n" title))
  (insert (format "Date: %s\n" (format-time-string "%a %b %d %R:%S %Z %Y")))
  (insert (format "Tags: \n\n"))
  (add-hook 'before-save-hook 'x-hugh-chronicle-update-datestamp nil t)
  (wc-goal-mode 1))

(defun x-hugh-jekyll-new-blog-entry (title)
  "A Small but Useful(tm) function to make a new blog entry in Jekyll."
  (interactive "sTitle: ")
  (setq filename (replace-regexp-in-string "[^a-zA-Z0-9]" "_" (downcase title)))
  (message filename)
  (find-file (concat "/home/aardvark/jekyll-blog/_posts/" (format-time-string "%Y-%m-%d-") filename ".md")) ;
  (insert "---")
  (insert (format "\ntitle: %s\n" title))
  (insert (format "date: %s\n" (format-time-string "%a %b %d %R:%S %Z %Y")))
  (insert (format "tags:\n---\n\n"))
  ; (add-hook 'before-save-hook 'x-hugh-chronicle-update-datestamp nil t)
  (wc-goal-mode 1))

(defun x-hugh-chronicle-update-datestamp ()
  "Update the timestamp on a blog post."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward-regexp (rx bol "date: "))
    (kill-line)
    (insert (format "%s" (format-time-string "%a %b %d %R:%S %Z %Y")))))

(defun x-hugh-chronicle-list-tags ()
  "A Small but Useful9tm) function to list the tags available for Chronicle."
  (interactive)
  (with-output-to-temp-buffer "*Blog tags*"
    (with-current-buffer "*Blog tags*"
      (insert-directory "/home/aardvark/blog/output/tags" "-CF"))))

(defun x-hugh-chronicle-add-tag ()
  "Add a tag to a chronicle blog post."
  (interactive)
;; This turns out to be surprisingly simple
  (insert
   (completing-read "Tag: "
		    (directory-files "/home/aardvark/blog/output/tags"))))

(provide 'x-hugh-blog)

;;; x-hugh-blog ends here
