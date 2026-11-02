# shellcheck shell=bash
# Shared helpers for install.sh and bootstrap/*.sh

info()  { printf '\033[34m›\033[0m %s\n' "$*"; }
ok()    { printf '\033[32m✔\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
die()   { printf '\033[31m✘\033[0m %s\n' "$*" >&2; exit 1; }
step()  { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }
has()   { command -v "$1" >/dev/null 2>&1; }
is_tty() { [[ -t 0 && -t 1 ]]; }

# Report lines collected for the final summary
REPORT=()
report() { REPORT+=("$*"); }

confirm() {  # confirm "question" -> 0 yes / 1 no (auto-yes when ASSUME_YES=1)
  [[ ${ASSUME_YES:-0} == 1 ]] && return 0
  is_tty || return 1
  local a; read -r -p "$1 [y/N] " a; [[ $a =~ ^[Yy]$ ]]
}

detect_arch() {
  ARCH=$(uname -m)
  if [[ $ARCH == arm64 ]]; then BREW_PREFIX=/opt/homebrew; else BREW_PREFIX=/usr/local; fi
  export ARCH BREW_PREFIX
}

load_brew_env() {
  [[ -x $BREW_PREFIX/bin/brew ]] && eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  # rustup (~/.cargo), mise binary (~/.local/bin) and mise-managed tools (shims)
  export PATH="$HOME/.local/share/mise/shims:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
}
