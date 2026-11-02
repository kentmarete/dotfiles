#!/usr/bin/env bash
# Idempotent workstation installer. Safe to re-run at any time.
#
#   ./install.sh                 full install (brew, links, toolchains, plugins)
#   ./install.sh --link-only     only (re)create symlinks
#   ./install.sh --skip-brew     don't run brew bundle
#   ./install.sh --skip-toolchains --skip-plugins
#   ./install.sh --macos         also apply macOS defaults (macos/defaults.sh)
#   ./install.sh --yes           answer yes to prompts
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# shellcheck source=bootstrap/lib.sh
source "$DOTFILES/bootstrap/lib.sh"
source "$DOTFILES/bootstrap/homebrew.sh"
source "$DOTFILES/bootstrap/link.sh"
source "$DOTFILES/bootstrap/toolchains.sh"

DO_BREW=1 DO_TOOLCHAINS=1 DO_PLUGINS=1 DO_MACOS=0 ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --link-only)       DO_BREW=0 DO_TOOLCHAINS=0 DO_PLUGINS=0 ;;
    --skip-brew)       DO_BREW=0 ;;
    --skip-toolchains) DO_TOOLCHAINS=0 ;;
    --skip-plugins)    DO_PLUGINS=0 ;;
    --macos)           DO_MACOS=1 ;;
    --skip-macos)      DO_MACOS=0 ;;
    --yes|-y)          ASSUME_YES=1 ;;
    -h|--help)         sed -n '2,9p' "$0"; exit 0 ;;
    *) die "unknown option: $arg" ;;
  esac
done
export ASSUME_YES

[[ $(uname -s) == Darwin ]] || die "This installer targets macOS."
detect_arch

step "Preflight"
ok "macOS $(sw_vers -productVersion), $ARCH ($([[ $ARCH == arm64 ]] && echo 'Apple Silicon' || echo Intel))"
ensure_clt

step "Homebrew"
if [[ $DO_BREW == 1 ]]; then
  ensure_homebrew
  brew_bundle
else
  load_brew_env
  info "skipped (--skip-brew)"
fi

step "Symlinks"
link_packages
create_local_files

step "Shells"
register_shells

if [[ $DO_TOOLCHAINS == 1 ]]; then
  step "Toolchains"
  ensure_rustup
  ensure_mise
  setup_rust
  setup_mise
fi

if [[ $DO_PLUGINS == 1 ]]; then
  step "Plugins"
  setup_sheldon
  setup_vim
  setup_tmux
  setup_bat_theme
fi

if [[ $DO_MACOS == 1 ]]; then
  step "macOS defaults"
  if [[ $ASSUME_YES == 1 ]]; then "$DOTFILES/macos/defaults.sh" --yes; else "$DOTFILES/macos/defaults.sh"; fi
  report "Applied macOS defaults"
fi

step "Validation"
"$HOME/.local/bin/dotfiles-doctor" || warn "doctor reported problems (see above)"

step "Summary"
if [[ ${#REPORT[@]} -gt 0 ]]; then printf '  • %s\n' "${REPORT[@]}"; else echo "  Nothing changed — already up to date."; fi
cat <<'EOF'

Next steps:
  exec zsh                     reload the shell
  tmux                         start tmux (Ctrl-a is the prefix)
  vim                          first launch installs coc language servers
  :VimspectorInstall           (in vim) install debug adapters
  Karabiner → Complex Modifications → Add rule → "Dotfiles: developer keyboard"
EOF
