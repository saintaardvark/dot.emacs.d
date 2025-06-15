;;; -*- lexical-binding: t -*-
;;; x-hugh-packages -- foo

;;; Commentary:

;;; Code:

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

(provide 'x-hugh-packages)
;;; x-hugh-packages.el ends here
