;;; -*- lexical-binding: t -*-
;;; x-hugh-terraform --- stuff related to terraform

;;; Commentary:

;;; Code:

(use-package terraform-mode
  :ensure t
  :config (add-hook 'terraform-mode-hook  #'terraform-format-on-save-mode)
)

;; Not needed in newer Emacs versions, but kept here to be defensive
(require 'subr-x)

(defun x-hugh-terraform-plan-to-details (start end)
  "Convert a terraform plan block in the region into a GitHub-flavored
<details>/<summary> block.  The '# module...' line becomes the summary;
the remaining non-empty lines become the fenced body."
  (interactive "r")
  (let* ((text  (buffer-substring-no-properties start end))
         (lines (split-string text "\n"))
         (summary-line (seq-find
                        (lambda (l) (string-match "^[[:space:]]*#.*will be" l))
                        lines))
         (body-lines   (seq-filter
                        (lambda (l)
                          (and (not (string-empty-p (string-trim l)))
                               (not (string-match "^[[:space:]]*#.*will be" l))))
                        lines)))
    (unless summary-line
      (user-error "No '# module ... will be' line found in region"))
    (delete-region start end)
    (insert (format "<details>\n<summary>%s</summary>\n\n```\n%s\n```\n</details>\n"
                    (string-trim summary-line)
                    (string-join body-lines "\n")))))

(provide 'x-hugh-terraform)
;;; x-hugh-terraform.el ends here
