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
