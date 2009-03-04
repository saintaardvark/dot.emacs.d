;;; twiki-outline.el --- major mode for editing twiki documents

;; Copyright (C) 2004 Noah S. Friedman

;; Author: Noah Friedman <friedman@splode.com>
;; Created: 2004-04-21

;; $Id: twiki-outline.el,v 1.1 2004/04/26 19:15:35 friedman Exp $

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 59 Temple Place, Suite 330; Boston, MA 02111-1307, USA.

;; Commentary:

;; twiki is a free web collaboration platform, http://twiki.org/

;; This mode currently implements outline highlighting and toggling display
;; of html tags, which are sometimes necessary for markup but make outlines
;; harder to read.

;; This mode works best in Emacs 21.  It works with some degradation of
;; functionality in Emacs 20.  I'm not sure about Emacs 19, and I have not
;; tested with XEmacs.

;; TODO: defcustomize, document

;; Code:

(require 'outline)

(defvar twiki-outline-regexp "---+\\++ \\|\\(\\(?:   \\)+\\)[0-9*] ")

(defvar twiki-outline-html-tag-face 'twiki-outline-html-tag-face
  "Font Lock mode face used to highlight HTML tags in twiki-outline mode.")

(defface twiki-outline-html-tag-face
    '((t :inherit font-lock-string-face))
    "Font Lock mode face used to highlight HTML tags in twiki-outline mode.")

(defvar twiki-outline-hide-html-tags t)

(defvar twiki-outline-font-lock-keywords
  '(("---+\\++ .*\\|\\(\\(?:   \\)+\\)[0-9*] .*\\(?:\n\\1 +[^ %0-9*\n].*\\)*"
     0 (twiki-outline-choose-face) nil t)
    ("<[^\>]*>"
     0 '(face           twiki-outline-html-tag-face
         invisible      twiki-outline-html-tag
         read-only      twiki-outline-html-tag
         front-sticky   nil
         rear-nonsticky t)
     t t)))

(defvar twiki-outline-faces
  [font-lock-warning-face
   font-lock-function-name-face
   font-lock-variable-name-face
   font-lock-keyword-face
   font-lock-builtin-face
   font-lock-comment-face
   font-lock-constant-face
   font-lock-type-face
   font-lock-string-face
   font-lock-doc-face
   font-lock-preprocessor-face])

(defun twiki-outline-level ()
  (let ((count 1)
        (outline-level 'outline-level))
    (save-excursion
      (outline-back-to-heading t)
      (while (and (not (bobp))
                  (not (eq (outline-level) 1)))
        (outline-up-heading 1)
        (or (bobp)
            (setq count (1+ count))))
      count)))

(defun twiki-outline-choose-face ()
  (let ((face (aref twiki-outline-faces
                    (% (funcall outline-level)
                       (length twiki-outline-faces)))))
    (if (facep face)
        face
      (aref twiki-outline-faces 0))))

;;;###autoload
(defun twiki-outline-toggle-html (&optional prefix)
  (interactive "P")
  (setq twiki-outline-hide-html-tags
        (if prefix
            (>= (prefix-numeric-value prefix) 0)
          (not twiki-outline-hide-html-tags)))

  (cond (twiki-outline-hide-html-tags
         (add-to-list 'buffer-invisibility-spec 'twiki-outline-html-tag)
         (when (listp inhibit-read-only)
           (setq inhibit-read-only
                 (delq 'twiki-outline-html-tag inhibit-read-only))))
        (t
         (setq buffer-invisibility-spec
               (delq 'twiki-outline-html-tag buffer-invisibility-spec))
         (when (listp inhibit-read-only)
           (add-to-list 'inhibit-read-only 'twiki-outline-html-tag))))

  (and (interactive-p)
       (if twiki-outline-hide-html-tags
           (message "Hiding HTML tags")
         (message "Displaying HTML tags"))))

;;;###autoload
(define-derived-mode twiki-outline-mode outline-mode "TwikiOutline" nil
  (make-local-variable 'outline-regexp)
  (setq outline-regexp twiki-outline-regexp)

  (make-local-variable 'outline-level)
  (setq outline-level 'twiki-outline-level)

  (setcar font-lock-defaults 'twiki-outline-font-lock-keywords)

  (make-local-variable 'inhibit-read-only)
  (setq inhibit-read-only nil)

  (twiki-outline-toggle-html twiki-outline-hide-html-tags)

  (make-local-variable 'font-lock-extra-managed-props)
  (setq font-lock-extra-managed-props '(invisible)))

(provide 'twiki-outline)

;;; twiki-outline.el ends here.
