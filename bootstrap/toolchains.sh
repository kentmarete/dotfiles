# shellcheck shell=bash
# Language toolchains (Rust via rustup, everything else via mise) and editor /
# shell / tmux plugins.

setup_rust() {
  has rustup || { warn "rustup not installed — skipping Rust"; return 0; }
  if ! rustup toolchain list 2>/dev/null | grep -q stable; then
    info "Installing Rust stable toolchain…"
    rustup default stable
    report "Installed Rust stable"
  fi
  rustup component add rust-analyzer clippy rustfmt rust-src >/dev/null 2>&1 &&
    ok "Rust $(rustc --version 2>/dev/null | awk '{print $2}') + rust-analyzer, clippy, rustfmt"
}

setup_mise() {
  has mise || { warn "mise not installed — skipping runtimes"; return 0; }
  info "Installing tools from ~/.config/mise/config.toml (runtimes + CLI tools, prebuilt)…"
  if mise install --yes; then
    ok "mise runtimes installed"
    report "mise: $(mise ls --current 2>/dev/null | awk '{print $1"@"$2}' | tr '\n' ' ')"
  else
    warn "mise install had failures — run 'mise doctor'"
    report "mise install: some runtimes FAILED"
  fi
  mise reshim >/dev/null 2>&1 || true
  has git-lfs && git lfs install --skip-repo >/dev/null 2>&1 || true
  # pgcli (SQL client with autocomplete) — Python app, installed with uv
  if has uv && ! has pgcli; then
    uv tool install 'pgcli' >/dev/null 2>&1 && ok "pgcli installed" || warn "pgcli install failed (uv tool install pgcli)"
  fi
}

setup_sheldon() {
  has sheldon || { warn "sheldon not installed — zsh plugins skipped"; return 0; }
  sheldon lock --update >/dev/null && ok "zsh plugins (sheldon) locked"
  rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/zsh/init-*.zsh   # refresh cached init scripts
}

setup_vim() {
  has vim || return 0
  local plug="$HOME/.vim/autoload/plug.vim"
  if [[ ! -f $plug ]]; then
    curl -fsLo "$plug" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  info "Installing vim plugins…"
  vim -Es -u "$HOME/.vimrc" -i NONE -c 'PlugInstall --sync' -c 'qa!' </dev/null >/dev/null 2>&1 || true
  if [[ -d $HOME/.vim/plugged/coc.nvim ]]; then
    ok "vim plugins installed (coc language extensions install on first launch)"
    report "Vim plugins installed"
  else
    warn "vim plugin install may have failed — open vim and run :PlugInstall"
  fi
}

setup_tmux() {
  has tmux || return 0
  local tpm="$HOME/.tmux/plugins/tpm"
  [[ -d $tpm ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm" >/dev/null 2>&1
  "$tpm/bin/install_plugins" >/dev/null 2>&1 && ok "tmux plugins installed" ||
    warn "tmux plugin install failed — start tmux and press Ctrl-a I"
  "$tpm/bin/update_plugins" all >/dev/null 2>&1 || true
}

setup_bat_theme() {
  has bat && bat cache --build >/dev/null 2>&1 || true
}
