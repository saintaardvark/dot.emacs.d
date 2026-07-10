;;; -*- lexical-binding: t -*-
;;; x-hugh-text --- stuff related to text editing

;;; Commentary:

;;; Code:

;; Text mode
(use-package filladapt
  :ensure t)

(setq kill-whole-line t)

;; FIXME: Not even sure what keypress that flyspell binding actually maps to
(use-package flyspell
  :config (add-hook 'text-mode-hook '(lambda () (flyspell-mode 1)))
  :custom (flyspell-auto-correct-binding [67108904]))

;; needed to get italian dictionary
(setq ispell-library-directory "/usr/lib/ispell")
;; needed to use ispell instead of aspell...which is just because
;; that's the italian dictionary I found
(setq ispell-program-name "/usr/bin/ispell")

(defun x-hugh-italiano ()
  "Uno modo per scrivere in italiano."
  (interactive)
  (set-input-method "italian-postfix")
  (setq ispell-local-dictionary "italiano"))

(defun x-hugh-nuovo-italiano (title)
  "Una funzione per scrivere uno nuovo blog post in italiano."
  (interactive "sTitolo (con dash e finisco con .md): ")
  (projectile-switch-project-by-name "~/dev/src/va7unx.space")
  (let* ((hugoname (format "italiano/%s" title))
	(filename (format "content/%s" hugoname)))
    (shell-command (format "hugo new %s" hugoname))
    (projectile-find-file filename)
    (x-hugh-italiano)))

(add-hook 'text-mode-hook '(lambda () (auto-fill-mode 1)))
(add-hook 'text-mode-hook '(lambda () (abbrev-mode 1)))

;; (add-hook 'git-commit-mode '(lambda () (auto-fill-mode -1)))

;; https://www.reddit.com/r/emacs/comments/69w9wg/can_we_do_this_in_emacs/dh9vra8/
(defun align-values (start end)
  "Vertically aligns region based on lengths of the first value of each line.
Example output:

    foo        bar
    foofoo     bar
    foofoofoo  bar"
  (interactive "r")
  (align-regexp start end
                "\\S-+\\(\\s-+\\)"
                1 1 nil))

(defun x-hugh-zap (arg char)
  "Kill up to, but *not* including, ARGth occurrence of CHAR.

Wrapper around 'zap-to-char' so does *not* including character."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (read-char "Zap to char: " t)))
  (zap-to-char arg char)
  (insert-char char)
  (backward-char))

(defun x-hugh-boxquote-yank-and-indent ()
  "My attempt to combine boxquote-yank and indent.
The car/cdr bits are from the docstring for boxquote-points.  It's a bit silly to run it twice, but it was simple."
  (interactive)
  (save-excursion
    (boxquote-yank)
    (forward-line)
    (indent-region (car (boxquote-points)) (cdr (boxquote-points)))))


;; TODO: This could be made a snippet
(defun x-hugh-details-summary (arg)
  "Add details/summary tag pair to text.  Useful for PRs.
With prefix argument, uses `prod' instead of `stage'."
  (interactive "P")
  (let ((env (if arg "prod" "stage")))
    (insert "<details>\n")
    (insert (format "<summary>ENV=%s make plan</summary>\n\n" env))
    (insert "```\n")
    (insert "details go here inside a code block\n")
    (insert "```\n")
    (insert "</details>\n")
    ;; Put cursor at the "details go here" line
    (forward-line -3)))

(defun x-hugh-details-surround ()
  "Surround regions with details tags.  Useful for PRs."
  (interactive)
  (if (region-active-p)
      (x-hugh-surround-region-plus-newlines "<details>\n<summary>Details go here</summary\n\n" "\n</details>\n")))

(defun x-hugh-get-random-emoji()
  (interactive)
  (require 'subr-x)
  (let (all-emojis (hash-table-keys emoji--derived))
    (nth (random (length all-emojis)) all-emojis)
    ))

(defun x-hugh-insert-random-emoji()
  (interactive)
  (insert (x-hugh-get-random-emoji)))

(defun x-hugh-gh-pr-munge-text ()
  "Prepare buffer for PR created with gh tool."
  (interactive)
  (save-excursion
    (let ((beg (point-min))
	  (end (point-max)))
      (unfill-region beg end))
    (auto-fill-mode -1)
    (electric-indent-mode 0)
    (turn-on-visual-line-mode)))

(defun x-hugh-arrayify (start end quote)
  "Turn strings on newlines into a QUOTEd, comma-separated one-liner.

Source: https://news.ycombinator.com/item?id=22131815
Thanks, numlocked!"
  (interactive "r\nMQuote: ")
  (let ((insertion
         (mapconcat
          (lambda (x) (format "%s%s%s" quote x quote))
          (split-string (buffer-substring start end)) ", ")))
    (delete-region start end)
    (insert insertion)))

;; Don't prompt me to save personal dictionary
(setq ispell-silently-savep t)

;; FIXME: Not working, unsure why
(defun toggle-quotes ()
  "Toggle quotes between single, double and backquotes.

Source: https://stackoverflow.com/a/41079223"
  (interactive)
  (let* ((beg (nth 8 (syntax-ppss)))
         (orig-quote (char-after beg))
         (new-quote (case orig-quote
                      (?\' ?\")
                      (?\" ?\`)
                      (?\` ?\')
		      )))
    (save-restriction
     (widen)
     (save-excursion
      (catch 'done
        (unless new-quote
          (message "Not inside a string")
          (throw 'done nil))
        (goto-char beg)
        (delete-char 1)
        (insert-char new-quote)
        (while t
          (cond ((eobp)
                 (throw 'done nil))
                ((= (char-after) orig-quote)
                 (delete-char 1)
                 (insert-char new-quote)
                 (throw 'done nil))
                ((= (char-after) ?\\)
                 (forward-char 1)
                 (when (= (char-after) orig-quote)
                   (delete-char -1))
                 (forward-char 1))
                ((= (char-after) new-quote)
                 (insert-char ?\\)
                 (forward-char 1))
                (t (forward-char 1)))))))))

(defun x-hugh-kill-word-inc-following-whitespace ()
  "Kill word including any following whitespace."
  (interactive)
  (kill-word 1)
  (just-one-space) 			; 😮😮😮
  )

;; TODO: swtich to using avy for this.  See
;; https://github.com/abo-abo/avy/wiki/custom-commands
(defun x-hugh-move-to-next-assignment-value ()
  "Move cursor to the first non-whitespace character after the next equal sign."
  (interactive)
  (search-forward "=")
  (if (looking-at (rx whitespace))
      (skip-chars-forward (rx whitespace))))


(defun tf-plan-wrap-details ()
  "Wrap each Terraform plan resource block in the buffer with `<details>' tags.

  A block starts at a line matching `  # module...' and ends at the next
  top-level closing brace line (four spaces followed by `}').  The header line
  becomes the `<summary>' (leading whitespace stripped); the resource body is
  placed verbatim inside a fenced code block.  A blank line separates blocks.

Created by Claude."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^  \\(# module.*\\)$" nil t)
      (let ((summary (match-string 1))
            (block-start (match-beginning 0))
            (body-start (line-beginning-position 2)))  ; start of next line
        (when (re-search-forward "^    }$" nil t)
          (let* ((body-end (line-end-position))
                 (body (buffer-substring-no-properties body-start body-end)))
            (delete-region block-start body-end)
            (goto-char block-start)
            (insert (format "<details>\n<summary>%s</summary>\n\n```\n%s\n```\n</details>"
                            summary body))))))))

(provide 'x-hugh-text)
;;; x-hugh-text.el ends here.
