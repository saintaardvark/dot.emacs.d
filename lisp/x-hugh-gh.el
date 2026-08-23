;;; -*- lexical-binding: t -*-
;;; x-hugh-gh --- Functions for working with git

;;; Commentary:
;;; Might as well put them some place...

;;; Code:

(defgroup x-hugh-gh nil
  "Settings for working with git."
  :group 'tools)

(defcustom x-hugh-gh/repo-path "~/dev/src"
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
  "Open GH page for PROJECT in browser."
  (interactive "sProject: ")
  (browse-url (format "%s/%s" x-hugh-gh/web-repo project)))

;; FIXME: Make this work from within magit, too
(defun x-hugh-gh-git-commit-and-push-without-mercy ()
  "Commit all outstanding and push without hesitation.

Meant to be called from within a file buffer.

Do it, monkey boy!"
  (interactive)
  (start-process "nomercy" "git-commit-and-push-without-mercy" "~/bin/git-commit-and-push-without-mercy.sh" (concat "-r " (buffer-file-name))))

(defun x-hugh-gh--git (dir &rest args)
  "Run git ARGS in DIR and return trimmed stdout, or nil on failure."
  (with-temp-buffer
    (let ((default-directory (file-name-as-directory dir)))
      (when (zerop (apply #'call-process "git" nil t nil args))
        (string-trim (buffer-string))))))

(defun x-hugh-gh-migrate-rh-origin (dir)
  "Repoint DIR's `origin' remote at dross, keeping the old URL as `rh'.

DIR must be a git repo whose `origin' remote URL looks like
rh:/var/cache/git/<name>.  A new remote named `rh' is added with
that original URL, and `origin' is repointed at
ssh://dross/aardvark/<name>.

Signals an error if DIR has no `origin' remote, if that remote's URL
doesn't match the expected pattern, or if DIR already has an `rh'
remote.

See also: `bin/git-migrate-rh-origin' for a shell-script equivalent
that can be run across many repos at once."
  (interactive (list (read-directory-name "Repo: " x-hugh-gh/repo-path nil t)))
  (unless (x-hugh-gh--git dir "rev-parse" "--git-dir")
    (user-error "%s is not a git repo" dir))
  (let ((origin-url (x-hugh-gh--git dir "remote" "get-url" "origin")))
    (unless origin-url
      (user-error "%s has no 'origin' remote" dir))
    (unless (string-prefix-p "rh:/var/cache/git/" origin-url)
      (user-error "%s origin '%s' doesn't match rh:/var/cache/git/*" dir origin-url))
    (when (x-hugh-gh--git dir "remote" "get-url" "rh")
      (user-error "%s already has an 'rh' remote" dir))
    (let* ((name (substring origin-url (length "rh:/var/cache/git/")))
           (new-url (concat "ssh://dross/aardvark/" name)))
      (x-hugh-gh--git dir "remote" "add" "rh" origin-url)
      (x-hugh-gh--git dir "remote" "set-url" "origin" new-url)
      (message "origin=%s rh=%s" new-url origin-url))))

(defun x-hugh-grx (url)
  "Run grx on URL."
  (interactive "sURL: ")
  (magit-status
   ;; https://stackoverflow.com/questions/14074912/how-do-i-delete-the-newline-from-a-process-output/54503687#54503687
   (substring
    (shell-command-to-string (format "/home/hugh/bin/grx %s" url))
    0 -1)))

(provide 'x-hugh-gh)
;;; x-hugh-functions.el ends here
