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

;; (defgroup x-hugh-doubled-words nil
;;   "Settings for doubled-words.."
;;   :group 'tools)

;; (defcustom x-hugh-doubled-words/exclusions
;;   '("GHz" "IPs" "VMs" "DCs")
;;   "List of words to exclude from doubling protection."
;;   :type 'string
;;   :group 'x-hugh-doubled-words)

;; (defun x-hugh-doubled-words/build-exclusion-regex (excluded-words)
;;   "Build a regex out of words to exclude from x-hugh-doubled-words."
;;   ;; for w in excluded-words:
;;   ;;   regex += "w\\|"
;;   ;;
;;   ;; regex.trim("\\|")
;;   (while (excluded-words
;; 	 (excluded-words-regex (format "%s\\|" (car excluded-words)))
;; 	 (setq excluded-words (cdr excluded-words))))
;;   (excluded-words-regex))

;; (x-hugh-doubled-words/build-exclusion-regex x-hugh-doubled-words/exclusions)

;; fix double-capitals
;; from https://emacs.stackexchange.com/questions/13970/fixing-double-capitals-as-i-type/13975#13975
;; FIXME: Have better way of specifying words to exclude
;; FIXME: Have way of reverting this change immediately after typing
;; -- see https://github.com/emacsorphanage/key-chord/blob/master/key-chord.el and the delay vars/functions there
(defun dcaps-to-scaps ()
  "Convert word in DOuble CApitals to Single Capitals."
  (interactive)
  (and (= ?w (char-syntax (char-before)))
       (save-excursion
         (and (if (called-interactively-p "any")
                  (skip-syntax-backward "w")
                (= -3 (skip-syntax-backward "w")))
              (let (case-fold-search)
		(and
                 (looking-at "\\b[[:upper:]]\\{2\\}[[:lower:]]")
                 (not (looking-at "\\b[[:upper:]]\\{2\\}s")) ; Exclude plurals
		 (not (looking-at "GHz\\|IPs\\|VMs\\|DCs\\|MRs\\|PRs")))) ; no brackets for alternation!
	      (capitalize-word 1)))))

(define-minor-mode dubcaps-mode
  "Toggle `dubcaps-mode'.  Converts words in DOuble CApitals to
Single Capitals as you type."
  :init-value nil
  :lighter (" DC")
  (if dubcaps-mode
      (add-hook 'post-self-insert-hook #'dcaps-to-scaps nil 'local)
    (remove-hook 'post-self-insert-hook #'dcaps-to-scaps 'local)))

(add-hook 'text-mode-hook #'dubcaps-mode)

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


(defun x-hugh-details-summary ()
  "Add details/summary tag pair to text.  Useful for PRs."
  (interactive)
  (insert "<details>\n")
  (insert "<summary>Details go here</summary>\n\n")
  (insert "```\n")
  (insert "details go here inside a code block\n")
  (insert "```\n")
  (insert "</details>\n"))

(defun x-hugh-details-surround ()
  "Surround regions with details tags.  Useful for PRs."
  (interactive)
  (if (region-active-p)
      (x-hugh-surround-region-plus-newlines "<details>\n<summary>Details go here</summary\n\n```\n" "```\n</details>\n")))

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


;; FIXME: not done yet.  Meant for editing text like this quickly by
;; letting me go from the end of one line to the first non-whitespace
;; char following the equal sign on the right.f

;; resource "aws_route53_record" "www" {
;;   zone_id = aws_route53_zone.primary.zone_id
;;   name    = "www.example.com"
;;   type    = "A"
;;   ttl     = 300
;;   records = [aws_eip.lb.public_ip]
;; }
;;
;; this might work:
;;  (let ((start (line-beginning-position))
        (end (line-end-position)))
    (if (search-forward (char-to-string char) end t)
(defun move-to-next-assignment-value ()
  "Move cursor to the first non-whitespace character after the equal sign on the next line."
  (interactive)
  (let ((current-line (thing-at-point 'line t)))
    (if (string-match "=" current-line)
        (let ((next-line (line-number-at-pos (1+ (line-beginning-position)))))
          (if (and next-line (not (eobp)))
              (progn
                (forward-line 1)  ; Move to the next line
                (skip-chars-forward " \t")  ; Skip whitespace
                (if (looking-at "=")
                    (progn
                      (forward-char 1)  ; Move past the equal sign
                      (skip-chars-forward " \t")))))  ; Skip whitespace after equal sign
            (message "No next line or no equal sign found.")))
      (message "No equal sign found in the current line."))))

(defun move-to-next-assignment-value ()
  "Move cursor to the first non-whitespace character after the equal sign on the next line."
  (interactive)
  (let ((current-line (thing-at-point 'line t)))
    (if (string-match "=" current-line)
        (let ((next-line (line-number-at-pos (1+ (line-beginning-position)))))
          (if (and next-line (not (eobp)))
              (progn
                (forward-line 1)  ; Move to the next line
                (skip-chars-forward " \t")  ; Skip whitespace
                (if (looking-at "=")
                    (progn
                      (forward-char 1)  ; Move past the equal sign
                      (skip-chars-forward " \t")))))
            (message "No next line or no equal sign found.")))
    (message "No equal sign found in the current line.")))

(defun move-to-next-assignment-value ()
  "Move cursor to the first non-whitespace character after the equal sign on the next line."
  (interactive)
  (let ((current-line (thing-at-point 'line t)))
    (if (string-match "=" current-line)
        (progn
          (forward-line 1)  ; Move to the next line
          (skip-chars-forward " \t")  ; Skip whitespace
          (when (looking-at "=")
            (forward-char 1)  ; Move past the equal sign
            (skip-chars-forward " \t")))  ; Skip whitespace after equal sign
      (message "No equal sign found in the current line."))))
    


(provide 'x-hugh-text)
;;; x-hugh-text.el ends here.
