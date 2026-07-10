;;; -*- lexical-binding: t -*-
;;; x-hugh-gh-transient --- transient (magit-style) menu over the gh CLI

;;; Commentary:
;; A lightweight transient popup wrapping `gh pr create'.  It collects
;; flags via a menu and hands them to `x-hugh-gpc' (in x-hugh-magit.el),
;; so PR bodies still open inside the project with origin tracking.
;;
;; There is no GitHub API code here -- everything shells out to gh.
;;
;; Deliberately menu-only for shell-safe flags (booleans, branch names,
;; comma-separated identifiers).  Free text -- the PR title and body --
;; is NOT collected here: with the editor flow gh takes the first line
;; of the buffer as the title and the rest as the body, so there is
;; nothing to shell-quote and nothing to get wrong.

;;; Code:

(require 'transient)

(declare-function x-hugh-gpc "x-hugh-magit" (&optional extra-args))

(defun x-hugh-gh-pr-create (&optional args)
  "Run `gh pr create' with ARGS collected from the `x-hugh-gh-pr' transient.
ARGS is a list of shell-safe gh flags."
  (interactive (list (transient-args 'x-hugh-gh-pr)))
  (x-hugh-gpc args))

(transient-define-prefix x-hugh-gh-pr ()
  "Create a GitHub pull request with gh.
With no title/body flags, gh opens the body in an editor buffer via
`x-hugh-gpc'; the buffer's first line becomes the PR title."
  ["Flags"
   ("-d" "Draft" "--draft")
   ("-f" "Fill title/body from commits" "--fill")
   ("-w" "Finish in web browser" "--web")]
  ["Arguments"
   ("-b" "Base branch" "--base=")
   ("-H" "Head branch" "--head=")
   ("-r" "Reviewers (comma-separated)" "--reviewer=")
   ("-a" "Assignees (comma-separated)" "--assignee=")
   ("-l" "Labels (comma-separated)" "--label=")]
  ["Actions"
   ("c" "Create" x-hugh-gh-pr-create)])

(provide 'x-hugh-gh-transient)
;;; x-hugh-gh-transient.el ends here
