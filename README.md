# Emacs configuration

A small, auditable Emacs config for Clojure/Java work, with an in-editor LLM
agent shell. No distribution framework — just `init.el` built on the built-in
`use-package`, `eglot`, and a curated package set.

- **Day-to-day usage & keybindings:** see [`EMACS-GUIDE.md`](EMACS-GUIDE.md).
- **This file:** how to get the config running on a **new machine**.

## What's in the repo

| File | Purpose |
|------|---------|
| `early-init.el` | GC/startup tuning, disables UI chrome before the frame paints |
| `init.el` | the whole configuration (numbered sections) |
| `custom.el` | Emacs Customize state (auto-written) |
| `.gitignore` | keeps packages, secrets, and generated state out of git |
| `EMACS-GUIDE.md` | onboarding cheat-sheet |
| `README.md` | this file |

**Deliberately not tracked** (so the repo stays portable and secret-free):
installed packages (`elpa/`), all credentials, and generated state
(`recentf`, histories, `package-quickstart.el`, `agent/`). These are recreated
per machine — see below.

## Requirements

- **Emacs 30+** (works in GUI and terminal `-nw`). Uses built-in `use-package`
  and `eglot`, so nothing to install for those.
- **git**, and network access to the GNU/NonGNU/MELPA package archives on first
  launch.

## Install on a new machine

```sh
# Back up any existing config first.
mv ~/.emacs.d ~/.emacs.d.bak 2>/dev/null || true

git clone <YOUR_REMOTE_URL> ~/.emacs.d
emacs
```

On first launch `init.el` refreshes the archives and installs every package via
`use-package :ensure t`. This takes a minute or two; let it finish, then
**restart Emacs once** so `early-init.el` and `package-quickstart` take effect.

After adding/removing packages later, run `M-x package-quickstart-refresh`.

## External tools (install what you use)

The config degrades gracefully — a missing tool just disables its feature, it
does not break startup. macOS `brew` shown; use your platform's package manager
elsewhere.

```sh
# Editor conveniences
brew install ripgrep                          # C-c s project-wide search
brew install --cask font-jetbrains-mono       # configured UI font (falls back if absent)

# Clojure / Java
brew install clojure/tools/clojure            # REPL / CLI  (CIDER: C-c M-j)
brew install borkdude/brew/clj-kondo          # Clojure linting
brew install clojure-lsp/brew/clojure-lsp     # Clojure static navigation (optional)
brew install jdtls                            # Java LSP (optional)
brew install pandoc                           # Markdown preview (optional)
```

## LLM agent shell (`agent-shell`)

The config drives coding agents over ACP from inside Emacs (section 17 of
`init.el`). Two providers are wired up:

- **Claude Code** — `C-c a` to start; billing toggles `C-c c s` (subscription)
  / `C-c c c` (console API key), which resume a prior session from a menu.
- **OpenRouter** (via the Qwen Code agent) — `C-c n`, then pick a model
  (`deepseek` / `kimi` / `glm`). Switches model without restarting Emacs.

### Per-machine setup for the agents

**1. Install the agent CLIs** (Node binaries — note the added supply chain):

```sh
npm install -g @qwen-code/qwen-code            # `qwen`  — used for OpenRouter
npm install -g @agentclientprotocol/claude-agent-acp   # Claude Code agent
claude setup-token                             # authenticate the Claude CLI once
```

**2. Provide credentials via `auth-source`, never in the repo.** Create
`~/.authinfo` (or the encrypted `~/.authinfo.gpg`) with the hosts the config
looks up:

```
machine openrouter.ai password sk-or-...
machine api.anthropic.com login apikey password sk-ant-...
```

Then lock it down:

```sh
chmod 600 ~/.authinfo
```

The config reads keys by host at runtime; if a key is missing the relevant
command errors early with a clear message rather than hanging. Model IDs live in
`init.el` (`my/openrouter-models`) and can be checked against
`https://openrouter.ai/api/v1/models`.

## Notes & conventions

- **Default folder:** Emacs opens into `~/dev/` if it exists (`my/dev-dir` in
  `init.el`); otherwise it stays put. Create it or edit that variable.
- **Secrets never live in this repo** — only in `~/.authinfo[.gpg]`, which is
  outside `~/.emacs.d`. Keep it that way.
- **`custom.el`** is auto-written by Emacs; commit changes to it deliberately.

## Updating another machine later

```sh
cd ~/.emacs.d && git pull
# in Emacs, if packages changed:  M-x package-quickstart-refresh   then restart
```
