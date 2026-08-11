;;; init.el --- Minimal Clojure/Java config  -*- lexical-binding: t; -*-
;;
;; Author: Tudor
;; Targets: Emacs 29+ (uses built-in use-package, eglot, treesit-free setup)
;; Design goals: small auditable package set, no distro, works in GUI and -nw.
;;
;; External prerequisites (install separately, on PATH):
;;   clj-kondo   -- Clojure linting        brew install borkdude/brew/clj-kondo
;;   clojure     -- CLI / REPL             brew install clojure/tools/clojure
;;   xmllint     -- XML pretty-print       (ships with macOS)
;;   pandoc      -- markdown preview       brew install pandoc      (optional)
;;   jdtls       -- Java LSP               brew install jdtls       (optional)
;;   JetBrains Mono font                   brew install --cask font-jetbrains-mono
;;
;;; Code:

;;; ---------------------------------------------------------------------------
;;; 0. Quiet third-party byte-compile noise
;;; ---------------------------------------------------------------------------
;; These warnings (incf/decf/seconds-to-string) come from other people's
;; packages compiled against a newer Emacs, not from this file.
(setq byte-compile-warnings '(not obsolete free-vars unresolved)
      warning-minimum-level :error
      native-comp-async-report-warnings-errors 'silent)


;;; ---------------------------------------------------------------------------
;;; 1. Package bootstrap -- pinned, curated-first
;;; ---------------------------------------------------------------------------
(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      ;; Prefer FSF-curated archives; MELPA only when nothing else has it.
      package-archive-priorities '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1)))

;; NOTE: no (package-initialize) here. Since Emacs 27 packages are activated
;; automatically before init.el is loaded; calling it again triggers a warning.
(unless package-archive-contents
  (package-refresh-contents))

;; use-package is built in since Emacs 29.
(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer  nil
      use-package-compute-statistics t)  ; M-x use-package-report


;;; ---------------------------------------------------------------------------
;;; 2. Security hygiene
;;; ---------------------------------------------------------------------------
;; The Emacs analogue of VSCode "workspace trust": a cloned repo's
;; .dir-locals.el can set safe variables but can NEVER execute code.
(setq enable-local-variables :safe
      enable-local-eval      nil
      ;; Verify TLS properly when fetching packages.
      network-security-level 'high
      gnutls-verify-error    t
      gnutls-min-prime-bits  3072
      ;; Keep Customize's generated code out of this file.
      custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file nil :nomessage))


;;; ---------------------------------------------------------------------------
;;; 3. macOS modifier keys  (GUI builds only -- see note at bottom of file)
;;; ---------------------------------------------------------------------------
;; Guarded on `window-system', not `system-type': terminal Emacs has no
;; ns-* variables at all, and the terminal emulator owns the modifiers there.
(when (memq window-system '(ns mac))
  (setq ns-command-modifier        'super  ; Cmd  -> s-...  (free for your binds)
        ns-alternate-modifier      'meta   ; Opt  -> M-...
        ns-right-alternate-modifier 'none  ; right Opt types ă ș ț é
        ns-function-modifier       'hyper))


;;; ---------------------------------------------------------------------------
;;; 4. UI
;;; ---------------------------------------------------------------------------
(use-package dracula-theme
  :config (load-theme 'dracula t))

;; Every one of these is absent in a non-toolkit / terminal build.
(when (fboundp 'menu-bar-mode)   (menu-bar-mode   -1))
(when (fboundp 'tool-bar-mode)   (tool-bar-mode   -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tooltip-mode)    (tooltip-mode    -1))

;; Font: only meaningful under a window system, and only if actually installed.
(when (and (display-graphic-p)
           (member "JetBrains Mono" (font-family-list)))
  (set-face-attribute 'default nil :family "JetBrains Mono" :height 130)
  (set-face-attribute 'fixed-pitch nil :family "JetBrains Mono"))

(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore
      use-short-answers t              ; y/n instead of yes/no  (Emacs 28+)
      scroll-conservatively 101
      sentence-end-double-space nil)

(global-display-line-numbers-mode 1)
(column-number-mode 1)
(show-paren-mode 1)
(delete-selection-mode 1)

(use-package which-key
  :config (which-key-mode 1))


;;; ---------------------------------------------------------------------------
;;; 5. Files, history, default project folder
;;; ---------------------------------------------------------------------------
(defvar my/dev-dir (expand-file-name "~/dev/")
  "Default folder Emacs opens into.")

(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles  nil
      require-final-newline t)

;; Only adopt the dev folder if it actually exists. A non-existent
;; `default-directory' breaks every subprocess Emacs later spawns.
(if (file-directory-p my/dev-dir)
    (setq default-directory     my/dev-dir
          initial-buffer-choice my/dev-dir)
  (message "my/dev-dir %s does not exist; staying in %s"
           my/dev-dir default-directory))

(recentf-mode 1)
(setq recentf-max-saved-items 200
      recentf-exclude '("/elpa/" "/tmp/" "/ssh:" "custom\\.el"))

(save-place-mode 1)
(savehist-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)


;;; ---------------------------------------------------------------------------
;;; 6. Minibuffer completion
;;; ---------------------------------------------------------------------------
(use-package vertico
  :config (vertico-mode 1))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides
        '((file (styles basic partial-completion)))))

(use-package marginalia
  :config (marginalia-mode 1))


;;; ---------------------------------------------------------------------------
;;; 7. Project tree
;;; ---------------------------------------------------------------------------
(use-package treemacs
  :commands (treemacs treemacs-select-window)
  :config
  (setq treemacs-width 32
        treemacs-is-never-other-window t
        treemacs-git-mode 'simple)
  ;; NOTE: these are minor modes -- call them, do not setq them.
  (treemacs-follow-mode 1)
  (treemacs-filewatch-mode 1))


;;; ---------------------------------------------------------------------------
;;; 8. In-buffer completion
;;; ---------------------------------------------------------------------------
(use-package company
  :config
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 2
        company-tooltip-align-annotations t)
  (global-company-mode 1))


;;; ---------------------------------------------------------------------------
;;; 9. Linting
;;; ---------------------------------------------------------------------------
(use-package flycheck
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (global-flycheck-mode 1))

(use-package flycheck-clj-kondo
  :after (flycheck clojure-mode))


;;; ---------------------------------------------------------------------------
;;; 10. Structural editing (Lisp only -- deliberately not global)
;;; ---------------------------------------------------------------------------
(use-package paredit
  :hook ((clojure-mode       . paredit-mode)
         (clojurescript-mode . paredit-mode)
         (clojurec-mode      . paredit-mode)
         (cider-repl-mode    . paredit-mode)
         (emacs-lisp-mode    . paredit-mode)
         (lisp-mode          . paredit-mode)))

(use-package rainbow-delimiters
  :hook ((clojure-mode       . rainbow-delimiters-mode)
         (clojurescript-mode . rainbow-delimiters-mode)
         (clojurec-mode      . rainbow-delimiters-mode)
         (cider-repl-mode    . rainbow-delimiters-mode)
         (emacs-lisp-mode    . rainbow-delimiters-mode)))


;;; ---------------------------------------------------------------------------
;;; 11. Clojure + CIDER
;;; ---------------------------------------------------------------------------
(use-package clojure-mode
  :mode (("\\.clj\\'"  . clojure-mode)
         ("\\.cljs\\'" . clojurescript-mode)
         ("\\.cljc\\'" . clojurec-mode)
         ("\\.edn\\'"  . clojure-mode)
         ("\\.bb\\'"   . clojure-mode)))   ; babashka

(use-package cider
  :after clojure-mode
  :config
  (setq cider-repl-display-help-banner nil
        cider-save-file-on-load t
        cider-repl-pop-to-buffer-on-connect 'display-only
        cider-show-error-buffer 'only-in-repl
        cider-auto-select-error-buffer nil
        cider-repl-history-file (locate-user-emacs-file "cider-history")
        cider-repl-wrap-history t
        cider-font-lock-dynamically '(macro core function var)
        nrepl-hide-special-buffers t
        nrepl-log-messages nil))

(use-package clj-refactor
  :after clojure-mode
  :hook (clojure-mode . clj-refactor-mode)
  :config
  (setq cljr-warn-on-eval nil)          ; do not eval code just to refactor
  (cljr-add-keybindings-with-prefix "C-c C-m"))


;;; ---------------------------------------------------------------------------
;;; 11b. clojure-lsp via eglot (built-in LSP client)
;;; ---------------------------------------------------------------------------
;; Install:  brew install clojure-lsp/brew/clojure-lsp-native
;;
;; Division of labour:
;;   CIDER       -> evaluation, REPL, debugger, test running  (needs live REPL)
;;   clojure-lsp -> project-wide xref, rename, unused vars    (works cold)
;; eglot is preferred over lsp-mode here: built in, ~1/10th the code.
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((clojure-mode clojurescript-mode clojurec-mode)
                 . ("clojure-lsp"))))

(when (executable-find "clojure-lsp")
  (dolist (h '(clojure-mode-hook clojurescript-mode-hook clojurec-mode-hook))
    (add-hook h #'eglot-ensure)))

;; eglot reports diagnostics through flymake; we run flycheck globally.
;; Without this bridge you get two overlapping diagnostic systems.
(use-package flycheck-eglot
  :after (flycheck eglot)
  :config (global-flycheck-eglot-mode 1))

;; CIDER and eglot both offer completion/xref. Let CIDER win when a REPL
;; is connected -- its data is live rather than statically inferred.
(with-eval-after-load 'cider
  (setq cider-eldoc-display-for-symbol-at-point t))


;;; ---------------------------------------------------------------------------
(setq c-basic-offset 4
      tab-width 4
      indent-tabs-mode nil)

;; Only attach the LSP if a server is actually installed.
(when (executable-find "jdtls")
  (add-hook 'java-mode-hook #'eglot-ensure))

(with-eval-after-load 'eglot
  (setq eglot-autoshutdown t
        eglot-sync-connect 1))


;;; ---------------------------------------------------------------------------
;;; 13. Shell / zsh
;;; ---------------------------------------------------------------------------
(setq shell-file-name          "/bin/zsh"
      explicit-shell-file-name "/bin/zsh")

(add-to-list 'auto-mode-alist '("\\.zsh\\'"      . sh-mode))
(add-to-list 'auto-mode-alist '("\\.zshrc\\'"    . sh-mode))
(add-to-list 'auto-mode-alist '("\\.zprofile\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.zshenv\\'"   . sh-mode))
(add-hook 'sh-mode-hook (lambda () (sh-set-shell "zsh")))

;; GUI Emacs on macOS does not inherit your shell PATH. Fix it.
(when (memq window-system '(ns mac))
  (use-package exec-path-from-shell
    :config
    (setq exec-path-from-shell-arguments '("-l"))  ; login shell, no -i: faster
    (exec-path-from-shell-initialize)))


;;; ---------------------------------------------------------------------------
;;; 14. Data formats: JSON, Markdown, XML, YAML
;;; ---------------------------------------------------------------------------
(use-package json-mode
  :mode "\\.json\\'"
  :hook (json-mode . (lambda () (setq-local js-indent-level 2))))

(use-package markdown-mode
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :config
  (setq markdown-command "pandoc"
        markdown-fontify-code-blocks-natively t))

(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

;; XML: nxml-mode is built in and good.
(add-to-list 'auto-mode-alist '("\\.\\(xml\\|xsd\\|xsl\\|pom\\)\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("pom\\.xml\\'" . nxml-mode))
(setq nxml-child-indent 2
      nxml-attribute-indent 2
      nxml-slash-auto-complete-flag t)

(defun my/pretty-print-json ()
  "Reformat the current buffer as indented JSON."
  (interactive)
  (json-pretty-print-buffer))

(defun my/pretty-print-xml ()
  "Reformat the current buffer with xmllint."
  (interactive)
  (if (executable-find "xmllint")
      (shell-command-on-region (point-min) (point-max)
                               "xmllint --format -" t t)
    (message "xmllint not found on PATH")))


;;; ---------------------------------------------------------------------------
;;; 15. Git
;;; ---------------------------------------------------------------------------
(use-package magit
  :commands (magit-status magit-blame)
  :config (setq magit-diff-refine-hunk t))


;;; ---------------------------------------------------------------------------
;;; 16. Keybindings
;;; ---------------------------------------------------------------------------
(global-set-key (kbd "C-c t") #'treemacs)
(global-set-key (kbd "C-c r") #'recentf-open-files)
(global-set-key (kbd "C-c j") #'my/pretty-print-json)
(global-set-key (kbd "C-c x") #'my/pretty-print-xml)
(global-set-key (kbd "C-c g") #'magit-status)
(global-set-key (kbd "C-x g") #'magit-status)
(global-set-key (kbd "M-o")   #'other-window)

;; Cmd-key bindings, GUI only (Cmd is mapped to Super above).
(when (memq window-system '(ns mac))
  (global-set-key (kbd "s-s") #'save-buffer)
  (global-set-key (kbd "s-c") #'kill-ring-save)
  (global-set-key (kbd "s-v") #'yank)
  (global-set-key (kbd "s-z") #'undo)
  (global-set-key (kbd "s-w") #'delete-window)
  (global-set-key (kbd "s-+") #'text-scale-increase)
  (global-set-key (kbd "s--") #'text-scale-decrease))

;;; ---------------------------------------------------------------------------
;;; 17. LLM agents (ACP) -- agent-shell
;;; ---------------------------------------------------------------------------
;; Prerequisite (installs a Node binary -- note the added supply chain):
;;   npm install -g @agentclientprotocol/claude-agent-acp
;;   claude setup-token        ; run the CLI once outside Emacs to authenticate
;;
;; Docs: https://github.com/xenodium/agent-shell
(use-package agent-shell
  :commands (agent-shell
             agent-shell-anthropic-start-claude-code
             agent-shell-qwen-start
             agent-shell-resume-session
             agent-shell-toggle)
  :config
  ;; --- Authentication -------------------------------------------------------
  ;; Default to subscription login. Switch billing at runtime without losing
  ;; the conversation via the toggles in section 17c (C-c c s / C-c c c):
  ;; they flip this variable and resume the persisted session under the new
  ;; credential. Console keys live in auth-source, never inline:
  ;;   ~/.authinfo  ->  machine api.anthropic.com login apikey password sk-ant-...
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))

  ;; --- Environment ----------------------------------------------------------
  ;; The agent process gets a MINIMAL env by default -- it would not see the
  ;; PATH/JAVA_HOME we fixed earlier. Inherit from Emacs explicitly.
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables :inherit-env t))

  ;; --- Defaults -------------------------------------------------------------
  (setq agent-shell-preferred-agent-config
        (agent-shell-anthropic-make-claude-code-config)
        agent-shell-display-action '(display-buffer-in-side-window
                                     (side . right) (window-width . 0.4))
        agent-shell-tool-use-expand-by-default t      ; SEE what it wants to run
        agent-shell-thought-process-expand-by-default nil
        agent-shell-show-usage-at-turn-end t          ; token cost visibility
        ;; When resuming (e.g. after a billing switch), replay the whole
        ;; conversation so context comes back. 'last / 'first-last are lighter.
        agent-shell-session-restore-verbosity 'full)

  ;; --- OpenRouter via the Qwen Code ACP agent -------------------------------
  ;; OpenRouter is OpenAI-compatible, so we drive it through Qwen Code.
  ;; Prerequisite:  npm install -g @qwen-code/qwen-code   (-> `qwen' on PATH)
  ;; Key lives in auth-source, never inline:
  ;;   ~/.authinfo -> machine openrouter.ai password sk-or-...
  (setq agent-shell-qwen-authentication
        (agent-shell-qwen-make-authentication
         :openai-api-key (lambda ()
                           (auth-source-pick-first-password
                            :host "openrouter.ai"))))

  ;; Default model for a bare M-x agent-shell-qwen-start. `:inherit-env t' lets
  ;; the qwen node binary see the PATH we fixed in exec-path-from-shell.
  ;; Section 17b rebinds OPENAI_MODEL per-shell to switch models live.
  (setq agent-shell-qwen-environment
        (agent-shell-make-environment-variables
         :inherit-env t
         "OPENAI_BASE_URL" "https://openrouter.ai/api/v1"
         "OPENAI_MODEL"    "deepseek/deepseek-v4-flash"))

  ;; --- Containment (uncomment to harden) ------------------------------------
  ;; Deny the agent direct read/write access to your filesystem:
  ;; (setq agent-shell-text-file-capabilities nil)
  ;;
  ;; Run the agent inside a devcontainer instead of on the host:
  ;; (setq agent-shell-command-prefix
  ;;       '("devcontainer" "exec" "--workspace-folder" ".")
  ;;       agent-shell-path-resolver-function
  ;;       #'agent-shell-devcontainer-resolve-path)

  :bind (("C-c a"   . agent-shell)
         ("C-c A"   . agent-shell-toggle)
         ("C-c c s" . my/claude-use-subscription)  ; billing -> Pro/Max login
         ("C-c c c" . my/claude-use-console)       ; billing -> console API key
         :map agent-shell-mode-map
         ;; RET submits by default; swap if you prefer composing multi-line.
         ("C-c C-k" . agent-shell-interrupt)))

;;; ---------------------------------------------------------------------------
;;; 17c. Switch Claude Code billing (subscription <-> console) mid-conversation
;;; ---------------------------------------------------------------------------
;; Auth is bound to the `claude' subprocess at launch, so billing cannot be
;; hot-swapped on a live agent. But the conversation is persisted to disk by
;; Claude Code independently of the credential, so each toggle just re-points
;; the auth and resumes a stored session under the new billing. With
;; `agent-shell-session-restore-verbosity' set to `full' (above), the prior
;; conversation is replayed. Kill the rate-limited buffer (C-x k) when done.
(defun my/claude--resume-with-auth (auth label)
  "Set Claude AUTH, announce LABEL, then resume a persisted session."
  (require 'agent-shell)
  (setq agent-shell-anthropic-authentication auth)
  (message "Claude billing -> %s. Pick the session to resume..." label)
  (call-interactively #'agent-shell-resume-session))

(defun my/claude-use-subscription ()
  "Switch Claude Code to Pro/Max subscription login and resume a session."
  (interactive)
  (my/claude--resume-with-auth
   (agent-shell-anthropic-make-authentication :login t)
   "subscription (Pro/Max login)"))

(defun my/claude-use-console ()
  "Switch Claude Code to the console API key (metered) and resume a session.
Reads the key from auth-source; errors early if it is not configured."
  (interactive)
  (unless (auth-source-pick-first-password
           :host "api.anthropic.com" :user "apikey")
    (user-error
     "No console key found: add to ~/.authinfo -> machine api.anthropic.com login apikey password sk-ant-..."))
  (my/claude--resume-with-auth
   (agent-shell-anthropic-make-authentication
    :api-key (lambda ()
               (auth-source-pick-first-password
                :host "api.anthropic.com" :user "apikey")))
   "console API key (metered)"))

;;; ---------------------------------------------------------------------------
;;; 17b. Switch OpenRouter models without restarting Emacs
;;; ---------------------------------------------------------------------------
;; Each agent-shell buffer is its own `qwen' subprocess, and the model is fixed
;; from OPENAI_MODEL at launch. Switching therefore means starting a fresh shell
;; with a different model -- no Emacs restart, and you can keep several open at
;; once (one DeepSeek buffer, one Kimi buffer, switch with C-x b).
(defvar my/openrouter-models
  ;; IDs verified live against https://openrouter.ai/api/v1/models.
  '(("deepseek" . "deepseek/deepseek-v4-flash")   ; fast; -pro for the big one
    ("kimi"     . "moonshotai/kimi-k2.7-code")    ; coding-tuned Kimi
    ("glm"      . "z-ai/glm-5.2"))
  "Friendly name -> OpenRouter model ID.")

(defun my/agent-shell-openrouter (name)
  "Start a fresh OpenRouter-backed Qwen agent-shell using model NAME.
Run it again and pick another model to switch -- no restart needed.
If a shell is reused instead of respawned, kill its buffer (C-x k) first."
  (interactive
   (list (completing-read "OpenRouter model: "
                          (mapcar #'car my/openrouter-models) nil t)))
  (require 'agent-shell)
  (setq agent-shell-qwen-environment
        (agent-shell-make-environment-variables
         :inherit-env t
         "OPENAI_BASE_URL" "https://openrouter.ai/api/v1"
         "OPENAI_MODEL"    (cdr (assoc name my/openrouter-models))))
  (agent-shell-qwen-start))

(global-set-key (kbd "C-c n") #'my/agent-shell-openrouter)

;;; init.el ends here
