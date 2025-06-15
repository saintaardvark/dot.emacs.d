;;; -*- lexical-binding: t -*-
;;; x-hugh-passwords --- My passwords

;;; Commentary:
;;; Might as well put them some place...

;;; Code:

(defgroup x-hugh-passwords nil
  "Settings for passwords."
  :group 'tools)

(defcustom x-hugh-passwords/password-file "~/passwords.git/passwords.gpg"
  "Path to where your password file is kept."
  :type 'string
  :group 'x-hugh-passwords)

(defun x-hugh-open-password-file ()
  "Open password file."
  (interactive)
  (find-file-read-only x-hugh-passwords/password-file))

(defun x-hugh-open-password-file-maybe-matching-string (&optional arg)
  "Open the password file.  If ARG, only list lines matching string."
  (interactive "p")
  (save-excursion
    (find-file x-hugh-passwords/password-file)
    (when arg
	(progn
	  (list-matching-lines
	   (read-from-minibuffer "String to look for (case-insensitive): "))
	  (kill-buffer (get-file-buffer x-hugh-passwords/password-file))))))

(provide 'x-hugh-passwords)
;;; x-hugh-passwords.el ends here
