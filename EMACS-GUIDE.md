# Emacs Dev Guide

A getting-started cheat-sheet for this Emacs configuration (Emacs 30+, `~/.emacs.d`).
Every keybinding below was verified against the actual config.

## Notation

| Symbol | Key |
|--------|-----|
| `C-x`  | hold **Ctrl**, press `x` |
| `M-x`  | hold **Meta** (⌥ Option / Alt), press `x` |
| `S-`   | **Shift** |
| `RET` / `SPC` / `DEL` | Enter / Space / Backspace |
| `C-c l` | Ctrl-c, then `l` (chords in sequence) |

**You do not need to memorize this.** Start a chord (e.g. press `C-c` and wait) and
**which-key** pops up a menu of every key that can follow. `M-x` lets you run any
command by name with live filtering. When stuck: `C-g` cancels anything.

## Before you start (external tools)

The config enables features that call out to command-line tools. Install what you use:

```sh
brew install ripgrep                          # C-c s project search
brew install --cask font-jetbrains-mono       # the configured UI font
brew install jdtls                            # Java LSP (optional)
brew install clojure-lsp/brew/clojure-lsp     # Clojure static nav (optional)
brew install clojure leiningen                # to run a Clojure REPL
```

Missing tools fail gracefully — LSP just won't start, `C-c s` will complain, etc.

---

## Cheat-sheet

### Discover & get help
| Key | Does |
|-----|------|
| *(start any chord & wait)* | which-key shows what keys follow |
| `M-x` | run a command by name |
| `C-g` | cancel / quit the current action |
| `C-h k` | describe what a key does |
| `C-h f` / `C-h v` | describe a function / variable |
| `C-h B` | Embark: list actions available right now |

### Files & folders
| Key | Does |
|-----|------|
| `C-x C-f` | open / create a file (type path; `~/dev/` is the default) |
| `C-x C-s` | save |
| `C-x C-w` | save as |
| `C-c r` | reopen a **recent** file |
| `C-x d` | **dired** — browse a folder |
| `C-c t` | toggle **treemacs** side tree |
| `C-x C-c` | quit Emacs |

In **dired**: `RET` open, `^` go up, `+` new dir, `C` copy, `R` rename, `D` delete, `g` refresh.
In **treemacs**: `RET` open, `TAB` fold/unfold, `cf`/`cd` create file/dir, `d` delete.

### Buffers & windows
| Key | Does |
|-----|------|
| `C-x b` | switch buffer (**consult** — live preview, recent first) |
| `C-x k` | kill (close) a buffer |
| `C-x o` | move to the other window |
| `C-x 2` / `C-x 3` | split below / split right |
| `C-x 1` | close all other windows |
| `C-x 0` | close this window |
| `S-<arrow>` | move between windows by direction |

### Search & jump
| Key | Does |
|-----|------|
| `C-s` / `C-r` | incremental search forward / back (shows `n/total`) |
| `C-c l` | **consult-line** — fuzzy-search lines in this buffer |
| `C-c s` | **consult-ripgrep** — search the whole project |
| `C-c i` | **consult-imenu** — jump to a function/definition |
| `M-g g` | go to line number |
| `M-y` | paste from **kill-ring** history (browse past copies) |

### Minibuffer (whenever it's asking you to pick something)
- Just **type** to filter — order-independent (`orderless`): `js idx` matches `js-indent-level`.
- `C-n` / `C-p` (or arrows) move; `RET` selects.
- **Marginalia** shows docs/metadata next to each candidate.
- `C-.` (**Embark**) acts on the highlighted candidate (open, delete, copy path…).

### Completion while typing (Corfu)
- A popup appears automatically after 2 chars. `TAB`/`RET` accept, `C-n`/`C-p` move.
- Press `SPC` inside the popup to keep filtering with a space (orderless separator).

### Editing
| Key | Does |
|-----|------|
| `C-SPC` | start selecting (set mark); move to extend |
| `C-w` / `M-w` | cut / copy region |
| `C-y` | paste; `M-y` cycle through older pastes |
| `C-/` | undo (repeat to keep undoing) |
| `M-%` | query-replace (interactive find/replace) |
| `C-x SPC` | rectangle selection (column edits) |
| `<f3>` / `<f4>` | record / replay a keyboard macro |

### Git (Magit)
| Key | Does |
|-----|------|
| `C-x g` | open **magit-status** |

Inside Magit: `s` stage, `u` unstage, `c c` commit, `P p` push, `F p` pull,
`b b` switch branch, `l l` log, `TAB` expand a diff, `q` quit. `?` shows all.

---

## Standard scenarios

### 1. Fire up a Clojure REPL and evaluate code
1. Open a file in a Clojure project (a folder with `deps.edn` or `project.clj`): `C-x C-f`.
2. Start the REPL: **`C-c M-j`** (`cider-jack-in-clj`). *(ClojureScript: `C-c M-J`.)*
   Wait for the REPL buffer to connect.
3. Evaluate as you work:
   - `C-x C-e` — eval the expression **before the cursor**, result in the echo area.
   - `C-c C-c` — eval the **top-level form** the cursor is in.
   - `C-c C-k` — load the **whole buffer**.
   - `C-c C-p` — eval and **pretty-print** into a popup.
4. `C-c C-z` — jump to the REPL buffer (and back).
5. Look things up: `C-c C-d` (docs prefix — which-key shows options; `C-c C-d C-d` = doc for symbol at point).
   Jump to a definition with `M-.`, come back with `M-,`.
6. Tests live under the `C-c C-t` prefix; quit the REPL with `C-c C-q`.

### 2. Open a JSON file, read it, pretty-print it
1. `C-x C-f` the `.json` file — it opens in `json-mode`.
2. If it's minified/ugly, **`C-c j`** (`json-pretty-print-buffer`) reformats it with 2-space
   indentation:
   ```
   {"name":"demo","tags":["a","b"]}   ->   {
                                              "name": "demo",
                                              "tags": [
                                                "a",
                                                "b"
                                              ]
                                            }
   ```
3. Navigate it:
   - `C-c l` (consult-line) then type a key name to jump to it.
   - `C-s` for quick incremental search.
   - `C-M-f` / `C-M-b` hop over whole `{...}` / `[...]` blocks; `C-M-u` jump out to the enclosing one.
4. `C-x C-s` to save.

### 3. Edit the same thing in many places
Pick the tool that fits:
- **Find/replace:** `M-%`, type old `RET` new `RET`, then `y`/`n` per match (`!` = all).
- **Search-then-edit-a-list:** `C-c s` (ripgrep across project) → in the results press
  `C-.` → **Export** to a writable buffer, edit every match, save to apply back.
- **Column / block editing:** `C-x SPC` to mark a rectangle, then `C-x r t` (string-rectangle)
  to type text onto every selected line.
- **Repeatable edit:** `<f3>` start recording, do the edit once, `<f4>` to record-stop and then
  replay it on the next occurrence; keep pressing `<f4>`.

### 4. Search the whole project and open a hit
1. `C-c s` (needs `ripgrep`), type your query — results stream in with live preview.
2. `C-n`/`C-p` to move, `RET` to jump to the file at that line.
3. Prefer a file tree? `C-c t` opens treemacs, rooted at the project.

### 5. Structural editing of Lisp/Clojure (paredit)
Parens stay balanced automatically. Most-used moves:
| Key | Does |
|-----|------|
| `C-<right>` | **slurp** — pull the next form *into* the current parens |
| `C-<left>`  | **barf** — push the last form *out* of the parens |
| `M-(` | wrap the next form in `( )` |
| `M-s` | splice — remove the surrounding parens |
| `M-r` | raise — replace the parent form with this one |
| `C-k` | kill to end of line, staying balanced |
| `C-M-f` / `C-M-b` | move over whole expressions |

### 6. Commit your work (Magit)
1. `C-x g` — status buffer.
2. Move to a change, `TAB` to view the diff, `s` to stage it (or `s` on a whole section).
3. `c c` — write a commit message, then `C-c C-c` to finish.
4. `P p` — push.

---

## Troubleshooting
- **Something's stuck / half-typed a key:** `C-g`.
- **"I don't remember the key":** `M-x` and search by name, or start the chord and read which-key.
- **A command says a tool is missing:** install it from the list at the top.
- **After adding/removing packages:** run `M-x package-quickstart-refresh`, then restart.
- **Undo too far:** `C-/` undoes; `C-g` then `C-/` "redoes" by undoing the undo.
