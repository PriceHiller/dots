(use-package indent-bars
  :ensure (:host github
                 :depth 1
                 :repo "jdtsmith/indent-bars")
  :init
  (define-globalized-minor-mode global-indent-bars-mode indent-bars-mode
    (lambda () (indent-bars-mode t)))
  :custom
  (indent-bars-starting-column 0)
  (indent-bars-pad-frac 0.2)
  (indent-bars-treesit-support t)
  (indent-bars-pattern ".")
  (indent-bars-display-on-blank-lines nil)
  (indent-bars-width-frace 0.2)
  :config
  (global-indent-bars-mode t))
