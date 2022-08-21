(add-to-list 'load-path "~/.config/emacs/config/plugins/config/")

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

; Keep near top, after use-package
(use-package general)
(require 'general)

(require 'init-evil)
(require 'init-doom-modeline)
(require 'init-ivy)
(require 'init-whichkey)
(require 'init-rainbow-delimiters)

; Keep these at bottom
(provide 'init-plugins)
