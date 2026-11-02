# shellcheck shell=bash
# PATH setup shared by zsh and bash. Safe to source repeatedly.
# Later prepends win, so the order below is lowest -> highest priority.

has() { command -v "$1" >/dev/null 2>&1; }

# Remove $1 from PATH (if present) then put it at the front.
# Re-prepending matters on macOS: /usr/libexec/path_helper (run by /etc/zprofile
# in every login shell, including new tmux panes) pushes /usr/bin ahead of Homebrew.
path_prepend() {
  [ -d "$1" ] || return 0
  PATH=":${PATH}:"
  PATH="${PATH//:$1:/:}"
  PATH="${PATH#:}"; PATH="${PATH%:}"
  PATH="$1${PATH:+:$PATH}"
}

path_append() {
  [ -d "$1" ] || return 0
  case ":${PATH}:" in *":$1:"*) ;; *) PATH="${PATH:+$PATH:}$1" ;; esac
}

# --- Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local) ------------
if [ -x /opt/homebrew/bin/brew ]; then
  export HOMEBREW_PREFIX=/opt/homebrew
elif [ -x /usr/local/bin/brew ]; then
  export HOMEBREW_PREFIX=/usr/local
fi
if [ -n "${HOMEBREW_PREFIX:-}" ]; then
  # Equivalent of `brew shellenv`, without spawning brew on every shell start.
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  if [ "$HOMEBREW_PREFIX" = /usr/local ]; then
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
  else
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
  fi
  path_prepend "$HOMEBREW_PREFIX/sbin"
  path_prepend "$HOMEBREW_PREFIX/bin"
  export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"

fi

# --- Editors -----------------------------------------------------------------------
# MacVim's terminal vim has +python3 (vimspector); Apple's /usr/bin/vim doesn't.
path_prepend "/Applications/MacVim.app/Contents/bin"

# --- Language tool bins ------------------------------------------------------
path_prepend "$HOME/.cargo/bin"                       # rustup, cargo, rust-analyzer
# mise shims: tools (node, java, starship, fzf, …) work in ANY process —
# vim/coc, tmux popups, scripts. Interactive shells additionally run
# `mise activate`, which puts the real install dirs in front of the shims.
path_prepend "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"

# --- Personal bins (dotfiles scripts are stowed here) -----------------------
path_prepend "$HOME/.local/bin"

# --- Apps that install their own CLIs (kept from the original ~/.zprofile) --
path_append "$HOME/.docker/bin"                                          # Docker Desktop
path_append "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" # JetBrains Toolbox

export PATH
