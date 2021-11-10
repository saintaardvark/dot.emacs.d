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
;; FIXME: Have way of rverting this change immediately after typing
;; FIXME: Maybe exclude plurals (XXs)
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

(defun x-hugh-git-changetype ()
  "Cycle through git changetype.

Meant for use in magit."
  (interactive)
  (save-excursion
    (search-forward-regexp "^Change-type: ")
    (cond ((looking-at "\\[patch\\|minor\\|major\\]")
	   (progn (kill-line)
		  (insert "patch")))
	  ((looking-at "patch")
	   (progn (kill-line)
		  (insert "minor")))
	  ((looking-at "minor")
	   (progn (kill-line)
		  (insert "major")))
	  ((looking-at "major")
	   (progn (kill-line)
		  (insert "patch"))))))

(defun x-hugh-git-connects-to ()
  "Add \"Connects-to\" argument to git commit.

Meant for use in magit."
  (interactive)
  (save-excursion
    (if (search-forward-regexp "^Connects-to:" nil t)
	(progn (beginning-of-line)
	       (kill-line)
	       (join-line))
      (let ((ticket (read-from-minibuffer "Ticket: ")))
	(search-forward-regexp "^Change-type: ")
	(forward-line)
      (insert (format "Connects-to: %s\n" ticket))))))

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

(defun x-hugh-gh-pr-munge-text ()
  "Run unfill on buffer and turn on viewlines-mode.

Meant for adapting text for PRs created with gh."
  (interactive)
  (save-excursion
    (let ((beg (point-min))
	  (end (point-max)))
      (unfill-region beg end))
    (electric-indent-mode 0)
    (turn-on-visual-line-mode)))

(provide 'x-hugh-text)
;;; x-hugh-text.el ends here.
