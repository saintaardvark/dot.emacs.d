;; Second version of dubcaps mode -- WIP

(defvar dubldubl--lastpair nil
  "Store before-and-after versions of last dubldubl word")

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
	      (setq dubldubl--lastpair (word-at-point))
	      (capitalize-word 1)
	      (message (word-at-point))
	      (append dubldubl--lastpair (word-at-point))))))

(define-minor-mode dubldubl-mode
  "Toggle `dubldubl-mode'.  Converts words in DOuble CApitals to
Single Capitals as you type."
  :init-value nil
  :lighter (" DC")
  (if dubldubl-mode
      (add-hook 'post-self-insert-hook #'dubldubl-to-scaps nil 'local)
    (remove-hook 'post-self-insert-hook #'dubldubl-to-scaps 'local)))
