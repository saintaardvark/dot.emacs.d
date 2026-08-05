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

;; For the <details> block itself and the header pattern, both of which
;; x-hugh-tf-plan needs too.
(require 'x-hugh-tf-plan)

(defun x-hugh-terraform-plan-to-details (start end)
  "Convert a terraform plan block in the region into a GitHub-flavored
<details>/<summary> block.  The '# module...' line becomes the summary;
the remaining non-empty lines become the fenced body.

The summary line is any of the ones Terraform writes above a resource --
`will be created', `must be replaced', `has changed' and the rest -- not
just `will be'."
  (interactive "r")
  (let* ((text  (buffer-substring-no-properties start end))
         (lines (split-string text "\n"))
         (header-p (lambda (line)
                     (string-match-p x-hugh-tf-plan-resource-header-regexp
                                     line)))
         (summary-line (seq-find header-p lines))
         (body-lines   (seq-remove
                        (lambda (line)
                          (or (string-empty-p (string-trim line))
                              (funcall header-p line)))
                        lines)))
    (unless summary-line
      (user-error "No resource header line found in region"))
    (delete-region start end)
    (insert (x-hugh-tf-plan-details-block
             (string-trim summary-line)
             (concat "```\n" (string-join body-lines "\n") "\n```"))
            "\n")))

(provide 'x-hugh-terraform)
;;; x-hugh-terraform.el ends here
