(use-package ivy
  :diminish
  :init
  (ivy-mode 1))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1)
  :config
  (setq all-the-icons-rich-icon t)
  (setq all-the-icons-ivy-rich-color-icon t))

(use-package ivy-rich
     :ensure t
     :init
     (ivy-rich-mode 1))

(use-package all-the-icons-completion
    :init
    (all-the-icons-completion-mode 1))

(all-the-icons-completion-mode)

(use-package swiper
    :config
    (general-define-key
      :states 'normal
      "/" 'swiper))
;
(provide 'init-ivy)
