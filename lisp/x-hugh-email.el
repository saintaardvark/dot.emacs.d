;;; -*- lexical-binding: t -*-
;;; x-hugh-email --- stuff related to email editing

;;; Commentary:

;;; Code:

;; Use post for Mutt.
(use-package post
  :custom ((post-email-address "aardvark@saintaardvarkthecarpeted.com")
           (post-should-prompt-for-attachment 'Never))
  :mode ("/tmp/mutt.*$" . post-mode))

(defun x-hugh-company-coming ()
  "Clean up email."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "Saint Aardvark the Carpeted" nil t)
      (replace-match "Hugh Brown" nil nil))
    (goto-char (point-min))
    (while (re-search-forward "In a surprising turn of events, " nil t)
      (replace-match "" nil nil))
    (goto-char (point-min))
    (flush-lines "Because the plural of Anecdote is Myth" nil t)))

(defun x-hugh-die-outlook-die ()
  "Decode HTML mail when replying.  Not quite perfect, but close."
  (interactive)
  (save-excursion
    (post-goto-body)
    (search-forward-regexp "^>")
    (let ((beg (point)))
      (goto-char (point-max))
      (search-backward-regexp ">")
      (end-of-line)
      (shell-command-on-region beg (point) "/usr/bin/w3m -T text/html" t t)
      (flush-lines (rx bol ">" (zero-or-more blank) eol))
      (flush-lines (rx bol (zero-or-more blank) eol))
      (post-goto-signature)
      (post-quote-region beg (point)))))

(defun x-hugh-hi-bob ()
  "Set email to cq at va7unx.space"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "Saint Aardvark the Carpeted <aardvark@saintaardvarkthecarpeted.com>" nil t)
      (replace-match "Hugh Brown VA7UNX <cq@va7unx.space>" nil nil))
    (post-goto-signature)
    (let ((beg (point)))
      (goto-char (point-max))
      (kill-region beg (point))
      (insert-file-contents "~/.signature-va7unx")
      (insert "--\n"))
    (flush-lines "Because the plural of Anecdote is Myth" nil t)))

(defun x-hugh-hugh-va7unx ()
  "Set email to hugh@va7unx.space."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "Saint Aardvark the Carpeted <aardvark@saintaardvarkthecarpeted.com>" nil t)
      (replace-match "Hugh Brown <hugh@va7unx.space>" nil nil))
    (goto-char (point-min))
    (while (re-search-forward "CC: Hugh Brown <hugh@va7unx.space>," nil t)
      (replace-match "CC: ")
      (kill-line))
    (goto-char (point-min))
    (while (re-search-forward "In a surprising turn of events, " nil t)
      (replace-match "" nil nil))
    (post-goto-signature)
    (let ((beg (point)))
      (goto-char (point-max))
      (kill-region beg (point))
      (insert-file-contents "~/.signature-va7unx")
      (insert "--\n"))
    (flush-lines "Because the plural of Anecdote is Myth" nil t)))

(defun x-hugh-fix-andys-links ()
  "Fix up Andy's links in email, which for some reason get split over two lines."
  (interactive)
  (save-excursion
    (post-goto-body)
    (search-forward "http")
    (forward-line)
    (join-line)
    (delete-char 1)))

(defun x-hugh-delete-to-sig ()
  "Delete from point to signature.

Rewritten as defun."
  (interactive)
  (let ((beg (point)))
    (save-excursion
      (post-goto-signature)
      (kill-region beg (point))
      (if (looking-at "--")
	  (insert "\n")))))

(defun x-hugh-fcc-nwcah ()
  "Add fcc/NWCAH header for Mutt"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward "Bcc:")
    (insert "\nFcc: =nwcah")))

(provide 'x-hugh-email)
;;; x-hugh-email.el ends here.
