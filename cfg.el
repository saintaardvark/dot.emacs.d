;;; cfg --- My functions for Chef, rewritten as macros.  -*- lexical-binding: t; -*-

;;; Commentary:
;;; Might as well put them some place...

;;; FIXME: Have a difference between *open* (either find-file or
;;; dired; interactive), and *return* (which will return the full path
;;; to whatever; *not* interactive).

;;; Code:

;; Expansion:
;; (custom-declare-group 'cfg-chef-custom nil
;;                       "Customization group for cfg-chef"
;;                       :group 'convenience
;;                       :group 'navigation)
(defmacro cfg-custom-group (toolname)
  "Establish customization group for (TOOLNAME)."
  (let ((customsymbol (intern (concat "cfg-" toolname "-custom")))
        (docstring (concat "Customization group for cfg-" toolname)))
    `(defgroup ,customsymbol nil
       ,docstring
       :group 'convenience
       :group 'navigation)))

;; Replaces x-hugh-chef-cookbook-directory
;; Expansion:
;; (custom-declare-variable 'cfg-chef-cookbook-directory 'nil
;;                          "Where chef cookbooks are kept locally."
;;                          :type 'directory
;;                          :group 'cfg-chef-custom)
(defmacro cfg-custom-dir-setting (toolname dirtype)
  "Add cfg-(TOOLNAME)-(DIRTYPE)-directory custom var."
  (let ((customsymbol (intern (concat "cfg-" toolname "-" dirtype "-directory")))
        (groupname (intern (concat "cfg-" toolname "-custom")))
        (docstring (concat "Where " toolname " " dirtype "s are kept locally.")))
    `(defcustom ,customsymbol nil
       ,docstring
       :type 'directory
       :group ',groupname)))

(defmacro cfg-funsymbol (args)
  "Handy funsymbol macro to turn (ARGS) into funsymbol."
  `(setq funsymbol (intern (concat ,@args))))

;; cfg-return-name
(defmacro cfg-dirtype-return-name (toolname dirtype)
  "Create a defun named cfg-(TOOLNAME)-return-name-of-(DIRTYPE)."
  (let ((funsymbol (intern (concat "cfg-" toolname "-return-name-of-" dirtype)))
        (docstring (format "Return name of %s given PATH-OR-BUFFER.

       Name of %s is last directory component.  Example:
       (chef-%s-return-name-of-%s \"/path/to/%s\") returns \"%s\".

       Noninteractive." dirtype dirtype toolname dirtype dirtype dirtype))
        (toolname-root (intern (concat "cfg-" toolname "-" dirtype "-directory")))
        )
    `(defun ,funsymbol (path-or-buffer)
       ,docstring
       (when path-or-buffer
         (if (bufferp path-or-buffer)
            (when (string-match
                   (format "^%s" ,toolname-root)
                   (or (buffer-file-name)
                       (expand-file-name default-directory)))
              (car
               (split-string
                (replace-match "" nil nil (or (buffer-file-name)
                                              (expand-file-name default-directory)))
                "/" t)))
           (progn
             (when (string-match (format "^%s" ,toolname-root) path-or-buffer)
               (car (split-string (replace-match "" nil nil path-or-buffer) "/" t)))))))))

(defmacro cfg-dirtype-return-path (toolname dirtype)
  "Create a defun named cfg-(TOOLNAME)-return-path-to-(DIRTYPE)."
  (let ((funsymbol (intern (concat "cfg-" toolname "-return-path-to-" dirtype)))
        (docstring (format "Return path to %s given NAME-OR-BUFFER." dirtype))
        (toolname-root (intern (concat "cfg-" toolname "-" dirtype "-directory"))))
    `(defun ,funsymbol (name-or-buffer)
       ,docstring
       (when name-or-buffer
         (if (bufferp name-or-buffer)
             (when
                 (string-match
                  (format "^%s/+" ,toolname-root)
                  (buffer-file-name))
               (format "%s/%s" ,toolname-root
                       (car
                        (split-string
                         (replace-match "" nil nil (buffer-file-name))
                         "/"))))
           (progn
             (when (file-directory-p (format "%s/%s" ,toolname-root name-or-buffer))
               (expand-file-name name-or-buffer ,toolname-root))))))))

;; Replaces: (defun x-hugh-chef-open-cookbook-dir ())
;; FIXME: The way this is built right now, it assumes that the helper function for
;; format is interactive.
;; Expansion:
;; (defalias 'cfg-chef-return-cookbook-dir
;;   #'(lambda nil "Return the directory of a cookbook; suitable for dired."
;;       (file-truename
;;        (format "%s/%s" cfg-chef-cookbook-directory
;;                (cfg-chef-get-cookbook)))))
(defmacro cfg-return-dirtype-dir (toolname dirtype)
  "Create a defun named cfg-(TOOLNAME)-return-(DIRTYPE)-dir.

The defun is not interactive in itself, but right now it calls an interactive
defun that prompts for completion of the dirtype.

Example:

\(cfg-chef-return-cookbook-dir\)
;; Prompts for completion
;; Returns: \"/Users/hubrown/gh/Chef-testing/syseng_collins\"."
  (let ((funsymbol (intern (concat "cfg-" toolname "-return-" dirtype "-dir")))
        (toolname-root (intern (concat "cfg-" toolname "-" dirtype "-directory")))
        (cfg-get-unit-defun (intern (concat "cfg-" toolname "-get-" dirtype)))
        (docstring (format "Return the directory of a %s; suitable for dired." dirtype)))
    `(defun ,funsymbol ()
       ,docstring
       (file-truename (format "%s/%s"
                              ,toolname-root
                              (,cfg-get-unit-defun))))))

(defmacro cfg-prompt-for-dirtype-name (toolname dirtype)
  "Create a defun named cfg-(TOOLNAME)-prompt-for-(DIRTYPE).

The defun will be interactive, prompting for the name of a
cookbook; it will return the *name* of a unit.  Example:

\(cfg-chef-prompt-for-cookbook\)
; \"completing-read\", starting in cfg-chef-cookbook-directory
; Returns: \"syseng_collins\""
  (let ((funsymbol (intern (concat "cfg-" toolname "-prompt-for-" dirtype)))
        (default-dirtype-helper (intern (concat "cfg-" toolname "-return-name-of-" dirtype)))
        (toolname-root (intern (concat "cfg-" toolname "-" dirtype "-directory")))
        (default-dirtype (intern (concat "default-" dirtype)))
        (docstring (format "Prompts for name of cookbook; return %s name for further action.

Starts in %s root directory.
If ``current-buffer'' is for file within a %s, that %s is offered as a default."
                           dirtype
                           dirtype
                           dirtype
                           dirtype))
        (prompt (concat (capitalize dirtype) ": ")))
    `(defun ,funsymbol ()
       ,docstring
       (interactive)
       (let ((,default-dirtype (,default-dirtype-helper (buffer-file-name))))
         (completing-read ,prompt
                          (directory-files ,toolname-root)
                          nil nil ,default-dirtype)))))

(defmacro cfg-dired-dirtype-interactive (toolname dirtype)
  "Create a defun named cfg-(TOOLNAME)-open-(DIRTYPE)-dir-interactive.

The defun will be interactive, prompting for the name of a
cookbook; it will run dired in that cookbook\'s directory.  Example:

cfg-chef-dired-cookbook-interactive
; user types in \"syseng_collins\"
; Runs dired in cfg-chef-cookbook-directory/\"syseng_collins\""
  (let ((funsymbol (intern (concat "cfg-" toolname "-dired-" dirtype "-interactive")))
        (promptfun (intern (concat "cfg-" toolname "-prompt-for-" dirtype)))
        (pathfun (intern (concat "cfg-" toolname "-return-path-to-" dirtype)))
        (docstring "Prompt for cookbook and open in dired."))
    `(defun ,funsymbol ()
       ,docstring
       (interactive)
       (dired (,pathfun (,promptfun))))))

(defmacro cfg-return-name-of-filetype (toolname dirtype filetype)
  "Create a defun named cfg-(TOOLNAME)-return-name-of-(FILETYPE).  Uses (DIRTYPE) too."
  (let ((funsymbol (intern (concat "cfg-" toolname "-return-name-of-" filetype)))
        (toolname-root (intern (concat "cfg-" toolname "-" dirtype "-directory")))
        (plural-filetype (concat filetype "s"))
        (docstring (format "Return name of %s given PATH-OR-BUFFER." filetype)))
    `(defun ,funsymbol (path-or-buffer)
       ,docstring
       (when path-or-buffer
         (if (bufferp path-or-buffer)
             (when
                 (string-match
                  (format "^%s\\/+.*\\/%s/+" ,toolname-root ,plural-filetype)
                  (or (buffer-file-name) "nil"))
               (car (split-string (replace-match "" nil nil (buffer-file-name)) "/")))
           (progn
             (when (string-match (format "^%s" ,toolname-root) path-or-buffer)
               (car
                (last
                 (split-string
                  (replace-match "" nil nil path-or-buffer)
                  "/"))))))))))

(defmacro cfg-return-path-of-filetype (toolname dirtype filetype &optional path)
  "Create a defun named cfg-(TOOLNAME)-return-path-of-(FILETYPE).  Uses (DIRTYPE) too.

If (PATH) is provided, use that as the path under (DIRTYPE) to (FILETYPE); otherwise, append \"s\" to make it plural.

Example:
\(cfg-return-path-of-filetype \"chef\" \"cookbook\" \"recipe\")
-- will look for recipe in \"recipes\" directory.
\(cfg-return-path-of-filetype \"chef\" \"cookbook\" \"spec\" \"spec/unit/recipes\")
-- will look for spec in \"spec/unit/recipes\" directory."
  (let ((funsymbol (intern (concat "cfg-" toolname "-return-path-of-" filetype)))
        (toolname-root (intern (concat "cfg-" toolname "-" dirtype "-directory")))
        (path-to-filetype (if (stringp path)
                              path
                            (concat filetype "s")))
        (dirsymbol (intern dirtype))
        (filesymbol (intern filetype))
        (docstring (format "Return full path of %s in %s. Does not check for existence" filetype dirtype)))
    `(defun ,funsymbol (,filesymbol ,dirsymbol)
       ,docstring
       ;; FIXME: Use a join here or some such.
       (format "%s/%s/%s/%s" ,toolname-root ,dirsymbol ,path-to-filetype ,filesymbol))))

(defmacro cfg-prompt-for-filetype-name (toolname dirtype filetype)
  "Create a defun named cfg-(TOOLNAME)-prompt-for-(FILETYPE)-name.  Uses (DIRTYPE) too.

The defun will be interactive, prompting for the name of an existing recipe file
within a cookbook; it will return the *name* of a unit."
  (let ((funsymbol (intern (concat "cfg-" toolname "-prompt-for-" filetype "-name")))
        (toolname-root (intern (concat "cfg-" toolname "-" dirtype "-directory")))
        (dirsymbol (intern dirtype))
        (plural-filetype (concat filetype "s"))
        (prompt (concat (capitalize filetype) ": "))
        (docstring (format "Prompt for name of %s within %s." filetype dirtype)))
    `(defun ,funsymbol (,dirsymbol)
       ,docstring
       (interactive)
       (completing-read ,prompt
                        (directory-files
                         (format "%s/%s/%s" ,toolname-root ,dirsymbol ,plural-filetype))
                        nil nil))))

(defmacro cfg-open-filetype (toolname dirtype filetype)
  "Create a defun named cfg-(TOOLNAME)-open-(FILETYPE).  Uses (DIRTYPE) too."
  (let ((funsymbol (intern (concat "cfg-" toolname "-open-" filetype)))
        (filetype-path-helper (intern (concat "cfg-" toolname "-return-path-of-" filetype)))
        (filetype-prompter (intern (concat "cfg-" toolname "-prompt-for-" filetype "-name")))
        (dirtype-prompter (intern (concat "cfg-" toolname "-prompt-for-" dirtype)))
        (dirsymbol (intern dirtype))
        (docstring (format "Prompt for, then open, %s within %s.

If within %s, offer that as default." filetype dirtype dirtype)))
    `(defun ,funsymbol ()
       ,docstring
       (interactive)
       (let ((,dirsymbol (,dirtype-prompter)))
         (find-file
          (,filetype-path-helper (,filetype-prompter ,dirsymbol) ,dirsymbol))))))

(defmacro cfg-setup (tool dirtype filetype)
  "Set up cfg for a TOOL from DIRTYPE and FILETYPE."
  `(progn
     (cfg-custom-group ,tool)
     (cfg-custom-dir-setting ,tool ,dirtype)
     (cfg-dirtype-return-name ,tool ,dirtype)
     (cfg-dirtype-return-path ,tool ,dirtype)
     (cfg-return-dirtype-dir ,tool ,dirtype)
     (cfg-prompt-for-dirtype-name ,tool ,dirtype)
     (cfg-dired-dirtype-interactive ,tool ,dirtype)
     (cfg-return-path-of-filetype ,tool ,dirtype ,filetype)
     (cfg-return-name-of-filetype ,tool ,dirtype ,filetype)
     (cfg-prompt-for-filetype-name ,tool ,dirtype ,filetype)
     (cfg-open-filetype ,tool ,dirtype ,filetype)))

(cfg-setup "chef" "cookbook" "recipe")
(cfg-setup "puppet" "module" "manifest")

(defmacro cfg-setup-files-only (tool dirtype filetype)
  "Set up cfg for a TOOL from DIRTYPE and FILETYPE.  Only the filetypes though..."
     (cfg-return-path-of-filetype ,tool ,dirtype ,filetype)
     (cfg-return-name-of-filetype ,tool ,dirtype ,filetype)
     (cfg-prompt-for-filetype-name ,tool ,dirtype ,filetype)
     (cfg-open-filetype ,tool ,dirtype ,filetype))

;; Not working...
;; (cfg-setup-files-only "chef" "cookbook" "attribute")
;; (cfg-setup-files-only "chef" "cookbook" "spec")
(cfg-return-path-of-filetype "chef" "cookbook" "attribute")
(cfg-return-name-of-filetype "chef" "cookbook" "attribute")
(cfg-prompt-for-filetype-name "chef" "cookbook" "attribute")
(cfg-open-filetype "chef" "cookbook" "attribute")
(cfg-return-path-of-filetype "chef" "cookbook" "spec" "spec/unit/recipes")
(cfg-return-name-of-filetype "chef" "cookbook" "spec")
(cfg-prompt-for-filetype-name "chef" "cookbook" "spec")
(cfg-open-filetype "chef" "cookbook" "spec")

;; (defmacro cfg-two-windows (tool dirtype f1 f2)
;;   "Create two windows for (TOOL) (DIRTYPE) (F1) and (F2)."
;;   (let ((funsymbol (intern (concat "cfg-" toolname "-open-" f1 "-and-" f2)))
;;         (docstring "Open two recipe and spec file side by side.")
;;         (f1-path-helper (intern (concat "cfg-" toolname "-return-path-of-" f1)))
;;         (f1-prompter (intern (concat "cfg-" toolname "-prompt-for-" f2 "-name")))
;;         (f2-path-helper (intern (concat "cfg-" toolname "-return-path-of-" f2)))
;;         (dirsymbol (intern dirtype))
;;          ))
;;     `(defun ,funsymbol ()
;;        ,docstring
;;        (interactive)
;;        (let* ((recipe (,f1-path-helper (,f1-prompter ,dirsymbol) ,dirsymbol))
;;               (spec (,f2-path-helper (recipe))))
;;          (delete-other-windows)
;;          (get-buffer-create buf1)
;;     (split-window-right)
;;     (other-window 1)
;;     (get-buffer-create buf2))))


;; Until I get the multiple components thing working:

;; (defmacro cfg-setup-2 (tool dirtype &rest filetypes)
;;   "Set up cfg for a TOOL from DIRTYPE and (FILETYPES)."
;;   `(progn
;;      (cfg-custom-group ,tool)
;;      (cfg-custom-dir-setting ,tool ,dirtype)
;;      (cfg-dirtype-return-name ,tool ,dirtype)
;;      (cfg-dirtype-return-path ,tool ,dirtype)
;;      (cfg-return-dirtype-dir ,tool ,dirtype)
;;      (cfg-prompt-for-dirtype-name ,tool ,dirtype)
;;      (cfg-dired-dirtype-interactive ,tool ,dirtype)
;;      (dolist (f ,filetypes)
;;        (message f)
;;        (cfg-return-path-of-filetype ,tool ,dirtype f)
;;        (cfg-return-name-of-filetype ,tool ,dirtype f)
;;        (cfg-prompt-for-filetype-name ,tool ,dirtype f)
;;        (cfg-open-filetype ,tool ,dirtype f))))

;; (cfg-setup-2 "ansible" "playbooks" "variables" "secrets" "otherthings")

(provide 'cfg)
;;; cfg.el ends here
