;; x-hugh-02-confluence.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; confluence editing support (with longlines mode)

(setq load-path  (cons (expand-file-name "~/.emacs.d/confluence-el") load-path))

;; Note:  we autoload to speed Emacs startup.  Use C-xwf (get page) to trigger actual load.

;; Note: Will barf on versions earlier than 23. I've taken out the
;; test for that on the assumption that I just don't have that many
;; copies earlier than that.

(setf confluence-url "http://www.chibi.ubc.ca/faculty/pavlidis/wiki/rpc/xmlrpc")
(setf confluence-default-space-alist (list (cons confluence-url "Pavlab")))

(autoload 'confluence-get-page "confluence" nil t)

(eval-after-load "confluence"
  '(progn
     (require 'longlines nil 'noerror)
     (progn
       (add-hook 'confluence-mode-hook 'longlines-mode)
       (add-hook 'confluence-before-save-hook 'longlines-before-revert-hook)
       (add-hook 'confluence-before-revert-hook 'longlines-before-revert-hook)
       (add-hook 'confluence-mode-hook '(lambda () (local-set-key "\C-j" 'confluence-newline-and-indent))))))

;; setup confluence mode
(add-hook 'confluence-mode-hook
          '(lambda ()
             (local-set-key "\C-xw" confluence-prefix-map)))

;; See x-hugh-keymap.el for keymap settings

(provide 'x-hugh-confluence)
