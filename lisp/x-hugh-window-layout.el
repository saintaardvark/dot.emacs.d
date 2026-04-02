;; An experiment based on
;; https://www.masteringemacs.org/article/demystifying-emacs-window-manager

(setq switch-to-buffer-obey-display-actions t)
(setq switch-to-buffer-in-dedicated-window "pop")
(window-tree)
(defun mp-toggle-window-dedication ()
  "Toggles window dedication in the selected window."
  (interactive)
  (set-window-dedicated-p (selected-window)
     (not (window-dedicated-p (selected-window)))))
;; left, top, right, bottom
(setq window-sides-slots '(0 1 0 0))

(add-to-list 'display-buffer-alist
          `(,(rx (| "*compilation*" "*grep*"))
            display-buffer-in-side-window
            (side . right)
            (slot . 0)
            (window-parameters . ((no-delete-other-windows . t)))
            (window-width . 80)))

;; Required. But note that this _does_ change Magit's default buffer display behavior.
(setq magit-display-buffer-function #'display-buffer)

(add-to-list 'display-buffer-alist
          `((derived-mode . magit-mode)
            (display-buffer-reuse-mode-window
             display-buffer-in-side-window)
            (mode magit-mode)
            (window . root)
            (window-width . 0.15)
            (direction . left)))

(display-buffer-alist)
