;;; x-hugh-ruby --- Ruby settings

;;; Commentary:
;;; ❤

;;; Code:

(exec-path-from-shell-copy-env "GEM_HOME")

(defun x-hugh-rubocop-disable (cop)
  "Add comment to disable a Rubocop complaint."
  (save-excursion
    (move-beginning-of-line nil)
    (insert (concat "# rubocop:disable " cop))))

(defun x-hugh-rubucop-disable-linelength ()
    "Disable Rubocop linelength complaint."
  (interactive)
  (x-hugh-rubocop-disable "LineLength"))

(add-hook 'ruby-mode-hook 'whitespace-cleanup-mode)

(setq flycheck-ruby-rubocop-executable (executable-find "rubocop"))

(provide 'x-hugh-ruby)
;;; x-hugh-ruby ends here

