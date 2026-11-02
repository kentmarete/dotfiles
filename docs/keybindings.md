# Keybindings cheat sheet

## Shell (zsh and bash)
| Keys | Action |
|---|---|
| `Ctrl-R` | History search (Atuin in zsh, fzf in bash) |
| `Ctrl-T` | Fuzzy-insert a file path (with bat preview) |
| `Alt-C` | Fuzzy cd into a subdirectory |
| `Tab` | zsh: fzf-tab completion menu (`<` / `>` switch groups) |
| `↑` / `↓` | History search for the prefix or substring you've typed |
| `Ctrl-Space` | zsh: accept the autosuggestion |
| `Ctrl-X Ctrl-E` | Edit the current command in vim |
| `z <dir>` / `zi` | zoxide jump / interactive jump |

## tmux (prefix = `Ctrl-a`)
| Keys | Action |
|---|---|
| `Ctrl-h/j/k/l` | Move between panes **and** vim splits (no prefix) |
| `prefix \|` / `prefix -` | Split horizontally / vertically (in the current dir) |
| `prefix H/J/K/L` | Resize the pane (repeatable) |
| `Alt-←` / `Alt-→` | Previous / next window |
| `prefix Tab` | Last window |
| `prefix S` | Session tree |
| `prefix P` | Project launcher (`cproj`) |
| `prefix g` | lazygit popup |
| `prefix D` | Dev dashboard window |
| `prefix Enter`, then `v` / `y` | Copy mode: select, then yank to the macOS clipboard |
| `prefix Ctrl-s` / `Ctrl-r` | Save / restore the session (resurrect) |
| `prefix r` | Reload config |
| `prefix I` / `prefix U` | Install / update plugins |

## Vim (leader = `Space`; press it and wait for which-key)
| Keys | Action |
|---|---|
| `gd` `gy` `gi` `gr` | Definition / type definition / implementation / references |
| `K` | Hover docs |
| `[g` / `]g` | Previous / next diagnostic |
| `Tab` / `S-Tab` / `Enter` | Completion next / previous / confirm |
| `Ctrl-j` / `Ctrl-k` | Next / previous snippet placeholder |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action (also on a visual selection) |
| `<leader>qf` | Quick-fix the current line |
| `<leader>F` | Format (format-on-save is also on) |
| `<leader>oi` | Organize imports |
| `<leader>d` / `o` / `s` | Diagnostics / outline / workspace symbols |
| `<leader>e` / `f` / `b` | Files / ripgrep / buffers (fzf) |
| `<leader>n` | File explorer |
| `<leader>gs` / `gb` / `gd` | Git status / blame / diff (fugitive) |
| `]h` `[h` · `<leader>hs` / `hu` | Next/prev hunk · stage/undo hunk |
| `<leader><leader>s` | Easymotion jump |
| `Shift-h` / `Shift-l` | Previous / next buffer |
| `F5` `F3` `F4` `F9` `F10` `F11` `F12` | Debug: continue, stop, restart, breakpoint, over, into, out |
| `<leader>dj` | Start a Java debug session |
| `<leader>di` / `<leader>dq` | Inspect value / reset the debugger |

## macOS
| Keys | Action |
|---|---|
| Caps Lock | Tap = Esc, hold = Ctrl (Karabiner rule) |
| Right ⌘ (hold) | Hyper ⌃⌥⇧⌘. Bind Raycast/Rectangle actions to Hyper+key |
| ``Ctrl-` `` | Ghostty quick (drop-down) terminal |
| ⌃⌥ ←/→/↑/↓, ⌃⌥ Enter | Rectangle: halves / maximize (its defaults) |
| ⌘ Space | Raycast (after replacing Spotlight in Raycast settings) |
