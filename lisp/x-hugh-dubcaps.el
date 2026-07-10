;; -*- lexical-binding: t -*-
;;; x-hugh-dubcaps --- convert DOuble CApitals to Single Capitals as you type

;;; Commentary:

;;; Code:

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
(defgroup dubcaps nil
  "Convert DOuble CApitals to Single Capitals as you type."
  :group 'text)

(defcustom dcaps-exclude-words '("GHz" "IPs" "VMs" "DCs" "MRs" "PRs")
  "Words `dcaps-to-scaps' must never correct.
Compared case-sensitively against the whole word being typed.
Add to this interactively with `dcaps-ignore-and-revert'."
  :type '(repeat string)
  :group 'dubcaps)

(defvar-local dcaps--last nil
  "Record of the most recent correction, or nil.
A list (BEG-MARKER END-MARKER ORIGINAL-STRING) describing the word
`dcaps-to-scaps' last corrected, used by `dcaps-revert-last'.")

(defun dcaps-to-scaps ()
  "Convert word in DOuble CApitals to Single Capitals.
Record the correction in `dcaps--last' so it can be reverted with
`dcaps-revert-last', and skip any word in `dcaps-exclude-words'."
  (interactive)
  (and (= ?w (char-syntax (char-before)))
       (save-excursion
         (when (if (called-interactively-p "any")
                   (skip-syntax-backward "w")
                 (= -3 (skip-syntax-backward "w")))
           (let* ((case-fold-search nil)
                  (beg (point))
                  (end (save-excursion (skip-syntax-forward "w") (point)))
                  (word (buffer-substring-no-properties beg end)))
             (when (and (looking-at "\\b[[:upper:]]\\{2\\}[[:lower:]]")
                        (not (looking-at "\\b[[:upper:]]\\{2\\}s")) ; plurals
                        (not (member word dcaps-exclude-words)))
               (setq dcaps--last
                     (list (copy-marker beg) (copy-marker end t) word))
               (capitalize-word 1)))))))

(defun dcaps-revert-last ()
  "Undo the most recent double-caps -> single-caps correction.
Works whether point is still on the word or several words later."
  (interactive)
  (pcase dcaps--last
    (`(,beg ,end ,orig)
     (save-excursion
       (delete-region beg end)
       (goto-char beg)
       (insert orig))
     (setq dcaps--last nil))
    (_ (message "No recent dubcaps correction to revert"))))

(defun dcaps-ignore-and-revert ()
  "Revert the last correction and never correct that word again.
Adds the word to `dcaps-exclude-words' and saves it permanently."
  (interactive)
  (pcase dcaps--last
    (`(,_beg ,_end ,orig)
     (dcaps-revert-last)
     (add-to-list 'dcaps-exclude-words orig)
     (customize-save-variable 'dcaps-exclude-words dcaps-exclude-words)
     (message "Reverted and permanently ignoring %S" orig))
    (_ (message "No recent dubcaps correction to ignore"))))

(defvar dubcaps-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c u") #'dcaps-revert-last)
    (define-key map (kbd "C-c U") #'dcaps-ignore-and-revert)
    map)
  "Keymap for `dubcaps-mode'.")

(define-minor-mode dubcaps-mode
  "Toggle `dubcaps-mode'.  Converts words in DOuble CApitals to
Single Capitals as you type."
  :init-value nil
  :lighter (" DC")
  :keymap dubcaps-mode-map
  (if dubcaps-mode
      (add-hook 'post-self-insert-hook #'dcaps-to-scaps nil 'local)
    (remove-hook 'post-self-insert-hook #'dcaps-to-scaps 'local)))

(add-hook 'text-mode-hook #'dubcaps-mode)

(provide 'x-hugh-dubcaps)
;;; x-hugh-dubcaps.el ends here.
