;;; x-hugh-folding --- Some stuff for folding

;;; Commentary:
;;; Sometimes I hate Emacs' defaults.

;;; Code:

(defun set-selective-display-dlw (&optional level)
  "Fold text indented same of more than the cursor.
If level is set, set the indent level to LEVEL.
If 'selective-display' is already set to LEVEL, clicking
F5 again will unset 'selective-display' by setting it to 0."
  (interactive "P")
  (if (eq selective-display (1+ (current-column)))
      (set-selective-display 0)
    (set-selective-display (or level (1+ (current-column))))))

(provide 'x-hugh-folding)
;;; x-hugh-folding.el ends here
