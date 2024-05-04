;; -*- lexical-binding: t -*-
;; Install elpaca
(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
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
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
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

(setq package-enable-at-startup nil)

;; Elpaca use package support
(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq use-package-always-ensure t))

;; Block until current queue processed
(elpaca-wait)

;; General for keybindings
(use-package general
  :ensure t
  :demand t)
(elpaca-wait)

(general-create-definer key-leader
  :states 'normal
  :prefix "SPC")

(general-create-definer key-local-leader
  :states 'normal
  :prefix ";")


(key-leader
  :states 'normal
  "/" '(comment-line :which-key "Comment: Toggle Current Line")
  )

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

(key-leader
  :states 'normal
  "b b" #'ibuffer)

(general-def
 "<escape>" #'keyboard-escape-quit)


;; Ensure emacs paths load the same as our shell
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; Which key to hint key bindings
(use-package which-key
  :defer nil
  :general
  (key-leader
    :states 'normal
    "w w" #'which-key-show-top-level)
  :custom
  (which-key-idle-delay 1)
  (which-key-max-description-length 50)
  :init
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
(use-package kanagawa-theme
  :custom
  (kanagwa-theme-org-bold t)
  (kanagawa-theme-org-height t)
  (kanagawa-theme-keyword-italic t)
  (kanagawa-theme-comment-italic t)
  :config
  (load-theme 'kanagawa t))

(use-package doom-modeline
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 5)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-minor-modes nil)
  (doom-modeline-enable-word-count nil)
  (doom-modeline-buffer-encoding t)
  (doom-modeline-indent-info nil)
  (doom-modeline-checker-simple-format t)
  (doom-modeline-vcs-max-length 12)
  (doom-modeline-env-version t)
  (doom-modeline-irc-stylize 'identity)
  (doom-modeline-github-timer nil)
  (doom-modeline-gnus-timer nil)
  :config
  (doom-modeline-mode))

(use-package nerd-icons)

(use-package nerd-icons-ibuffer
  :ensure t
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package nerd-icons-dired
  :after nerd-icons
  :init
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package treemacs
  :defer t
  :general
  (key-leader
    :states 'normal
    "t" '(nil :which-key "Treemacs"))
  (key-leader
    :states 'normal
    "t t" '(treemacs :which-key "Treemacs: Toggle")
    "t p" '(nil :which-key "Treemacs Project"))
  (key-leader
    :states 'normal
    "t p n" '(nil :which-key "Treemacs Project: New"))
  :custom
  (treemacs-silent-refresh t)
  (treemacs-silent-filewatch t)
  (treemacs-filewatch-mode t)
  (treemacs-show-hidden-files nil)
  (treemacs-follow-after-init t)
  (treemacs-expand-after-init t)
  (treemacs-file-event-delay 100)
  (treemacs-follow-mode t)
  :hook (treemacs-mode . (lambda () (display-line-numbers-mode -1))))

(use-package treemacs-nerd-icons
  :after nerd-icons treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package treemacs-evil
  :after treemacs)

;; Download Evil
(use-package goto-chg)
(use-package evil
  :after goto-chg
  :custom
  (evl-kbd-macro-suppress-motion-error t)
  (evil-want-C-u-scroll t)
  (evil-want-integration t)
  (evil-want-keybinding 'nil)
  (which-key-allow-evil-operators t)
  (evil-undo-system 'undo-redo)
  (evil-want-fine-undo t)
  (evil-emacs-state-modes nil)
  (evil-insert-state-modes nil)
  (evil-motion-state-modes nil)
  :config
  (evil-mode 1))

(use-package evil-matchit
  :config
  (global-evil-matchit-mode))

(use-package targets
  :ensure (:host github
                 :depth 1
                 :repo "noctuid/targets.el"
  :custom
  (targets-user-text-objects '((pipe "|" nil separator)
                               (paren "(" ")" pair :more-keys "b")
                               (bracket "[" "]" pair :more-keys "r")
                               (curly "{" "}" pair :more-keys "c")))
  :config
  (targets-setup t
                 :inside-key nil
                 :around-key nil
                 :remote-key nil)))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Allow to jump to characters, etc.
(use-package avy
  :general
  (:keymaps 'normal
            "f" 'avy-goto-char))

;; Improved PDF Experience
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
  :ensure (:host github
                 :depth 1
                 :repo "axelf4/hotfuzz"
                 :pre-build (("cmake" "-DCMAKE_C_FLAGS='-O3 -march=native'" ".") ("cmake" "--build" "."))))

(use-package orderless
  :after hotfuzz
  :config
  (defun +orderless--consult-suffix ()
    "Regexp which matches the end of string with Consult tofu support."
    (if (and (boundp 'consult--tofu-char) (boundp 'consult--tofu-range))
        (format "[%c-%c]*$"
                consult--tofu-char
                (+ consult--tofu-char consult--tofu-range -1))
      "$"))

  ;; Recognizes the following patterns:
  ;; * .ext (file extension)
  ;; * regexp$ (regexp matching at end)
  (defun +orderless-consult-dispatch (word _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" word)
      `(orderless-regexp . ,(concat (substring word 0 -1) (+orderless--consult-suffix))))
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." word))
      `(orderless-regexp . ,(concat "\\." (substring word 1) (+orderless--consult-suffix))))))

  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))
  (setq
   completion-ignore-case t
   completion-styles '(hotfuzz orderless basic)
   completion-category-defaults nil
   completion-category-overrides '((file (styles partial-completion))
                                   (command (styles +orderless-with-initialism))
                                   (variable (styles +orderless-with-initialism))
                                   (symbol (styles +orderless-with-initialism)))
   orderless-component-separator #'orderless-escapable-split-on-space
   orderless-style-dispatchers (list #'+orderless-consult-dispatch
                                     #'orderless-affix-dispatch)
   orderless-matching-styles
   '(orderless-literal
     orderless-prefixes
     orderless-initialism)))

(use-package corfu
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
  (global-corfu-mode)
  (corfu-popupinfo-mode))

;; Add extensions
(use-package cape
  :ensure (:host github
		 :repo "minad/cape"
		 :depth 1)
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

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;; Enable vertico
(use-package vertico
  :general
  (:keymaps '(normal insert visual motion)
            "M-." #'vertico-repeat) ; Perfectly return to the state of the last Vertico minibuffer usage
  (:keymaps 'vertico-map
            "C-<return>" #'vertico-insert
            "<escape>" #'minibuffer-keyboard-quit
            "M-s" #'vertico-next-group
            "M-a" #'vertico-previous-group
            "TAB" #'vertico-next
            [tab] #'vertico-next
            "S-TAB" #'vertico-previous
            [backtab] #'vertico-previous
            "<backspace>" #'vertico-directory-delete-char
            "C-<backspace>" #'vertico-directory-delete-word
            "<return>" #'vertico-directory-enter
            "M-j" #'vertico-quick-insert)
  :hook (minibuffer-setup . vertico-repeat-save) ; Make sure vertico state is saved for `vertico-repeat'
  :custom
  (vertico-count 15)
  (vertico-resize t)
  (vertico-cycle nil)
  (enable-recursive-minibuffers t)
  (vertico-grid-lookahead 50)
  (vertico-buffer-display-action '(display-buffer-reuse-window))
  (vertico-multiform-categories
   '((file reverse)
     (consult-ripgrep buffer)
     (consult-location)
     (imenu buffer)
     (library reverse indexed)
     (org-roam-node reverse indexed)
     (t reverse)))
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
  :ensure (:host github
                 :depth 1
                 :repo "minad/marginalia")
  :general
  (:keymaps 'minibuffer-local-map
            "M-A"  #'marginalia-cycle)
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align #'center)
  :init
  (marginalia-mode))

(use-package embark
  :after marginalia
  :general
  ("C-." 'embark-act)
  :custom
  (prefix-help-command #'embark-prefix-help-command)
  :init)

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  :init
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref
        consult-narrow-key "<"
        completion-in-region-function #'consult-completion-in-region)
  :general
  (key-leader
    :states 'normal
    "c" '(nil :which-key "Consult")
    "c b" '(consult-buffer :which-key "Consult: Buffers")
    "c f" '(consult-fd :which-key "Consult: Find File")
    "c r" '(consult-recent-file :which-key "Consult: Recent  Files")))


;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure nil
  :init
  (savehist-mode))

;; Treesitter
(use-package tree-sitter-langs)


(use-package tree-sitter
  :after tree-sitter-langs
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package treesit-auto
  :ensure (:host github :repo "renzmann/treesit-auto")
  :after tree-sitter
  :custom
  (setq treesit-auto-install 'prompt)
  :config
  (global-treesit-auto-mode))

(use-package ts-fold
  :ensure (:host github :repo "emacs-tree-sitter/ts-fold")
  :after
  tree-sitter
  :config
  (global-ts-fold-mode)
  (global-ts-fold-indicators-mode)
  (ts-fold-line-comment-mode))

;; Undo Tree
(use-package vundo
  :defer t
  :hook (vundo-mode . (lambda () (setq-local cursor-type nil)))
  :custom
  (vundo-glyph-alist vundo-unicode-symbols))

;; Persistent Undo
(use-package undo-fu-session
  :config
  (undo-fu-session-global-mode))

;; Set background colors for color codes
(use-package rainbow-mode
  :config
  (rainbow-mode t))

;; Setup Language Servers

(use-package lsp-mode
  :general
  (key-leader
    :states 'visual
    "l f r" '(lsp-format-buffer :which-key "LSP Format: Region"))
  (key-leader
    :states 'normal
    "k" '(lsp-ui-doc-glance :which-key "LSP: Glance Symbol")
    "K" '(lsp-describe-thing-at-point :which-key "LSP: Full Doc")
    "l" '(nil :which-key "LSP")
    "l f" '(nil :which-key "LSP Format")
    "l f f" '(lsp-format-buffer :which-key "LSP Format: Buffer")
    "l i" '(lsp-treemacs-implementations :which-key "LSP: Implementation")
    "l r" '(lsp-treemacs-references :which-key "LSP: Refrences")
    "l n" '(lsp-rename :which-key "LSP: Rename")
    "l R" '(lsp-restart :which-key "LSP: Restart")
    "l d" '(lsp-find-definition :which-key "LSP: Definition")
    "l D" '(lsp-find-declaration :which-key "LSP: Declaration")
    "l c" '(lsp-execute-code-action :which-key "LSP: Code Actions")
    "l t" '(nil :which-key "LSP Treemacs")
    "l t e" '(lsp-treemacs-errors-list :which-key "LSP Treemacs: Errors List")
    "l t s" '(lsp-treemacs-symbols :which-key "LSP Treemacs: Symbols")
    "l t q" '(lsp-treemacs-quick-fix :which-key "LSP Treemacs: Quickfix")
    "l t h" '(lsp-treemacs-call-heirarchy :which-key "LSP Treemacs: Call Hierarchy"))
  :custom
  (lsp-keymap-prefix "M-l")
  (lsp-auto-execute-action 'nil)
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         ;; (XXX-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp
  :config
  (with-eval-after-load 'lsp-mode
    (lsp-treemacs-sync-mode)
    (setq lsp-modeline-diagnostics-scope :workspace)))

;; optionally
(use-package lsp-ui
  :custom
  (lsp-ui-doc-delay 0.1)
  :commands
  lsp-ui-mode
  lsp-ui-doc-enable)

;; optionally if you want to use debugger
(use-package dap-mode
  :config
  (require 'dap-cpptools)
  (require 'dap-gdb-lldb)
  (dap-register-debug-template "Rust::GDB Run Configuration"
                               (list :type "gdb"
                                     :request "launch"
                                     :name "GDB::Run"
                                     :gdbpath "rust-gdb"
                                     :target nil
                                     :cwd nil))
  (dap-ui-mode)
  (dap-tooltip-mode)
  (dap-ui-controls-mode)
  (dap-auto-configure-mode)
  (dap-mode))

;; Rust integration
(use-package rustic
  :general
  (key-leader
    :states 'normal 'rustic-mode
    "f r" '(rustic-cargo-run :which-key "Cargo: Run"))
  :config
  (rustic-mode))


;;; Org Mode Appearance ------------------------------------
(use-package org-bullets
  :hook (org-mode-hook . (lambda ()
			   (org-bullets-mode 1)
			   (org-toggle-pretty-entities))))

;; Load org-faces to make sure we can set appropriate faces
(require 'org-faces)

;; Hide emphasis markers on formatted text
(setq org-hide-emphasis-markers t)

;; Resize Org headings
(dolist (face '((org-level-1 . 1.45)
                (org-level-2 . 1.35)
                (org-level-3 . 1.3)
                (org-level-4 . 1.25)
                (org-level-5 . 1.2)
                (org-level-6 . 1.15)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1)))
  (set-face-attribute (car face) nil :font "Fira Code" :weight 'medium :height (cdr face)))
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-table nil :inherit 'fixed-pitch)
(set-face-attribute 'org-formula nil :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)


;; Misc settings
(menu-bar-mode -1) ; Disable menubar
(scroll-bar-mode -1) ; Disable visible scrollbar
(tool-bar-mode -1)  ; Disable toolbar
(tooltip-mode) ; Enable tooltips
(set-fringe-mode 10)  ; Breathing room
(setq visible-bell nil) ; Enable visible bell
(blink-cursor-mode 0) ; Disable blinking  cursor
(setq display-line-numbers-type 'relative)
(column-number-mode t)
(global-display-line-numbers-mode t)
(setq-default indent-tabs-mode nil)
(global-hl-line-mode t)
(setq use-dialog-box nil)
(global-auto-revert-mode t)
(recentf-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(save-place-mode 1)
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)
(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))