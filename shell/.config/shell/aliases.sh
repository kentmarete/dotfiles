# shellcheck shell=bash
# Aliases shared by zsh and bash. Every tool-specific alias is guarded so a
# half-installed machine still gets a working shell.

# --- General -----------------------------------------------------------------
alias c='clear'
alias v='vim'
alias t='tmux'
alias ..='cd ..'
alias ...='cd ../..'
alias reload='exec "${SHELL##*/}"'   # re-exec current shell type
alias dots='cd "$DOTFILES"'

# --- Modern CLI replacements ------------------------------------------------
if has eza; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --git --group-directories-first'
  alias la='eza -a --group-directories-first'
  alias lt='eza --tree --level=2 --git-ignore'
else
  alias ll='ls -lahG'
fi
# bat as cat (plain, no pager). Use `\cat` for the real one.
has bat && alias cat='bat --paging=never --style=plain'
# NOTE: grep is deliberately NOT aliased to rg — their flags differ and that
# breaks muscle memory and pasted commands. Use `rg` directly.
has lazygit && alias lg='lazygit'
has btop && alias top='btop'

# --- Git (short forms; `git <alias>` versions live in ~/.gitconfig) --------
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gap='git add -p'            # interactive staging
alias gb='git branch'
alias gbs='git branches'          # sorted by recent commit
alias gc='git commit'
alias gca='git commit --amend --no-edit'
alias gco='git checkout'
alias gsw='git switch'
alias gswc='git switch -c'
alias grs='git restore'
alias grss='git restore --staged'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gf='git fetch --all --prune'
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gst='git stash'
alias gstp='git stash pop'
alias gwl='git worktree list'

# --- Docker / Kubernetes ----------------------------------------------------
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kd='kubectl describe'
has kubectx && alias kctx='kubectx'
has kubens  && alias kns='kubens'

# --- Rust -----------------------------------------------------------------
alias cb='cargo build'
alias ct='cargo test'
alias cr='cargo run'
alias ck='cargo check'            # not `cc` — that would shadow the C compiler
alias ccl='cargo clippy --all-targets -- -D warnings'
alias cf='cargo fmt'

# --- Java / Spring Boot ---------------------------------------------------
alias mvnc='mvn clean'
alias mvnt='mvn test'
alias mvnp='mvn package'
alias mvnci='mvn clean install'
alias mvnsb='mvn spring-boot:run'
alias gw='./gradlew'
alias gwb='./gradlew build'
alias gwsb='./gradlew bootRun'

# --- Node / TS / Angular / React -------------------------------------------
alias ni='npm install'
alias nr='npm run'
alias nd='npm run dev'
alias nt='npm test'
alias pn='pnpm'
alias ngs='ng serve'
alias ngt='ng test'

# --- Python -----------------------------------------------------------------
alias py='python3'
alias uvr='uv run'
alias venv='uv venv && . .venv/bin/activate'

# --- Shell switching (both shells share this whole config) -----------------
alias tozsh='exec zsh -l'
alias tobash='exec "${HOMEBREW_PREFIX:-/usr/local}/bin/bash" -l'
