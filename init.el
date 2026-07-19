;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-
;; Personal settings.
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

(defvar my/packages
  '(dracula-theme
    treemacs
    cider
    clojure-mode
    clj-refactor
    paredit
    rainbow-delimiters
    flycheck
    flycheck-clj-kondo
    company
    markdown-mode
    json-mode
    yaml-mode
    magit
    which-key
    vertico
    orderless
    marginalia))
(dolist (p my/packages)
  (unless (package-installed-p p) (package-install p)))

;;; ---------- Security hygiene ----------
(setq enable-local-variables :safe      ; never auto-run .dir-locals code
      enable-local-eval nil
      network-security-level 'high
      gnutls-verify-error t
      custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file) (load custom-file))

;;; ---------- UI ----------
(load-theme 'dracula t)
(set-face-attribute 'default nil :family "JetBrains Mono" :height 130)
(menu-bar-mode -1) (tool-bar-mode -1) (scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(show-paren-mode 1)
(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      use-short-answers t)
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
(vertico-mode 1)
(marginalia-mode 1)
(setq completion-styles '(orderless basic))

;;; ---------- Project tree ----------
(global-set-key (kbd "C-c t") #'treemacs)
(with-eval-after-load 'treemacs
  (setq treemacs-width 32
        treemacs-follow-mode t
        treemacs-filewatch-mode t))

;;; ---------- Completion-at-point ----------
(global-company-mode 1)
(setq company-idle-delay 0.2 company-minimum-prefix-length 2)

;;; ---------- Linting ----------
(global-flycheck-mode 1)
(require 'flycheck-clj-kondo)

;;; ---------- Clojure + REPL ----------
(dolist (h '(clojure-mode-hook clojurescript-mode-hook cider-repl-mode-hook))
  (add-hook h #'paredit-mode)
  (add-hook h #'rainbow-delimiters-mode))
(add-hook 'clojure-mode-hook #'clj-refactor-mode)
(setq cider-repl-display-help-banner nil
      cider-save-file-on-load t
      cider-repl-pop-to-buffer-on-connect 'display-only
      cider-show-error-buffer 'only-in-repl
      nrepl-hide-special-buffers t)

;;; ---------- Java ----------
;; Built-in java-mode + LSP-free start. Add eglot when you want jdtls:
(with-eval-after-load 'eglot
  (add-hook 'java-mode-hook #'eglot-ensure))
(setq c-basic-offset 4)

;;; ---------- Shell / zsh ----------
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.zshrc\\'" . sh-mode))
(setq shell-file-name "/bin/zsh"
      explicit-shell-file-name "/bin/zsh")

;;; ---------- Data formats ----------
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))
(add-hook 'json-mode-hook (lambda () (setq js-indent-level 2)))
(global-set-key (kbd "C-c j") #'json-pretty-print-buffer)
(setq markdown-command "pandoc")        ; optional; for live preview
(add-hook 'nxml-mode-hook (lambda () (setq nxml-child-indent 2)))
(add-to-list 'auto-mode-alist '("\\.xml\\'" . nxml-mode))

;;; ---------- Magit ----------
(global-set-key (kbd "C-x g") #'magit-status)


;; ------------ Disable bell ----
(setq visible-bell nil)
;;; init.el ends here
