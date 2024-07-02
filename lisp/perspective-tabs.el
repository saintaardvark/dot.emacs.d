;;; perspective-tabs.el --- shows perspectives as tabs in the tab-bar  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Geert Vermeiren <geertv@surfspot.be>

;; Author: Geert Vermeiren <geertv@surfspot.be>
;; URL: http://github.com/nex3/perspective-el

;; Package-Requires: ((emacs "27.1") (perspective "2.18") (cl-lib "0.5"))
;; Version: 0.1
;; Created: 2023-02-15
;; By: Geert Vermeiren <geertv@surfspot.be>
;; Keywords: workspace, convenience, frames, tab-bar

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;;; Commentary:

;; This package provides a minor-mode that will show the tagged workspaces
;; from Perspective as tabs in the built-in tab-bar. Clicking on those tabs
;; will switch between perspectives.


;;; Code:

(require 'map)
(require 'tab-bar nil t)

(eval-when-compile
  (require 'perspective nil t))

(defvar perspective-tabs-saved-settings
  '((tab-bar-separator . nil)
    (tab-bar-close-button-show . nil)
    (tab-bar-tabs-function . nil))
  "Settings saved from before `perspective-tabs-mode' was activated.
Used to restore them when the mode is disabled.")

(defun perspective-tabs-function (&optional frame)
  "Return a list of perspective tabs in FRAME.
FRAME defaults to the current frame."
  (let ((perspectives (perspectives-hash frame))
        (persp-current-name (persp-current-name)))
    (mapcar (lambda (persp-name)
              (list
               (if (string= persp-name persp-current-name) 'current-tab 'tab)
               (cons 'name persp-name)
               (cons 'perspective (gethash persp-name perspectives))))
            (persp-names))))

(defun perspective-tabs-select-tab (&optional arg)
  "Set the frame's perspective to the selected tab's perspective.
ARG is the position of the perspective in the tab bar."
  ;; modeled on/copied from `bufler-workspace-tabs--tab-bar-select-tab'.
  (interactive "P")
  (unless (integerp arg)
    (let ((key (event-basic-type last-command-event)))
      (setq arg (if (and (characterp key) (>= key ?1) (<= key ?9))
                    (- key ?0)
                  1))))
  (let* ((tabs (funcall tab-bar-tabs-function))
         (from-index (tab-bar--current-tab-index tabs))
         (to-index (1- (max 1 (min arg (length tabs))))))
    (unless (eq from-index to-index)
      (let* ((_from-tab (tab-bar--tab))
             (to-tab (nth to-index tabs))
             (perspective (alist-get 'perspective to-tab)))
        (persp-activate perspective)
        (force-mode-line-update 'all)))))

(defun perspective-tabs-close-tab (&optional arg)
  "Close a perspective. Called from tab-bar code and icons.
ARG is the position of the perspective in the tab bar."
  ;; riffing on :) from `bufler-workspace-tabs--tab-bar-select-tab'.
  (interactive "P")
  (unless (integerp arg)
    (let ((key (event-basic-type last-command-event)))
      (setq arg (if (and (characterp key) (>= key ?1) (<= key ?9))
                    (- key ?0)
                  1))))
  (let* ((tabs (funcall tab-bar-tabs-function))
         (kill-index (1- (max 1 (min arg (length tabs)))))
         (kill-tab (nth kill-index tabs))
         (perspective-name (alist-get 'name kill-tab)))
    (if (= 1 (length tabs))
        (delete-frame)
      (persp-kill perspective-name))
    (force-mode-line-update 'all)))

(defun perspective-tabs-new (&optional arg)
  "Create a new perspective.
ARG is just here to be compatible with the function `tab-bar-new-tab-to'."
  (interactive "i")
  (persp-activate (persp-new (persp-prompt))))

;; (defvar-keymap perspective-tabs-map
;;   :doc "Keymap to navigate perspectives when they are shown as tabs.
;; Unuseful keys have been omitted."
;;   "0" #'tab-close
;;   "2" #'tab-new
;;   "o" #'tab-next
;;   "O" #'tab-previous
;;   "r" #'tab-rename
;;   "RET" #'tab-switch
;;   )

;;;###autoload
(define-minor-mode perspective-tabs-mode
  "Use tabs to show and manage perspectives."
  :group 'perspective-tabs
  :global t
  (if perspective-tabs-mode
      ;; activate
      (progn
        (unless (version<= "27.1" emacs-version)
          (user-error "`perspective-tabs-mode' requires Emacs version 27.1 or later"))
        (unless (bound-and-true-p persp-mode)
          (user-error "`perspective-tabs-mode' requires perspective (`persp-mode') to be active"))
        ;; Save settings
        (message "settings: %s" perspective-tabs-saved-settings)
        (cl-loop for (symbol . _value) in perspective-tabs-saved-settings
                 do (setf (map-elt perspective-tabs-saved-settings symbol)
                          (symbol-value symbol)))
        (advice-add 'tab-bar-select-tab :override #'perspective-tabs-select-tab)
        (advice-add 'tab-bar-switch-to-tab :override #'persp-switch)
        (advice-add 'tab-bar-new-tab-to :override #'perspective-tabs-new)
        (advice-add 'tab-bar-close-tab :override #'perspective-tabs-close-tab)
        (advice-add 'tab-bar-rename-tab :override #'persp-rename)
        (setf tab-bar-tabs-function #'perspective-tabs-function)
        (tab-bar-mode 1))
    ;;deactivate
    (advice-remove 'tab-bar-select-tab #'perspective-tabs-select-tab)
    (advice-remove 'tab-bar-switch-to-tab #'persp-switch)
    (advice-remove 'tab-bar-new-tab-to #'perspective-tabs-new)
    (advice-remove 'tab-bar-close-tab #'perspective-tabs-close-tab)
    (advice-remove 'tab-bar-rename-tab #'persp-rename)
    ;; Restore settings.
    (cl-loop for (symbol . value) in perspective-tabs-saved-settings
             do (set symbol value)
             do (setf (map-elt perspective-tabs-saved-settings symbol) nil))
    (tab-bar-mode -1))
  (force-mode-line-update 'all))

(provide 'perspective-tabs)
;;; perspective-tabs.el ends here
