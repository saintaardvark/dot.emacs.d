;;; x-hugh-shell --- My shell stuff

;;; Commentary:
;;; Might as well put them some place...

;;; Code:

(defun x-hugh-edit-dot-bashrc (arg)
  "Edit .bashrc_local, or (with arg) .bashrc."
  (interactive "P")
  (if arg
      (find-file (file-truename "~/.bashrc"))
    (find-file (file-truename"~/.bashrc_local"))))

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

(provide 'x-hugh-shell)
;;; x-hugh-shell ends here
