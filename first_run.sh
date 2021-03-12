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
