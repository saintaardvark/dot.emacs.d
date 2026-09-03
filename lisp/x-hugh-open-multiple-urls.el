;;; -*- lexical-binding: t -*-
;;; x-hugh-open-multiple-urls --- open every URL in the region, one tab each

;;; Commentary:
;; Highlight a region full of links, and `x-hugh-open-multiple-urls'
;; hands each URL it finds to `browse-url'.  Duplicates are dropped,
;; order is kept, and anything over
;; `x-hugh-open-multiple-urls-confirm-threshold' asks first so a stray
;; region doesn't open forty tabs.

;;; Code:

(require 'browse-url)
(require 'seq)
(require 'thingatpt)

(defgroup x-hugh-open-multiple-urls nil
  "Open all the URLs in a region."
  :group 'browse-url)

(defcustom x-hugh-open-multiple-urls-confirm-threshold 5
  "Ask before opening more than this many URLs at once.
Set to nil to never ask."
  :type '(choice integer (const :tag "Never ask" nil))
  :group 'x-hugh-open-multiple-urls)

(defcustom x-hugh-open-multiple-urls-delay 0.2
  "Seconds to wait between calls to `browse-url'.
Some browsers drop tabs when several requests arrive at once.  Set
to 0 to fire them off as fast as Emacs can."
  :type 'number
  :group 'x-hugh-open-multiple-urls)

(defcustom x-hugh-open-multiple-urls-regexp
  (if (boundp 'browse-url-button-regexp)
      browse-url-button-regexp
    thing-at-point-url-regexp)
  "Regexp matching a URL in the region."
  :type 'regexp
  :group 'x-hugh-open-multiple-urls)

(defun x-hugh-open-multiple-urls-collect (beg end)
  "Return the distinct URLs between BEG and END, in the order found."
  (let (urls)
    (save-excursion
      (goto-char beg)
      (while (re-search-forward x-hugh-open-multiple-urls-regexp end t)
        (push (match-string-no-properties 0) urls)))
    (delete-dups (nreverse urls))))

(defun x-hugh-open-multiple-urls (beg end)
  "Open every URL between BEG and END in the browser, one tab each.

Called interactively, BEG and END are the bounds of the region.
Duplicate URLs are opened only once.  If the region holds more
than `x-hugh-open-multiple-urls-confirm-threshold' URLs, ask for
confirmation first."
  (interactive "r")
  (unless (use-region-p)
    (user-error "No region: highlight some URLs first"))
  (let* ((urls (x-hugh-open-multiple-urls-collect beg end))
         (count (length urls)))
    (cond
     ((zerop count)
      (message "No URLs in region"))
     ((and x-hugh-open-multiple-urls-confirm-threshold
           (> count x-hugh-open-multiple-urls-confirm-threshold)
           (not (yes-or-no-p (format "Open %d URLs in the browser? " count))))
      (message "Not opening %d URLs" count))
     (t
      (seq-do-indexed
       (lambda (url i)
         (unless (zerop i)
           (sleep-for x-hugh-open-multiple-urls-delay))
         (browse-url url))
       urls)
      (message "Opened %d URL%s" count (if (= count 1) "" "s"))))))

(provide 'x-hugh-open-multiple-urls)
;;; x-hugh-open-multiple-urls.el ends here
