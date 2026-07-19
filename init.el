;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-
;; Personal settings.  Emacs 30+, organized around the built-in use-package.

;;; ---------- Package bootstrap (auditable, pinned) ----------
(setq byte-compile-warnings '(not obsolete free-vars))
(setq warning-minimum-level :error)

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-archive-priorities '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1)))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))

;; use-package ships with Emacs 29+.  :ensure t auto-installs on first run.
(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t)

;;; ---------- Security hygiene ----------
(setq enable-local-variables :safe      ; never auto-run .dir-locals code
      enable-local-eval nil
      network-security-level 'high
      gnutls-verify-error t
      custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file) (load custom-file))

;;; ---------- Startup GC restore ----------
;; early-init.el raised the GC ceiling for a fast startup; bring it back down
;; to a value that keeps interactive pauses short without collecting constantly.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024)
                  gc-cons-percentage 0.1)))

;;; ---------- UI ----------
(use-package dracula-theme
  :config (load-theme 'dracula t))

(set-face-attribute 'default nil :family "JetBrains Mono" :height 130)
(show-paren-mode 1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(delete-selection-mode 1)                ; typing replaces the active region
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))       ; smooth trackpad/wheel scrolling
(setq ring-bell-function 'ignore
      visible-bell nil
      use-short-answers t)

;; which-key is built into Emacs 30 -- no external package needed.
(which-key-mode 1)

;;; ---------- Files, backups, recents ----------
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      default-directory "~/dev/"        ; <- your default open folder
      initial-buffer-choice default-directory)
(recentf-mode 1)
(setq recentf-max-saved-items 200)
(global-set-key (kbd "C-c r") #'recentf-open-files)
(save-place-mode 1)
(savehist-mode 1)
(global-auto-revert-mode 1)

;;; ---------- Minibuffer completion ----------
(use-package vertico
  :init (vertico-mode 1))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package orderless
  :init (setq completion-styles '(orderless basic)
              completion-category-overrides
              '((file (styles basic partial-completion)))))

(use-package consult
  :bind (("C-x b" . consult-buffer)       ; enhanced buffer switcher
         ("C-c l" . consult-line)         ; search lines in this buffer
         ("C-c s" . consult-ripgrep)      ; search across the project
         ("C-c i" . consult-imenu)        ; jump to a definition
         ("M-y"   . consult-yank-pop)     ; browse the kill ring
         ("M-g g" . consult-goto-line)))

(use-package embark
  :bind (("C-." . embark-act)             ; act on the thing at point
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;;; ---------- Completion-at-point ----------
(use-package company
  :init (global-company-mode 1)
  :config (setq company-idle-delay 0.2
                company-minimum-prefix-length 2))

;;; ---------- Project tree ----------
(use-package treemacs
  :bind ("C-c t" . treemacs)
  :config (setq treemacs-width 32
                treemacs-follow-mode t
                treemacs-filewatch-mode t))

;;; ---------- Linting ----------
(use-package flycheck
  :init (global-flycheck-mode 1))

(use-package flycheck-clj-kondo
  :after flycheck)

;;; ---------- Clojure + REPL ----------
(use-package paredit
  :hook ((clojure-mode clojurescript-mode cider-repl-mode) . paredit-mode))

(use-package rainbow-delimiters
  :hook ((clojure-mode clojurescript-mode cider-repl-mode) . rainbow-delimiters-mode))

(use-package clojure-mode)

(use-package clj-refactor
  :hook (clojure-mode . clj-refactor-mode))

(use-package cider
  :defer t
  :config
  (setq cider-repl-display-help-banner nil
        cider-save-file-on-load t
        cider-repl-pop-to-buffer-on-connect 'display-only
        cider-show-error-buffer 'only-in-repl
        nrepl-hide-special-buffers t))

;;; ---------- Java ----------
;; Built-in java-mode; eglot (also built in) starts jdtls when available.
(with-eval-after-load 'eglot
  (add-hook 'java-mode-hook #'eglot-ensure))
(setq c-basic-offset 4)

;;; ---------- Shell / zsh ----------
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.zshrc\\'" . sh-mode))
(setq shell-file-name "/bin/zsh"
      explicit-shell-file-name "/bin/zsh")

;;; ---------- Data formats ----------
(use-package json-mode
  :mode "\\.json\\'"
  :hook (json-mode . (lambda () (setq js-indent-level 2))))
(global-set-key (kbd "C-c j") #'json-pretty-print-buffer)

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :config (setq markdown-command "pandoc"))   ; optional; for live preview

(add-to-list 'auto-mode-alist '("\\.xml\\'" . nxml-mode))
(add-hook 'nxml-mode-hook (lambda () (setq nxml-child-indent 2)))

;;; ---------- Magit ----------
(use-package magit
  :bind ("C-x g" . magit-status))

;;; init.el ends here
