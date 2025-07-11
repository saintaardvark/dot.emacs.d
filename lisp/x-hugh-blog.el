;;; -*- lexical-binding: t -*-
;;; x-hugh-blog --- My blogging code

;;; Commentary:

;;; Code:

(defgroup x-hugh-blog nil
  "Settings for working with git."
  :group 'tools)

(defcustom x-hugh-blog/repo-path "~/dev/src/va7unx.space"
  "Path to where the blog repo is kept."
  :type 'string
  :group 'x-hugh-blog)

(defcustom x-hugh-blog/post-dir "content/posts"
  "Directory within the blog repo where new posts are put."
  :type 'string
  :group 'x-hugh-blog)

(defcustom x-hugh-blog/hugo-exe "/home/aardvark/bin/hugo"
  "Path to hugo executable."
  :type 'string
  :group 'x-hugh-blog)

(defun x-hugh-jekyll-new-blog-entry (title)
  "A Small but Useful(tm) function to make a new blog entry named titled TITLE in Jekyll."
  (interactive "sTitle: ")
  (let ((filename (replace-regexp-in-string "[^a-zA-Z0-9]" "_" (downcase title))))
    (message filename)
    (find-file (concat x-hugh-blog/repo-path "/" x-hugh-blog/post-dir "/" (format-time-string "%Y-%m-%d-") filename ".md")) ;
    (insert "---")
    (insert (format "\ntitle: %s\n" title))
    (insert (format "date: %s\n" (format-time-string "%a %b %d %R:%S %Z %Y")))
    (insert (format "tags:\n---\n\n"))))
                                        ; (add-hook 'before-save-hook 'x-hugh-chronicle-update-datestamp nil t)
(defun x-hugh-hugo-new-blog-entry (title)
  "A Small but Useful(tm) function to make a new blog entry named titled TITLE in Hugo."
  (interactive "sTitle: ")
  (let* ((hugo-ified-title (replace-regexp-in-string "[^a-zA-Z0-9]" "-" (downcase title)))
	 (filename-with-extension (format "%s/%s.md" x-hugh-blog/post-dir hugo-ified-title))
	 (default-directory x-hugh-blog/repo-path)
	 (full-blog-post-path (format "%s/%s" x-hugh-blog/repo-path filename-with-extension))) ; TODO: This could be its own helper function
    (message (format "DEBUG: fulp-blog-post-path: %s" full-blog-post-path))
    (if (not (file-exists-p full-blog-post-path))
	(async-shell-command (format "%s new %s" x-hugh-blog/hugo-exe filename-with-extension))
      (find-file full-blog-post-path))))

(defun x-hugh-jekyll-update-datestamp ()
  "Update the timestamp on a blog post."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward-regexp (rx bol "date: "))
    (kill-line)
    (insert (format "%s" (format-time-string "%a %b %d %R:%S %Z %Y")))))

;; FIXME: This stuff duplicates what's in x-hugh-markdown.el. One of the two should be removed.
;; FIXME: I don't have any keymappings for these?
(defun x-hugh-markdown-footnote (&optional imgplease)
  "Add a footnote in Markdown mode at the *end* of the buffer.

Uses numbers for links.  Linkify the region if region active. Prefix means make it an image."
  (interactive "p")
  (let ((current-line (line-number-at-pos))
        (last-line (line-number-at-pos (point-max)))
        (link (read-string "Link: "))
        (link-number (x-hugh-get-next-link-number))
        (first-prefix
         (if (equal imgplease 1)
             (setq first-prefix "[")
           (setq first-prefix "!["))))
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
      (insert (format "[%d]: %s" link-number link)))
    (if (region-active-p)
        (progn
          (setq pos1 (region-beginning) pos2 (region-end))
          (goto-char pos1)
          (insert "[")
          (goto-char pos2)
          (forward-char)
          (insert (format "][%d]" link-number)))
      (insert (format "%s%s][%d]" first-prefix (read-string "Description: ") link-number)))))

(defun x-hugh-get-next-link-number ()
  "Figure out the number for the next link."
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (beginning-of-line)
    (if (looking-at "\\[\\([0-9]+\\)]:")
        (progn
          (message (match-string 1))
          (eval (+ 1 (string-to-number (match-string 1)))))
      ;; else:
      (if (search-backward-regexp (rx bol "[") (point-min) t)
          (progn
            (if (looking-at "^\\[\\([0-9]+\\)]:")
                (progn
                  (message (match-string 1))
                  (eval (+ 1 (string-to-number (match-string 1)))))
              (eval 0)))
        (eval 0)))))

(defun x-hugh-markdown-footnote-noninteractive (link imgplease)
  "Refactored, non-interactive version of x-hugh-markdown-footnote."
  )

(defun x-hugh-add-markdown-footnote-at-end-of-page (link)
  "Refactored, non-interactive function to add footnote for LINK."
  (let ((current-line (line-number-at-pos))
        (last-line (line-number-at-pos (point-max)))
        (link-number (x-hugh-get-next-link-number)))
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
      (insert (format "[%d]: %s" link-number link)))
    link-number))

(defun x-hugh-markdown-footnote-refactored (&optional imgplease)
  "Refactored version."
  (interactive "p")
  (let ((first-prefix
         (if (equal imgplease 1)
             (setq first-prefix "[")
           (setq first-prefix "![")))
        (link (read-string "Link: "))
        (link-number (x-hugh-add-markdown-footnote-at-end-of-page link))
	(if (region-active-p)
            (progn
              (setq pos1 (region-beginning) pos2 (region-end))
              (goto-char pos1)
              (insert "[")
              (goto-char pos2)
              (forward-char)
              (insert (format "][%d]" link-number)))
	  (insert (format "%s%s][%d]" first-prefix (read-string "Description: ") link-number))))))

(defun x-hugh-chronicle-add-tag ()
  "Add a tag to a chronicle blog post."
  (interactive)
  ;; This turns out to be surprisingly simple
  (insert
   (completing-read "Tag: "
		    (directory-files "/home/aardvark/blog/output/tags"))))

(defun x-hugh-list-phonepix ()
  "List phonepix at /mnt."
  (interactive)
  (setq x-hugh-blog-saved-window-configuration
        (current-window-configuration))
  (split-window-right)
  (save-excursion
    (other-window 1)
    (image-dired "/mnt/phonepix")))

(defun x-hugh-list-phonepix-2 ()
  "List phonepix at /mnt, take 2."
  (interactive)
  (dired "/mnt/phonepix")
  (dired-mark-files-regexp (image-file-name-regexp))
  (let ((files (dired-get-marked-files)))
    (progn
      (image-dired-display-thumbs)
      (other-window 1)
      (bury-buffer))))

(defun x-hugh-image-dired-phonepix-to-blog ()
  "Convert marked image files to suitably small blogpix."
  (interactive)
  (save-window-excursion
    ;; Could do this with tramp, but this is simpler to start with.
    (let ((img (image-dired-original-file-name))
          (base (file-name-nondirectory (image-dired-original-file-name))))
      (save-excursion
        (other-window 1)
        (insert (format "https://saintaardvarkthecarpeted.com/images/%s" base)))
      (async-shell-command (format "/home/aardvark/bin/mogrify_for_blog.sh %s" img)))))

(defun x-hugh-get-name-of-previous-month ()
  "Return the name of the previous month."
  ()
  (let ((this-month-by-name (format-time-string "%B"))
	;; Stupid simple
	(this-month-to-last-month #s(hash-table
				     size 30
				     test equal
				     data (
					   "January" "December"
					   "February" "January"
					   "March" "February"
					   "April" "March"
					   "May" "April"
					   "June" "May"
					   "July" "June"
					   "August" "July"
					   "September" "August"
					   "October" "September"
					   "November" "October"
					   "December" "November"
					   ))))
    (gethash this-month-by-name this-month-to-last-month)))

(defun x-hugh-get-year-of-previous-month ()
  "Return the year of the previous month."
  ()
  (let ((this-month-by-name (format-time-string "%B"))
	(this-year (format-time-string "%Y")))
    (if (string= this-month-by-name "January")
	(- (string-to-number this-year) 1)
      this-year)))

(defun x-hugh-blog-what-happened-last-month ()
  "Create post for what happened last month."
  (interactive)
  (let ((last-month (x-hugh-get-name-of-previous-month))
	(year-of-last-month (x-hugh-get-year-of-previous-month))
	(title-format "What happened in %s %s")
	(journal-file x-hugh-org/journal-file))
    (message (format title-format last-month year-of-last-month))
    (x-hugh-hugo-new-blog-entry (format title-format last-month year-of-last-month))
    (find-file-other-window journal-file)))
;; also open journal.org to its left, ideally opened to last month's entries
;; Bonus points: hugo -D in background

(provide 'x-hugh-blog)

;;; x-hugh-blog.el ends here
