#!/bin/bash

if [ -d ~/.cask ] ; then
	cd ~/.cask
        git pull origin master
else
	git clone https://github.com/cask/cask.git ~/.cask
fi

cd ~/.emacs.d

# Necessary on OSX; see
# http://stackoverflow.com/questions/18330954/using-cask-with-emacs-app
if [ -f /Applications/Emacs.app/Contents/MacOS/Emacs ] ; then
	export EMACS=/Applications/Emacs.app/Contents/MacOS/Emacs
fi

~/.cask/bin/cask

# Note to myself:
# Emacs 26 (still the default on Debian 10) has a problem with gnutls-cli.  See x-hugh-init.el for details.
# If you get random errors about packages not being downloadable, add these lines to cask-cli.el:
# diff --git a/cask-cli.el b/cask-cli.el
# index b9016ce..d11a7f0 100644
# --- a/cask-cli.el
# +++ b/cask-cli.el
# @@ -40,6 +40,11 @@
#  (when noninteractive
#     (shut-up-silence-emacs))
#
#     +
#     +;;  See comment in ~/.emacs.d/x-hugh-init.el
#     +(if (version< emacs-version "27.0")
#     +       (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))
#     +
#      (defconst cask-cli--table-padding 10
#         "Number of spaces to pad with when printing table.")

# Note to myself:
# Not sure what's gone wrong, but in updating my .emacs.d repo I manage to bork packages pretty badly.  Here's what I had to do to revert:

# Add to ~/.emacs:
# (eval-and-compile
#   (customize-set-variable
#    'package-archives '(("org" . "https://orgmode.org/elpa/")
#                        ("melpa" . "https://melpa.org/packages/")
#                        ("gnu" . "https://elpa.gnu.org/packages/"))))

# - eval that
# - list packages
# - install use-packages
# - edit x-hugh-init.el
# - add:
# (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
#     (let* ((my-lisp-dir "~/.emacs.d/.cask/")
# 	   (default-directory my-lisp-dir))
#       (setq load-path (cons my-lisp-dir load-path))
#       (normal-top-level-add-subdirs-to-load-path)))
# restart
# Note that this was *after* running cask.  Did get error re: cask init function gone ... did not have time to dig into that
#
# Note: I encountered this again, and the steps above did not fix.  I had to blow away ~/.emac.d/.cask and run this script (first_run.sh) again.
