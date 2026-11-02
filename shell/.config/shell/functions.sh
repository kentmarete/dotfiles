# shellcheck shell=bash
# Functions shared by zsh and bash. Keep syntax portable (no zsh/bash-only arrays).

# --- General -----------------------------------------------------------------
mkcd() { mkdir -p "$1" && cd "$1" || return; }

path() { echo "$PATH" | tr ':' '\n'; }

# Show / kill whatever is listening on a TCP port:  port 8080 / killport 8080
port()     { lsof -nP -iTCP:"$1" -sTCP:LISTEN; }
killport() { lsof -ti tcp:"$1" | xargs kill -9 2>/dev/null && echo "killed :$1" || echo "nothing on :$1"; }

# --- Shells -----------------------------------------------------------------
# Which shell am I in?
whichshell() { ps -p $$ -o comm=; echo "login shell: $SHELL"; }

# Permanently change the login shell: set-login-shell zsh|bash
set-login-shell() {
  local target
  case "$1" in
    zsh)  target=/bin/zsh ;;   # Apple's zsh; Homebrew zsh also works if preferred
    bash) target="${HOMEBREW_PREFIX:-/usr/local}/bin/bash" ;;
    *) echo "usage: set-login-shell zsh|bash"; return 1 ;;
  esac
  [ -x "$target" ] || { echo "$target not found (brew install $1?)"; return 1; }
  if ! grep -qx "$target" /etc/shells; then
    echo "Registering $target in /etc/shells (sudo)…"
    echo "$target" | sudo tee -a /etc/shells >/dev/null || return 1
  fi
  chsh -s "$target" && echo "Login shell is now $target (open a new terminal)."
}

# Measure interactive startup time (spec: shell startup optimisation).
#   shell-bench          -> zsh, 10 runs     shell-bench bash 5
#   ZPROF=1 zsh -i -c exit   -> per-function zsh profile
shell-bench() {
  local sh="${1:-zsh}" n="${2:-10}" i
  echo "Timing $n interactive $sh startups…"
  time (for i in $(seq "$n"); do "$sh" -i -c exit >/dev/null 2>&1; done)
}

# --- Git ----------------------------------------------------------------------
# Fuzzy switch branch (local + remote)
fbr() {
  local branch
  branch=$(git branch --all --sort=-committerdate --format='%(refname:short)' |
    grep -v HEAD | fzf --prompt='branch> ' \
      --preview 'git log --oneline --graph --color=always -20 {}') || return
  git switch "${branch#origin/}"
}

# Fuzzy browse commits, enter shows the commit
flog() {
  git log --oneline --color=always --decorate |
    fzf --ansi --no-sort --preview 'git show --color=always {1} | delta 2>/dev/null || git show --color=always {1}' \
        --bind 'enter:execute(git show {1} | less -R)'
}

# cd into a worktree picked with fzf (wrapper around the `gwt` script)
gwcd() { local p; p=$(gwt path "$@") && [ -n "$p" ] && cd "$p" || return; }

# --- Docker -------------------------------------------------------------------
dsh()    { local c; c=$(docker ps --format '{{.Names}}' | fzf --prompt='exec> ') && docker exec -it "$c" sh -c 'command -v bash >/dev/null && exec bash || exec sh'; }
dlogs()  { local c; c=$(docker ps -a --format '{{.Names}}' | fzf --prompt='logs> ') && docker logs -f --tail 200 "$c"; }
dstop()  { docker ps --format '{{.Names}}' | fzf -m --prompt='stop> ' | xargs -r docker stop; }
dinspect() { local c; c=$(docker ps -a --format '{{.Names}}' | fzf) && docker inspect "$c" | jq . | bat -l json; }
dclean() {
  echo "Removing stopped containers, dangling images, unused networks and build cache…"
  docker container prune -f && docker image prune -f && docker network prune -f && docker builder prune -f
}

# --- Kubernetes -------------------------------------------------------------
# Fallbacks when kubectx/kubens aren't installed.
has kubectx || kctx() { kubectl config use-context "$(kubectl config get-contexts -o name | fzf --prompt='context> ')"; }
has kubens  || kns()  { kubectl config set-context --current --namespace "$(kubectl get ns -o name | sed 's#namespace/##' | fzf --prompt='namespace> ')"; }
kpod()  { kubectl get pods --no-headers "$@" | fzf --prompt='pod> ' | awk '{print $1}'; }
klogs() { local p; p=$(kpod) && kubectl logs -f --tail=200 "$p" "$@"; }
kexec() { local p; p=$(kpod) && kubectl exec -it "$p" -- sh -c 'command -v bash >/dev/null && exec bash || exec sh'; }
kdesc() { local p; p=$(kpod) && kubectl describe pod "$p"; }

# --- Secrets (macOS Keychain; never keep tokens in dotfiles) ---------------
#   secret set GITHUB_TOKEN        (prompts, stores in login keychain)
#   export GITHUB_TOKEN="$(secret get GITHUB_TOKEN)"
secret() {
  case "$1" in
    get) security find-generic-password -a "$USER" -s "$2" -w ;;
    set) local v; printf 'value for %s: ' "$2"; stty -echo; read -r v; stty echo; echo
         security add-generic-password -U -a "$USER" -s "$2" -w "$v" ;;
    rm)  security delete-generic-password -a "$USER" -s "$2" >/dev/null ;;
    *)   echo "usage: secret get|set|rm NAME"; return 1 ;;
  esac
}

# --- Dotfiles -----------------------------------------------------------------
dotfiles-update() {
  (cd "$DOTFILES" && git pull --rebase && ./install.sh --skip-macos) && exec "${SHELL##*/}"
}
