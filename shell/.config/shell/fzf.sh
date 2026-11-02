# shellcheck shell=bash
# fzf settings shared by zsh and bash. Key bindings are loaded per-shell in
# .zshrc / .bashrc via `fzf --zsh` / `fzf --bash`.
#   Ctrl-T  files      Ctrl-R  history      Alt-C  cd into directory

if has fd; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

export FZF_DEFAULT_OPTS="
  --height 80% --layout=reverse --border --info=inline
  --bind 'ctrl-/:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up'
"

# Previews only where they make sense (not on Ctrl-R history lines).
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null || cat {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons {} 2>/dev/null || ls {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:hidden:wrap"
