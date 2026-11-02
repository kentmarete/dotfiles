# shellcheck shell=bash
# Xcode CLT + Homebrew + Brewfile. Sourced by install.sh.

ensure_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    ok "Xcode Command Line Tools present"
  else
    info "Installing Xcode Command Line Tools (a dialog will open)…"
    xcode-select --install || true
    die "Re-run ./install.sh once the Command Line Tools installer has finished."
  fi
}

ensure_homebrew() {
  if [[ -x $BREW_PREFIX/bin/brew ]]; then
    ok "Homebrew present at $BREW_PREFIX"
  else
    info "Installing Homebrew to ${BREW_PREFIX}…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    report "Installed Homebrew"
  fi
  load_brew_env
  has brew || die "brew not on PATH after install"
}

brew_bundle() {
  local file="$DOTFILES/brew/Brewfile"
  if brew bundle check --no-upgrade --file="$file" >/dev/null 2>&1; then
    ok "All Brewfile packages already installed"
  else
    info "Installing missing Brewfile packages (this can take a while)…"
    if brew bundle install --no-upgrade --file="$file"; then
      report "brew bundle: installed missing packages"
    else
      warn "Some Brewfile entries failed — see output above (run 'brew bundle check --verbose')"
      report "brew bundle: some packages FAILED"
    fi
  fi
}

# mise provides runtimes AND the CLI tools that have no Homebrew bottle on
# this macOS (see brew/Brewfile). Official installer: one prebuilt binary.
ensure_mise() {
  if has mise; then
    ok "mise $(mise --version | awk '{print $1}')"
  else
    info "Installing mise to ~/.local/bin (prebuilt binary from mise.run)…"
    curl -fsSL https://mise.run | MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh
    report "Installed mise"
  fi
}

ensure_rustup() {
  if has rustup; then
    ok "rustup present ($(command -v rustup))"
  else
    info "Installing rustup (official installer, prebuilt toolchain)…"
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
    report "Installed rustup"
  fi
}
