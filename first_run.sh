#!/bin/bash

if [ -d ~/.cask ] ; then
	cd ~/.cask 
        git pull origin master
else
	git clone https://github.com/cask/cask.git ~/.cask
fi
cd ~/.emacs.d
~/.cask/bin/cask
