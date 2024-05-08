(use-package flymake
  :ensure nil
  :init
  (define-globalized-minor-mode global-flymake-mode flymake-mode
    (lambda () (flymake-mode t)))
  :custom
  (flymake-show-diagnostics-at-end-of-line t)
  :config
  (global-flymake-mode))
