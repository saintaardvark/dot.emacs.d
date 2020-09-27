;;; x-hugh-email --- stuff related to email editing

;;; Commentary:

;;; Code:

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
  "Clean up email when replying to another amateur."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "Saint Aardvark the Carpeted <aardvark@saintaardvarkthecarpeted.com>" nil t)
      (replace-match "Hugh Brown VA7UNX <va7unx@members.fsf.org>" nil nil))
    (post-goto-signature)
    (let ((beg (point)))
      (goto-char (point-max))
      (kill-region beg (point))
      (insert-file-contents "~/.signature-va7unx")
      (insert "--\n"))
    (flush-lines "Because the plural of Anecdote is Myth" nil t)))

(defun x-hugh-libre-space-email ()
  "Set appropriate email bits when using aardvark@libre.space email.."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "Saint Aardvark the Carpeted <aardvark@saintaardvarkthecarpeted.com>" nil t)
      (replace-match "Hugh Brown <aardvark@libre.space>" nil nil))
    (post-goto-signature)
    (let ((beg (point)))
      (goto-char (point-max))
      (kill-region beg (point))
      (insert-file-contents "~/.signature-librespace")
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

(provide 'x-hugh-email)
;;; x-hugh-email.el ends here.
