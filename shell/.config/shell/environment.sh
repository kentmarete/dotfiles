# shellcheck shell=bash
# Environment variables shared by zsh and bash.

export DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# XDG base directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Locale & editor
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESS='-R -F -i -M'

# Homebrew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_BUNDLE_FILE="$DOTFILES/brew/Brewfile"

# bat as man pager
if has bat; then
  export BAT_THEME="gruvbox-dark"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi

# Where `cproj` looks for projects (colon-separated). Override in local.sh.
export PROJECT_DIRS="${PROJECT_DIRS:-$HOME/code:$HOME/projects:$HOME/src:$HOME/work:$HOME/equity:$HOME/fin}"

# Language-specific
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
export MAVEN_OPTS="${MAVEN_OPTS:--Xmx2g}"
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=4096}"
export PYTHONDONTWRITEBYTECODE=1
export DOCKER_BUILDKIT=1
# NOTE: JAVA_HOME is intentionally NOT hardcoded — mise sets it per project.
