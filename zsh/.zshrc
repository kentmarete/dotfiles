# ~/.zshrc — interactive zsh. Profile startup with:  ZPROF=1 zsh -i -c exit
[[ -n $ZPROF ]] && zmodload zsh/zprof

# --- Shared config (same files are sourced by ~/.bashrc) -------------------
for _f in path environment fzf aliases functions; do
  [[ -r $HOME/.config/shell/$_f.sh ]] && source "$HOME/.config/shell/$_f.sh"
done
# Machine-specific, untracked overrides (PROJECT_DIRS, work proxies, …)
[[ -r $HOME/.config/shell/local.sh ]] && source "$HOME/.config/shell/local.sh"
unset _f
typeset -U path fpath   # dedupe

# --- Options ------------------------------------------------------------------
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history share_history hist_ignore_all_dups hist_ignore_space \
       hist_reduce_blanks hist_verify
setopt auto_cd auto_pushd pushd_ignore_dups interactive_comments no_beep
bindkey -e                                   # emacs keys (Ctrl-A/E etc.)
autoload -Uz edit-command-line && zle -N edit-command-line
bindkey '^X^E' edit-command-line             # edit current command in $EDITOR

# --- Completion styling (fzf-tab reads these) -----------------------------
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no               # let fzf-tab own the menu
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:(cat|bat|vim|v):*' fzf-preview 'bat --color=always --line-range=:200 $realpath 2>/dev/null || eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:git-(switch|checkout|log|diff):*' fzf-preview 'git log --oneline --graph --color=always -20 $word'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps -p $word -o pid,user,%cpu,%mem,command'
zstyle ':fzf-tab:*' switch-group '<' '>'

# --- Cached tool init (regenerated only when the binary changes) ----------
_evalcache() {
  local name=$1; shift
  local bin=${commands[$1]}
  [[ -z $bin ]] && return 0
  local cache="$XDG_CACHE_HOME/zsh/init-$name.zsh"
  # mise-managed tools are shims whose mtime never changes; watch the tool's
  # install dir instead (a new version dir appears there on upgrade).
  local inst="$XDG_DATA_HOME/mise/installs/$1"
  if [[ ! -s $cache || $bin -nt $cache || ( -d $inst && $inst -nt $cache ) ]]; then
    mkdir -p ${cache:h} && "$@" >| $cache
  fi
  source $cache
}

_evalcache mise     mise activate zsh       # runtimes: node, java, python, …
_evalcache fzf      fzf --zsh               # Ctrl-T, Ctrl-R, Alt-C
_evalcache zoxide   zoxide init zsh         # z <dir>, zi (interactive)
_evalcache starship starship init zsh       # prompt (branch-aware)
# Atuin replaces fzf's Ctrl-R with synced, searchable history. Up-arrow stays
# with history-substring-search. Disable with DOTFILES_NO_ATUIN=1 in local.sh.
[[ -z $DOTFILES_NO_ATUIN ]] && _evalcache atuin atuin init zsh --disable-up-arrow

# --- Plugins (Sheldon). Order is defined in ~/.config/sheldon/plugins.toml:
#     zsh-completions(fpath) -> compinit -> fzf-tab -> autosuggestions
#     -> syntax-highlighting -> history-substring-search
if (( $+commands[sheldon] )); then
  # Regenerate the cached plugin script when plugins.toml changes.
  [[ $HOME/.config/sheldon/plugins.toml -nt $XDG_CACHE_HOME/zsh/init-sheldon.zsh ]] &&
    rm -f $XDG_CACHE_HOME/zsh/init-sheldon.zsh
  _evalcache sheldon sheldon source
else
  autoload -Uz compinit && compinit
fi

# history-substring-search: type a fragment, then Up/Down
if (( $+functions[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P'   history-substring-search-up
  bindkey '^N'   history-substring-search-down
fi
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^ ' autosuggest-accept              # Ctrl-Space accepts suggestion

[[ -n $ZPROF ]] && zprof
true
