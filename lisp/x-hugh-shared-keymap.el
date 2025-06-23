;;; -*- lexical-binding: t -*-
;; just an experiment

;; Goal: be able to define something like this...
(setq hydra_map '(("a" . hydra-apropos/body)
                  ("d" . hydra-dev/body)))

;; ...and be able to use that for both the global keymap:

(global-set-key (kbd "C-c a") 'hydra-apropos/body)
(global-set-key (kbd "C-c d") 'hydra-dev/body)

;; ...and the hydra main menu:

(defhydra hydra-menu (:exit t)
  "menu"
  ("a" hydra-apropos/body "apropos")
  ("d" hydra-dev/body "dev")
  )

;; This seems to do well for the global keymap:
(defun x-hugh-try-shared-map-for-global-menu (item)
  "Split ITEM into car, cdr & set key appropriately."
  (interactive)
  (let ((key (format "C-c %s" (car item)))
	(func (cdr item)))
    (global-set-key (kbd key) func)))

;; ...when passed through --map:
(--map (x-hugh-try-shared-map-for-global-menu it) hydra_map)

;; So the next step is getting hydra-menu defined.
;;
;; This seems to be harder.  I've tried a few different things here.
;;
;; This is awful, but does allow me to get the hydra name; that's one
;; part of the whole process.:
;;
;; Oh, so awful.  Should get the function name directly.
;; Failing that, should use a regex here.
(defun x-hugh-get-hydra-name (full-name)
  (let ((foo (format "%s" full-name)))
    (format "%s" (cdr (split-string (car (split-string foo "/" )) "-")))))

;; this is another attempt.  here, i'm generating the entries that go
;; in the middle of `defhydra`:

(defun x-hugh-try-shared-map-for-hydra-menu (a_map)
  "try building a hydra map out of the whole thing."
  (interactive)
  (--map (list (car it) (cdr it) "bar")
	 a_map))

(x-hugh-try-shared-map-for-hydra-menu hydra_map)
;; output of that:
;; ("a" hydra-apropos/body "bar")
;; ("d" hydra-dev/body "bar")

;; next, i'm trying to find a different way to get the hydra name:


;; This next part does not work; the defhydra call returns an error:
;; Debugger entered--Lisp error: (wrong-type-argument sequencep take)
;; hydra--head-name((take 1000 (x-hugh-try-shared-map-for-hydra-menu hydra_map) :exit nil) hydra-menu-testing)
;; #f(compiled-function (name body &optional docstring &rest heads) "Create a Hydra - a family of functions with prefix NAME.\n\nNAME should be a symbol, it will be the prefix of all functions\ndefined here.\n\nBODY has the format:\n\n    (BODY-MAP BODY-KEY &rest BODY-PLIST)\n\nDOCSTRING will be displayed in the echo area to identify the\nHydra.  When DOCSTRING starts with a newline, special Ruby-style\nsubstitution will be performed by `hydra--format'.\n\nFunctions are created on basis of HEADS, each of which has the\nformat:\n\n    (KEY CMD &optional HINT &rest PLIST)\n\nBODY-MAP is a keymap; `global-map' is used quite often.  Each\nfunction generated from HEADS will be bound in BODY-MAP to\nBODY-KEY + KEY (both are strings passed to `kbd'), and will set\nthe transient map so that all following heads can be called\nthough KEY only.  BODY-KEY can be an empty string.\n\nCMD is a callable expression: either an interactive function\nname, or an interactive lambda, or a single sexp (it will be\nwrapped in an interactive lambda).\n\nHINT is a short string that identifies its head.  It will be\nprinted beside KEY in the echo erea if `hydra-is-helpful' is not\nnil.  If you don't even want the KEY to be printed, set HINT\nexplicitly to nil.\n\nThe heads inherit their PLIST from BODY-PLIST and are allowed to\noverride some keys.  The keys recognized are :exit, :bind, and :column.\n:exit can be:\n\n- nil (default): this head will continue the Hydra state.\n- t: this head will stop the Hydra state.\n\n:bind can be:\n- nil: this head will not be bound in BODY-MAP.\n- a lambda taking KEY and CMD used to bind a head.\n\n:column is a string that sets the column for all subsequent heads.\n\nIt is possible to omit both BODY-MAP and BODY-KEY if you don't\nwant to bind anything.  In that case, typically you will bind the\ngenerated NAME/body command.  This command is also the return\nresult of `defhydra'." #<bytecode 0xae5476f17ba27c6>)(hydra-menu-testing (exit :t) "Testing menu" (take 1000 (x-hugh-try-shared-map-for-hydra-menu hydra_map)))
;; macroexpand((defhydra hydra-menu-testing (exit :t) "Testing menu" (take 1000 (x-hugh-try-shared-map-for-hydra-menu hydra_map))))
;; elisp--eval-last-sexp(nil)
;; eval-last-sexp(nil)
;; funcall-interactively(eval-last-sexp nil)
;; command-execute(eval-last-sexp)
;;
;; Arghhh, so close!  Somehow I need to pop out the enclosing list --
;; like you do in numpy with squeeze.
(defhydra hydra-menu-testing (exit :t)
  "Testing menu"
  ;; oh god this is ugly
  (take 1000 (x-hugh-try-shared-map-for-hydra-menu hydra_map))
  )
;; https://emacs.stackexchange.com/questions/12286/is-there-a-general-way-to-expand-a-list-for-to-be-used-as-individual-arguments
;; (cl-reduce)
;;
;; same link:
;; (apply #'concat '("foo" "bar" "baz"))

;; FIXME: Do I need to just give up and do a macro here?


(defmacro x-hugh-build-hydra (var)
  `(defhydra hydra-menu-testing (exit :t)
	"Testing menu"
	;; oh god this is ugly
	(x-hugh-try-shared-map-for-hydra-menu ,var)))
(x-hugh-build-hydra hydra_map)

(defmacro x-hugh-foo (var)
  (defhydra hydra-foo (exit :t) "foo")
'(+ 1 2)

(hydra-menu-testing)
