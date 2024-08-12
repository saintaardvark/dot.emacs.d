# dot.emacs.d

## Overview

This is my .emacs.d repository.

## Usage

Clone to .emacs.d, then run Emacs.  Packages should be installed by default.

## Building Emacs

Just a reference for myself for Debian:

```
apt-get install \
	texinfo \
	texi2html \
	autoconf \
	libgccjit-12 \
	libgnutls28-dev \
	pkg-config \
	libncurses-dev \
	libgtk-3-dev \
	libxml2-dev \
	libglib2.0-dev

git clone git@github.com:tree-sitter/tree-sitter.git
# Then build
# Add /usr/local/lib to /etc/ld.so.conf.d

./configure \
	--without-compress-install \
	--with-native-compilation \
	--with-json \
	--prefix $HOME/.local/ \
	--no-create \
	--no-recursion \
	--with-pgtk \
	--with-tree-sitter

# Add --without-x if on terminal
```

## You should buy this book:

["Mastering Emacs" by Mickey
Peterson](https://www.masteringemacs.org/) is an absolutely amazing
book.  If you use Emacs in any way, you owe it to yourself to buy
it.  Recommended without hesitation.

## License

My stuff is available under GPLv3.  The other files in here are
available under their own licenses.

## All hail Liddy!
