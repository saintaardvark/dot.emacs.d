;;; x-hugh-shell --- My shell stuff

;;; Commentary:
;;; Might as well put them some place...

;;; Code:

(defun x-hugh-edit-dot-bashrc (arg)
  "Better way to edit bashrc files, now that I've split them up.

If ARG is provided, open in other window."
  (interactive "P")
  (x-hugh-edit-completing-read arg "~/" ".bashrc"))

(defun hlu-make-script-executable ()
  "If file starts with a shebang, make `buffer-file-name' executable.

Stolen from http://www.emacswiki.org/emacs/MakingScriptsExecutableOnSave."
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (when (and (looking-at "^#!")
                 (not (file-executable-p buffer-file-name)))
	(set-file-modes buffer-file-name
			(logior (file-modes buffer-file-name) #o100))
	(message (concat "Made " buffer-file-name " executable"))))))

(add-hook 'after-save-hook 'hlu-make-script-executable)

;; Specify that I want bash for inferior shells
(use-package term
  :config
  (setq explicit-shell-file-name "/bin/bash"))

(use-package em-term
  :custom (eshell-visual-commands
	   '("vi" "screen" "top" "less" "more" "lynx" "ncftp" "pine" "tin" "trn" "elm" "ssh")))

(defun x-hugh-launch-shell ()
  "Launch a shell in the Hugh-approved manner.

If we're in a projectile-associated buffer, then invoke
projectile-run-shell; otherwise, just invoke shell."
  (interactive)
  (if (projectile-project-p)
      (projectile-run-shell)
    (shell)))

(provide 'x-hugh-shell)
;;; x-hugh-shell.el ends here
