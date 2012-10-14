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

(provide 'x-hugh-cfengine)
