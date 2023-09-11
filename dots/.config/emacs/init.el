;; Install elpaca
(defvar elpaca-installer-version 0.5)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
			      :ref nil
			      :files (:defaults (:exclude "extensions"))
			      :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
	(if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
		 ((zerop (call-process "git" nil buffer t "clone"
				       (plist-get order :repo) repo)))
		 ((zerop (call-process "git" nil buffer t "checkout"
				       (or (plist-get order :ref) "--"))))
		 (emacs (concat invocation-directory invocation-name))
		 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
				       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
		 ((require 'elpaca))
		 ((elpaca-generate-autoloads "elpaca" repo)))
	    (progn (message "%s" (buffer-string)) (kill-buffer buffer))
	  (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Elpaca use package support
(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed
(elpaca-wait)

;; General for keybindings
(use-package general
  :demand t)

(elpaca-wait)

(general-create-definer key-leader
  :prefix "SPC")

(general-create-definer key-local-leader
  :prefix ";")

(key-leader
  :states 'normal
  "/" '(comment-line :which-key "Comment: Toggle Current Line"))

(key-leader
  :states 'visual
  "/" '(comment-or-uncomment-region :which-key "Comment: Toggle Selected Lines"))

(key-leader
  :states '(normal visual)
  :keymaps 'emacs-lisp-mode-map
  "f" '(nil :which-key "File"))

(key-leader
  :states 'normal
  :keymaps 'emacs-lisp-mode-map
  "f r" '(eval-buffer :which-key "File: Evaluate"))

(key-leader
  :states 'visual
  :keymaps 'emacs-lisp-mode-map
  "f r" '(eval-region :which-key "File: Evaluate Region"))


;; Which key to hint key bindings
(use-package which-key
  :after evil
  :init
  (setq which-key-idle-delay 0.1)
  :config
  (which-key-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("d445c7b530713eac282ecdeea07a8fa59692c83045bf84dd112dd738c7bcad1d"
     default))
 '(tool-bar-mode nil))

;; Doom Themes
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package nerd-icons)
(use-package treemacs
  :defer t
  :after nerd-icons
  :config
  (use-package treemacs-nerd-icons)
  (use-package treemacs-evil)
  (treemacs-load-theme "nerd-icons")
  (setq treemacs-silent-refresh t
	treemacs-silent-filewatch t
	tree-file-event-delay 100))

;; Download Evil
(use-package goto-chg)
(use-package evil
  :after goto-chg
  :init
  (setq evl-kbd-macro-suppress-motion-error t
        evil-want-C-u-scroll t
        evil-want-integration t
        evil-want-keybinding 'nil
        which-key-allow-evil-operators t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package pdf-tools
  :config
  (pdf-tools-install)
  (defun pdf-tools-settings () )
  (add-hook 'pdf-tools-enabled-hook (lambda ()
                                      (pdf-view-themed-minor-mode)
                                      (display-line-numbers-mode -1))))
;; Configure Tempel
(use-package tempel
  :custom
  (tempel-trigger-prefix ">")
  :init
  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-complete
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))

(use-package tempel-collection
  :after tempel)

;; We do setup for hotfuzz in the orderless package
(use-package hotfuzz
  :elpaca (:host github
                 :depth 1
                 :repo "axelf4/hotfuzz"
                 :pre-build (("cmake" "-DCMAKE_C_FLAGS='-O3 -march=native'" ".") ("cmake" "--build" "."))))

(use-package orderless
  :after hotfuzz
  :custom
  (completion-ignore-case t)
  (completion-styles '(hotfuzz orderless))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion))))
  (orderless-matching-styles
   '(orderless-literal
     orderless-prefixes
     orderless-initialism)))

(use-package corfu
  :elpaca
  (:host github
         :repo "minad/corfu"
         :depth 1
         :files ("extensions/*"))
  :after tempel tempel-collection
  :custom
  (completion-cycle-threshold nil)
  (corfu-min-width 60)
  (corfu-max-width corfu-min-width)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (tab-always-indent 'complete)
  (corfu-scroll-margin 5)
  (corfu-popupinfo-delay 0.1)
  (corfu-separator ?\s)
  :general
  (:keymaps 'corfu-map
            :states 'insert
            "TAB" #'corfu-next
            [tab] #'corfu-next
            "S-TAB" #'corfu-previous
            [backtab] #'corfu-previous
            "S-SPC" #'corfu-insert-separator
            "<escape>" #'corfu-quit
            "<return>" #'corfu-insert
            "M-d" #'corfu-show-documentation
            "M-d" #'corfu-show-location)
  :init
  (defun corfu-enable-always-in-minibuffer ()
    "Enable Corfu in the minibuffer if Vertico/Mct are not active."
    (unless (or (bound-and-true-p mct--active)
                (bound-and-true-p vertico--input)
                (eq (current-local-map) read-passwd-map))
      (setq-local corfu-popupinfo-delay 0.1)
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1)
  (global-corfu-mode)
  (corfu-popupinfo-mode))

(use-package corfu-candidate-overlay
  :after corfu
  :config
  ;; enable corfu-candidate-overlay mode globally
  ;; this relies on having corfu-auto set to nil
  (corfu-candidate-overlay-mode +1))

;; Add extensions
(use-package cape
  :elpaca (:host github :repo "minad/cape")
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  (add-to-list 'completion-at-point-functions #'cape-emoji))

(use-package kind-icon
  :ensure t
  :after corfu nerd-icons
  :custom
  (kind-icon-use-icons nil)
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  (kind-icon-mapping
   `(
     (array ,(nerd-icons-codicon "nf-cod-symbol_array") :face font-lock-type-face)
     (boolean ,(nerd-icons-codicon "nf-cod-symbol_boolean") :face font-lock-builtin-face)
     (class ,(nerd-icons-codicon "nf-cod-symbol_class") :face font-lock-type-face)
     (color ,(nerd-icons-codicon "nf-cod-symbol_color") :face success)
     (command ,(nerd-icons-codicon "nf-cod-terminal") :face default)
     (constant ,(nerd-icons-codicon "nf-cod-symbol_constant") :face font-lock-constant-face)
     (constructor ,(nerd-icons-codicon "nf-cod-triangle_right") :face font-lock-function-name-face)
     (enummember ,(nerd-icons-codicon "nf-cod-symbol_enum_member") :face font-lock-builtin-face)
     (enum-member ,(nerd-icons-codicon "nf-cod-symbol_enum_member") :face font-lock-builtin-face)
     (enum ,(nerd-icons-codicon "nf-cod-symbol_enum") :face font-lock-builtin-face)
     (event ,(nerd-icons-codicon "nf-cod-symbol_event") :face font-lock-warning-face)
     (field ,(nerd-icons-codicon "nf-cod-symbol_field") :face font-lock-variable-name-face)
     (file ,(nerd-icons-codicon "nf-cod-symbol_file") :face font-lock-string-face)
     (folder ,(nerd-icons-codicon "nf-cod-folder") :face font-lock-doc-face)
     (interface ,(nerd-icons-codicon "nf-cod-symbol_interface") :face font-lock-type-face)
     (keyword ,(nerd-icons-codicon "nf-cod-symbol_keyword") :face font-lock-keyword-face)
     (macro ,(nerd-icons-codicon "nf-cod-symbol_misc") :face font-lock-keyword-face)
     (magic ,(nerd-icons-codicon "nf-cod-wand") :face font-lock-builtin-face)
     (method ,(nerd-icons-codicon "nf-cod-symbol_method") :face font-lock-function-name-face)
     (function ,(nerd-icons-codicon "nf-cod-symbol_method") :face font-lock-function-name-face)
     (module ,(nerd-icons-codicon "nf-cod-file_submodule") :face font-lock-preprocessor-face)
     (numeric ,(nerd-icons-codicon "nf-cod-symbol_numeric") :face font-lock-builtin-face)
     (operator ,(nerd-icons-codicon "nf-cod-symbol_operator") :face font-lock-comment-delimiter-face)
     (param ,(nerd-icons-codicon "nf-cod-symbol_parameter") :face default)
     (property ,(nerd-icons-codicon "nf-cod-symbol_property") :face font-lock-variable-name-face)
     (reference ,(nerd-icons-codicon "nf-cod-references") :face font-lock-variable-name-face)
     (snippet ,(nerd-icons-codicon "nf-cod-symbol_snippet") :face font-lock-string-face)
     (string ,(nerd-icons-codicon "nf-cod-symbol_string") :face font-lock-string-face)
     (struct ,(nerd-icons-codicon "nf-cod-symbol_structure") :face font-lock-variable-name-face)
     (text ,(nerd-icons-codicon "nf-cod-text_size") :face font-lock-doc-face)
     (typeparameter ,(nerd-icons-codicon "nf-cod-list_unordered") :face font-lock-type-face)
     (type-parameter ,(nerd-icons-codicon "nf-cod-list_unordered") :face font-lock-type-face)
     (unit ,(nerd-icons-codicon "nf-cod-symbol_ruler") :face font-lock-constant-face)
     (value ,(nerd-icons-codicon "nf-cod-symbol_field") :face font-lock-builtin-face)
     (variable ,(nerd-icons-codicon "nf-cod-symbol_variable") :face font-lock-variable-name-face)
     (t ,(nerd-icons-codicon "nf-cod-code") :face font-lock-warning-face)))
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package nerd-icons-dired
  :after nerd-icons
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;; Enable vertico
(use-package vertico
  :elpaca (:host github
                 :depth 1
                 :repo "minad/vertico"
                 :files ("extensions/*"))
  :general
  (:keymaps '(normal insert visual motion)
            "M-." #'vertico-repeat) ; Perfectly return to the state of the last Vertico minibuffer usage
  (:keymaps 'vertico-map
            "<C-RET>" #'vertico-insert
            "<escape>" #'minibuffer-keyboard-quit
            "<M-s>" #'vertico-next-group
            "<M-a>" #'vertico-previous-group
            "TAB" #'vertico-next
            [tab] #'vertico-next
            "S-TAB" #'vertico-previous
            [backtab] #'vertico-previous
            "<backspace>" #'vertico-directory-delete-char
            "C-<backspace>" #'vertico-directory-delete-word
            "RET" #'vertico-directory-enter
            "M-j" #'vertico-quick-insert)
  :hook (minibuffer-setup . vertico-repeat-save) ; Make sure vertico state is saved for `vertico-repeat'
  :custom
  (vertico-count 50)
  (vertico-resize t)
  (vertico-cycle nil)
  (enable-recursive-minibuffers t)
  (vertico-grid-separator "       ")
  (vertico-grid-lookahead 50)
  (vertico-buffer-display-action '(display-buffer-reuse-window))
  (vertico-multiform-categories
   '((file reverse)
     (consult-grep buffer)
     (consult-location)
     (imenu buffer)
     (library reverse indexed)
     (org-roam-node reverse indexed)
     (t reverse)
     ))
  (vertico-multiform-commands
   '(("flyspell-correct-*" grid reverse)
     (org-refile grid reverse indexed)
     (consult-yank-pop indexed)
     (consult-flycheck)
     (consult-lsp-diagnostics)
     ))
  :init
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (setq read-extended-command-predicate
        #'command-completion-default-include-p)


  (vertico-mode)
  (vertico-mouse-mode))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :elpaca (:host github
                 :depth 1
                 :repo "minad/marginalia")
  :general
  (:keymaps 'minibuffer-local-map
            "M-A"  #'marginalia-cycle)
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align #'right)
  :init
  (marginalia-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :elpaca nil
  :init
  (savehist-mode))

;; Treesitter
(use-package tree-sitter-langs
  :elpaca (:host github :repo "emacs-tree-sitter/tree-sitter-langs"))

(use-package tree-sitter
  :after tree-sitter-langs
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package treesit-auto
  :elpaca (:host github :repo "renzmann/treesit-auto")
  :after tree-sitter
  :init
  (setq treesit-language-source-alist
	'((emacs-lisp "https://github.com/Wilfred/tree-sitter-elisp")))
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

(use-package ts-fold
  :elpaca (:host github :repo "emacs-tree-sitter/ts-fold")
  :after treesit-auto
  :config
  (global-ts-fold-mode)
  (global-ts-fold-indicators-mode)
  (ts-fold-line-comment-mode))

;; Opacity
(set-frame-parameter nil 'alpha-background 25)
(add-to-list 'default-frame-alist '(alpha-background . 25))
(menu-bar-mode -1) ; Disable menubar
(scroll-bar-mode -1) ; Disable visible scrollbar
(tool-bar-mode -1)  ; Disable toolbar
(tooltip-mode -1) ; Disable tooltips
(set-fringe-mode 10)  ; Breathing room
(setq visible-bell t) ; Enable visible bell
(blink-cursor-mode 0) ; Disable blinking  cursor
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)
