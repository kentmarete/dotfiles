# shellcheck shell=bash
# Back up conflicting files, then symlink packages into $HOME with GNU Stow.

STOW_PACKAGES=(shell zsh bash vim tmux git starship mise ghostty karabiner scripts)

backup_conflicts() {
  local pkg="$1" rel target dest moved=0
  while IFS= read -r rel; do
    rel="${rel#./}"
    target="$HOME/$rel"
    if [[ -L $target ]]; then
      # Already pointing into this repo? Leave it alone.
      [[ $(readlink "$target") == *"${DOTFILES##*/}/$pkg/"* ]] && continue
    elif [[ ! -e $target ]]; then
      continue
    fi
    dest="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    warn "backed up ~/$rel → $dest"
    moved=1
  done < <(cd "$DOTFILES/$pkg" && find . \( -type f -o -type l \) ! -name '.DS_Store')
  [[ $moved == 1 ]] && report "Backed up existing files to $BACKUP_DIR"
  return 0
}

link_packages() {
  has stow || die "GNU stow not installed (brew install stow)"
  chmod +x "$DOTFILES"/scripts/.local/bin/* "$DOTFILES"/macos/*.sh "$DOTFILES"/install.sh
  local pkg
  for pkg in "${STOW_PACKAGES[@]}"; do
    backup_conflicts "$pkg"
    # --no-folding: link files, not whole directories, so tools can keep
    # writing their own state into ~/.config/*, ~/.vim, ~/.local/bin
    stow --dir="$DOTFILES" --target="$HOME" --no-folding --restow "$pkg"
    ok "linked $pkg"
  done
  report "Linked packages: ${STOW_PACKAGES[*]}"
}

unlink_packages() {
  local pkg
  for pkg in "${STOW_PACKAGES[@]}"; do
    stow --dir="$DOTFILES" --target="$HOME" --delete "$pkg" && ok "unlinked $pkg"
  done
}

create_local_files() {
  # Git identity — kept out of the repo
  if [[ ! -f $HOME/.gitconfig.local ]]; then
    local name="" email=""
    if is_tty; then
      read -r -p "Git user.name:  " name
      read -r -p "Git user.email: " email
    fi
    cat >"$HOME/.gitconfig.local" <<EOF
# Machine-local git settings (not version-controlled)
[user]
    name = ${name:-CHANGE ME}
    email = ${email:-change-me@example.com}
# [user]
#     signingkey = ~/.ssh/id_ed25519.pub
# [gpg]
#     format = ssh
# [commit]
#     gpgsign = true
EOF
    report "Created ~/.gitconfig.local${name:+ for $name}"
    [[ -z $name ]] && warn "Edit ~/.gitconfig.local to set your git identity"
  fi

  # Shell local overrides — also out of the repo
  if [[ ! -f $HOME/.config/shell/local.sh ]]; then
    cat >"$HOME/.config/shell/local.sh" <<'EOF'
# Machine-local shell settings (not version-controlled). Sourced by zsh and bash.
# export PROJECT_DIRS="$HOME/code:$HOME/work"
# export DOTFILES_NO_ATUIN=1          # use fzf for Ctrl-R instead of atuin
# export GITHUB_TOKEN="$(secret get GITHUB_TOKEN)"   # from macOS Keychain
EOF
    report "Created ~/.config/shell/local.sh"
  fi
}

register_shells() {
  local sh changed=0
  for sh in "$BREW_PREFIX/bin/bash" "$BREW_PREFIX/bin/zsh"; do
    [[ -x $sh ]] || continue
    grep -qx "$sh" /etc/shells && continue
    if confirm "Add $sh to /etc/shells (needs sudo)?"; then
      echo "$sh" | sudo tee -a /etc/shells >/dev/null && changed=1
    else
      warn "Skipped registering $sh (needed only to make it a login shell)"
    fi
  done
  [[ $changed == 1 ]] && report "Registered Homebrew shells in /etc/shells"
  ok "Login shell: $(dscl . -read "/Users/$USER" UserShell | awk '{print $2}') (change with: set-login-shell zsh|bash)"
}
