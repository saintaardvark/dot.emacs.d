;;; x-hugh-text --- stuff related to text editing

;;; Commentary:

;;; Code:

;; Text mode
(use-package filladapt)

;; FIXME: Not even sure what keypress that flyspell binding actually maps to
(use-package flyspell
  :config (add-hook 'text-mode-hook '(lambda () (flyspell-mode 1)))
  :custom (flyspell-auto-correct-binding [67108904]))

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
		 (not (looking-at "GHz\\|IPs\\|VMs\\|DCs")))) ; no brackets for alternation!
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

(defun x-hugh-company-coming ()
  "Clean up email."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "Saint Aardvark the Carpeted" nil t)
      (replace-match "Hugh Brown" nil nil))
    (goto-char (point-min))
    (while (re-search-forward "disturbed my sleep to write" nil t)
      (replace-match "wrote" nil nil))
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
      (insert-file-contents "~/.signature-va7unx"))

    (flush-lines "Because the plural of Anecdote is Myth" nil t)))

(defun x-hugh-zap (arg char)
  "Kill up to, but *not* including, ARGth occurrence of CHAR.

Wrapper around 'zap-to-char' so does *not* including character."
  (interactive (list (prefix-numeric-value current-prefix-arg)
		     (read-char "Zap to char: " t)))
  (zap-to-char arg char)
  (insert-char char)
  (backward-char))

(defun x-hugh-delete-to-sig ()
  "Delete from point to signature.

Rewritten as defun."
  (interactive)
  (let ((beg (point)))
    (save-excursion
      (post-goto-signature)
      (kill-region beg (point)))))


(defun x-hugh-boxquote-yank-and-indent ()
  "My attempt to combine boxquote-yank and indent.
The car/cdr bits are from the docstring for boxquote-points.  It's a bit silly to run it twice, but it was simple."
  (interactive)
  (save-excursion
    (boxquote-yank)
    (next-line)
    (indent-region (car (boxquote-points)) (cdr (boxquote-points)))))

(provide 'x-hugh-text)
;;; x-hugh-text.el ends here.
