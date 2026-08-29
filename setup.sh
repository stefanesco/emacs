#!/usr/bin/env bash
set -euo pipefail

# Setup script for Tudor's Emacs configuration.
# Installs all external tools that init.el expects on PATH.
# Safe to re-run: skips anything already installed.
#
# Usage:  ./setup.sh          -- install everything
#         ./setup.sh --check   -- dry-run: report what is missing

CHECK_ONLY=false
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

MISSING=()

need() {
  local cmd="$1" label="$2" install="$3"
  if command -v "$cmd" &>/dev/null; then
    printf "  ✓  %-20s %s\n" "$label" "$(command -v "$cmd")"
  else
    printf "  ✗  %-20s MISSING\n" "$label"
    MISSING+=("$install")
  fi
}

need_font() {
  local name="$1" install="$2"
  if fc-list 2>/dev/null | grep -qi "jetbrains" || \
     compgen -G "$HOME/Library/Fonts/*JetBrains*" &>/dev/null || \
     compgen -G "/Library/Fonts/*JetBrains*" &>/dev/null; then
    printf "  ✓  %-20s installed\n" "$name"
  else
    printf "  ✗  %-20s MISSING\n" "$name"
    MISSING+=("$install")
  fi
}

need_npm() {
  local cmd="$1" pkg="$2"
  if command -v "$cmd" &>/dev/null; then
    printf "  ✓  %-20s %s\n" "$pkg" "$(command -v "$cmd")"
  else
    printf "  ✗  %-20s MISSING\n" "$pkg"
    MISSING+=("npm install -g $pkg")
  fi
}

echo ""
echo "Checking Emacs config dependencies..."
echo ""
echo "── Core tools ──────────────────────────────────────────"
need emacs       "Emacs 29+"             "brew install emacs"
need git         "git"                   "brew install git"
need zsh         "zsh"                   ":"

echo ""
echo "── Clojure toolchain ─────────────────────────────────"
need clojure     "Clojure CLI"           "brew install clojure/tools/clojure"
need clj-kondo   "clj-kondo"            "brew install borkdude/brew/clj-kondo"
need clojure-lsp "clojure-lsp"          "brew install clojure-lsp/brew/clojure-lsp-native"

echo ""
echo "── Java (optional) ───────────────────────────────────"
need jdtls       "jdtls (Java LSP)"     "brew install jdtls"

echo ""
echo "── Data formats ────────────────────────────────────────"
need pandoc      "pandoc"                "brew install pandoc"
need xmllint     "xmllint"               ":"

echo ""
echo "── LLM agent shell ───────────────────────────────────"
need node        "Node.js"               "brew install node"
need_npm claude  "@agentclientprotocol/claude-agent-acp"
need_npm qwen    "@qwen-code/qwen-code"

echo ""
echo "── Font ──────────────────────────────────────────────"
need_font "JetBrains Mono"  "brew install --cask font-jetbrains-mono"

echo ""

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "All dependencies are installed."
  exit 0
fi

echo "${#MISSING[@]} missing dependencies."
echo ""

if $CHECK_ONLY; then
  echo "Run without --check to install them."
  exit 1
fi

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

echo "Installing missing dependencies..."
echo ""

for cmd in "${MISSING[@]}"; do
  [[ "$cmd" == ":" ]] && continue
  echo "→ $cmd"
  eval "$cmd"
  echo ""
done

echo ""
echo "── Post-install steps (manual) ───────────────────────"
echo ""
echo "1. Authenticate Claude Code (run once outside Emacs):"
echo "     claude setup-token"
echo ""
echo "2. Add API keys to ~/.authinfo for agent-shell billing:"
echo "     machine api.anthropic.com login apikey password sk-ant-..."
echo "     machine openrouter.ai password sk-or-..."
echo ""
echo "3. Start Emacs — packages install automatically on first launch."
echo ""
echo "Done."
