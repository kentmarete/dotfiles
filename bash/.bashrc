# ~/.bashrc — interactive bash. Shares env/aliases/functions with zsh via
# ~/.config/shell/*.sh. Prefer Homebrew bash 5 (`tobash`); /bin/bash 3.2 works
# but loses some completion features.

# Non-interactive shells (scp, scripts): PATH only, then stop.
. "$HOME/.config/shell/path.sh"
case $- in *i*) ;; *) return ;; esac

for _f in environment fzf aliases functions local; do
  [ -r "$HOME/.config/shell/$_f.sh" ] && . "$HOME/.config/shell/$_f.sh"
done
unset _f

# --- Options & history ----------------------------------------------------
export BASH_SILENCE_DEPRECATION_WARNING=1   # macOS "default shell is now zsh" nag
HISTFILE="$HOME/.bash_history"
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
shopt -s histappend checkwinsize cmdhist
if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
  shopt -s autocd globstar dirspell cdspell
fi
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- Completion (bash-completion@2 also loads git, brew, docker, kubectl …) --
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
  . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
fi
# Complete the `g` alias like git
if declare -F __git_complete >/dev/null 2>&1; then __git_complete g __git_main; fi
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set colored-stats on'
bind '"\e[A": history-search-backward'   # type a prefix, then Up/Down
bind '"\e[B": history-search-forward'

# --- Tools --------------------------------------------------------------------
has mise     && eval "$(mise activate bash)"
has fzf      && eval "$(fzf --bash)"
has zoxide   && eval "$(zoxide init bash)"
has starship && eval "$(starship init bash)"
