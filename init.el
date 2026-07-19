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
(add-hook 'prog-mode-hook #'display-line-numbers-mode) ; numbers only in code
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

;;; ---------- Editing quality-of-life ----------
(electric-pair-mode 1)                    ; auto-close brackets/quotes
                                          ; (paredit still owns the lisp modes)
(global-so-long-mode 1)                   ; stay responsive in huge/minified files
(windmove-default-keybindings)            ; S-<arrow> moves between windows
(setq-default indent-tabs-mode nil        ; indent with spaces
              tab-width 4)
(setq uniquify-buffer-name-style 'forward ; foo/x.el & bar/x.el, not x.el<2>
      sentence-end-double-space nil
      require-final-newline t
      isearch-lazy-count t                ; "3/17" match counter in isearch
      echo-keystrokes 0.02
      scroll-margin 3                     ; keep a few lines of context
      scroll-conservatively 101           ; scroll one line, don't recenter
      scroll-preserve-screen-position t)
;; Create missing parent directories when saving a new file.
(add-hook 'before-save-hook
          (lambda ()
            (when buffer-file-name
              (let ((dir (file-name-directory buffer-file-name)))
                (unless (file-directory-p dir)
                  (make-directory dir t))))))

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
;; Corfu: a lightweight in-buffer popup that reuses orderless filtering.
(use-package corfu
  :init (global-corfu-mode 1)
  :config
  (setq corfu-auto t                     ; pop up automatically
        corfu-auto-delay 0.2
        corfu-auto-prefix 2
        corfu-cycle t                     ; wrap around the candidate list
        corfu-quit-no-match 'separator)
  :bind (:map corfu-map
              ("SPC" . corfu-insert-separator))) ; type a space to keep filtering

;; Cape: extra completion-at-point sources (files, words, keywords).
(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-keyword))

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

;;; ---------- LSP (eglot, built-in) ----------
;; Requires the language servers on PATH:
;;   Java    -> jdtls            (brew install jdtls)
;;   Clojure -> clojure-lsp      (brew install clojure-lsp/brew/clojure-lsp)
;; For Clojure this complements CIDER: CIDER drives the live REPL, while
;; clojure-lsp provides static navigation, references, and completion.
(use-package eglot
  :ensure nil                             ; ships with Emacs
  :hook ((java-mode clojure-mode clojurescript-mode) . eglot-ensure)
  :config
  (setq eglot-events-buffer-config '(:size 0 :format short) ; don't log traffic
        eglot-autoshutdown t              ; stop the server with its last buffer
        eglot-extend-to-xref t
        eldoc-echo-area-use-multiline-p nil)) ; keep hover docs to one line
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
