;;; x-hugh-gh --- Functions for working with git

;;; Commentary:
;;; Might as well put them some place...

;;; Code:

(defgroup x-hugh-gh nil
  "Settings for working with git."
  :group 'tools)

(defcustom x-hugh-gh/repo-path "~/software"
  "Path to where your main git repos are kept."
  :type 'string
  :group 'x-hugh-gh)

(defcustom x-hugh-gh/web-repo "https://github.com/saintaardvark"
  "Website where your git repos are kept."
  :type 'string
  :group 'x-hugh-gh)

(defun x-hugh-gh-open-git-repo ()
  "Open up a git repo."
  (interactive)
  (let ((dir (completing-read "File: " (directory-files x-hugh-gh/repo-path t))))
    (dired dir)
    (magit-status dir)))

(defun x-hugh-gh-open-github-repo-url (project)
  "Open GH page for current repo in browser."
  (interactive "sProject: ")
  (browse-url (format "%s/%s" x-hugh-gh/web-repo project)))

(defun x-hugh-gh-git-commit-and-push-without-mercy ()
  "Commit all outstanding and push without hesitation. Meant to be called from within a file buffer.

Do it, monkey boy!"
  (interactive)
  (start-process "nomercy" "git-commit-and-push-without-mercy" "~/bin/git-commit-and-push-without-mercy.sh" (concat "-r" (buffer-file-name))))

(provide 'x-hugh-gh)
;;; x-hugh-functions ends here