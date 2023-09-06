;; just an experiment

(setq hydra_map '(("a" . hydra-apropos/body)
                  ("d" . hydra-dev/body)))

(defun x-hugh-try-shared-map-for-global-menu (item)
  "Split ITEM into car, cdr & set key appropriately."
  (interactive)
  (let ((key (format "C-c %s" (car item)))
	(func (cdr item)))
    (global-set-key (kbd key) func)))

(--map (x-hugh-try-shared-map-for-global-menu it) hydra_map)

(defun x-hugh-try-shared-map-for-hydra-menu (a_map)
  "Try building a hydra map out of the whole thing."
  (interactive)
  (list (--map (list (car it) (cdr it) "bar")
	     a_map)))

(x-hugh-try-shared-map-for-hydra-menu hydra_map)

