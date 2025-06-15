;;; -*- lexical-binding: t -*-
;; x-hugh-dired --- Dired stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

;; code goes here

(use-package dired
  :custom ((dired-dwim-target t)
	   (dired-recursive-copies 'always)
	   (dired-recursive-deletes 'top)))

;; Emergency fix for bug
;; - https://debbugs.gnu.org/cgi/bugreport.cgi?bug=58946
;; - https://debbugs.gnu.org/cgi/bugreport.cgi?bug=58870
;; - https://snapcraft.io/emacs shows latest build being October 29th, 29.0.50-master-81d7827 -- this is what I have installed.
;; Waiting on snapraft for this to be refreshed.

(defun dired--make-directory-clickable ()
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^  /" nil t 1)
      (let ((bound (line-end-position))
            (segment-start (point))
            (inhibit-read-only t)
            (dir "/"))
        (while (search-forward "/" bound t 1)
          (setq dir (concat dir (buffer-substring segment-start (point))))
          (add-text-properties
           segment-start (1- (point))
           `( mouse-face highlight
              help-echo "mouse-1: goto this directory"
              keymap ,(let* ((current-dir dir)
                             (click (lambda ()
                                      (interactive)
                                      (if (assoc current-dir dired-subdir-alist)
                                          (dired-goto-subdir current-dir)
                                        (dired current-dir)))))
                        (define-keymap
                          "<mouse-2>" click
                          "<follow-link>" 'mouse-face
                          "RET" click)))))))))


;; TODO: Use dired-git-info
(use-package dired-git-info
  :ensure t
  :config (define-key dired-mode-map ")" 'dired-git-info-mode))

(provide 'x-hugh-dired)
;;; x-hugh-template.el ends here
