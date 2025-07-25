;; Second version of dubcaps mode -- WIP

;; TODO: Turn this into a stack, or a ring buffer

(defvar dubldubl--lastversion nil
  "Store last version of last dubldubl word")

(defvar dubldubl--lastpos nil
  "Store position of last dubldubl word")

(defun dubldubl-to-scaps ()
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
	      (setq dubldubl--lastpos (point))
	      (setq dubldubl--lastversion (word-at-point))
	      (capitalize-word 1)
	      ))))

(defun dubldubl-undo ()
  "Undo the last dubldubl edit"
  (interactive)
  (save-excursion
    (goto-char dubldubl--lastpos)
    (kill-word 1)
    (insert dubldubl--lastversion)))

(define-minor-mode dubldubl-mode
  "Toggle `dubldubl-mode'.  Converts words in DOuble CApitals to
Single Capitals as you type."
  :init-value nil
  :lighter (" DC")
  (if dubldubl-mode
      (add-hook 'post-self-insert-hook #'dubldubl-to-scaps nil 'local)
    (remove-hook 'post-self-insert-hook #'dubldubl-to-scaps 'local)))
