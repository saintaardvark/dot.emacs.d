;; Cfengine stuff.

(defun x-hugh-open-cfengine-files ()
  (interactive)
  (dired-other-frame "~/svn/cfengine/cf-01.chibi.ubc.ca/inputs")
  (split-window-vertically)
  (dired "~/svn/cfengine/cf-01.chibi.ubc.ca/files/Centos/5/"))

(defun x-hugh-open-cf3-files ()
  (interactive)
  (dired-other-frame "~/svn/cfengine/cf-02.chibi.ubc.ca/inputs")
  (split-window-vertically)
  (dired "~/svn/cfengine/cf-01.chibi.ubc.ca/files/centos/5/"))

(defun x-hugh-open-neurodevnet-cfengine-files ()
  (interactive)
  (dired-other-frame "~/svn/cfengine/nd-cf-01.chibi.ubc.ca/inputs")
  (split-window-vertically)
  (dired "~/svn/cfengine/nd-cf-01.chibi.ubc.ca/files/Centos/5/"))

(defun x-hugh-cf3-insert-file-template (file)
  "Insert a copy-file template."
  (interactive "sFile to copy: ")
  (newline-and-indent)
  (insert-string (format "\"%s\"" file))
  (newline-and-indent)
  (insert-string (format "  comment => \"Copy %s into place.\"," file))
  (newline-and-indent)
  (insert-string (format "  perms   => mog(\"0755\", \"root\", \"wheel\"),"))
  (newline-and-indent)
  (insert-string (format "  copy_from => secure_cp(\"$(g.masterfiles)/centos/5%s\", \"$(g.masterserver)\");" file)))

(defun x-hugh-cf3-insert-directory-template (dir)
  "Insert a create-directory template."
  (interactive "sDirectory to create (no trailing slash): ")
  (newline-and-indent)
  (insert-string (format "\"%s\/.\"" dir))
  (newline-and-indent)
  (insert-string (format "  comment => \"Create directory %s.\"," dir))
  (newline-and-indent)
  (insert-string (format "  perms   => mog(\"0755\", \"root\", \"wheel\"),"))
  (newline-and-indent)
  (insert-string (format "  create  => \"true\";")))

      ;; "/etc/drush/."
      ;;   comment => "Create /etc/drush.",
      ;;   create  => "true",
      ;;   perms   => mog("0755", "root", "wheel");

(defun x-hugh-cf3-insert-boilerplate ()
  "Insert Cf3 boilerplate re: local changes being overwitten."
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (indent-for-comment)
    (insert-string "This file is maintained by Cfengine. All local changes will be overwritten!")
    (newline-and-indent)))

(provide 'x-hugh-cfengine)
