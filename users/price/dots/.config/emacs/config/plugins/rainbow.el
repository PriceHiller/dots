;;; -*- lexical-binding: t -*-
;;; Colorize color names and delims

;; Set background colors for color codes
(use-package rainbow-mode
  :init
  (define-globalized-minor-mode global-rainbow-mode rainbow-mode
    (lambda () (rainbow-mode t)))
  :config

  (global-rainbow-mode t))

(use-package rainbow-delimiters
  :init
  (define-globalized-minor-mode global-rainbow-delimiters-mode rainbow-delimiters-mode
    (lambda () (rainbow-delimiters-mode t)))
  :config
  (global-rainbow-delimiters-mode t))


