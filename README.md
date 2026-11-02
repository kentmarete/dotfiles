# dotfiles: macOS engineering workstation

These dotfiles set up a Mac for development: **Zsh** as the default shell, with **Bash** fully configured as an alternative, plus **Vim**, **tmux** and **Homebrew**. The toolchains cover Rust, Java and Spring Boot, Node, TypeScript, Angular, React and React Native, Python, SQL, Docker and Kubernetes.
GNU Stow symlinks every package into `$HOME`. The installer is idempotent, so you can re-run it at any time.

## Install on a new Mac

```sh
xcode-select --install                       # 1. Apple command-line tools
git clone <this-repo-url> ~/dotfiles         # 2. clone (must live at ~/dotfiles, or export DOTFILES)
cd ~/dotfiles
./install.sh                                 # 3. Homebrew + Brewfile + links + toolchains + plugins
./install.sh --macos                         #    (optional) also apply macOS defaults
exec zsh                                     # 4. reload
```

`install.sh` does the following:
1. Detects Apple Silicon or Intel and checks for the Command Line Tools.
2. Installs Homebrew only if it is missing, then installs only the missing Brewfile packages.
3. Moves any existing dotfiles that conflict to `~/.dotfiles-backup/<timestamp>/`, then stows each package.
4. Creates the untracked `~/.gitconfig.local` (your git identity) and `~/.config/shell/local.sh`.
5. Registers Homebrew bash and zsh in `/etc/shells`. It asks first, because this needs sudo.
6. Installs Rust stable (with rust-analyzer, clippy and rustfmt) and the mise runtimes: JDK 21 and 25, Node LTS, Python, Maven, Gradle, pnpm, tsc, ng and eslint.
7. Installs the Sheldon, vim-plug and TPM plugins.
8. Runs `dotfiles-doctor` and prints a report.

Flags: `--link-only`, `--skip-brew`, `--skip-toolchains`, `--skip-plugins`, `--macos`, `--yes`.
Run `make help` to list the Makefile shortcuts (`make doctor`, `make update`, `make bench`, `make unlink`, …).

## Layout

| Dir | Stowed to | What |
|---|---|---|
| `shell/` | `~/.config/shell/` | **Shared** `path.sh`, `environment.sh`, `aliases.sh`, `functions.sh`, `fzf.sh`, sourced by both zsh and bash |
| `zsh/` | `~/.zshrc`, `~/.zprofile`, `~/.config/sheldon/plugins.toml` | Zsh with Sheldon plugins |
| `bash/` | `~/.bashrc`, `~/.bash_profile` | Bash with bash-completion@2 |
| `vim/` | `~/.vimrc`, `~/.vim/coc-settings.json` | Vim IDE: coc.nvim, fzf, fugitive, vimspector |
| `tmux/` | `~/.tmux.conf` | tmux + TPM, resurrect/continuum, vim-tmux-navigator |
| `git/` | `~/.gitconfig`, `~/.config/git/ignore` | delta, aliases, sensible defaults |
| `starship/` | `~/.config/starship.toml` | Prompt (branch, status, language versions) |
| `mise/` | `~/.config/mise/config.toml` | Global runtime versions |
| `ghostty/` | `~/.config/ghostty/config` | Terminal |
| `karabiner/` | `~/.config/karabiner/assets/…` | Caps Lock = Esc/Ctrl, Right Cmd = Hyper |
| `scripts/` | `~/.local/bin/` | `cproj`, `gwt`, `devdash`, `dotfiles-doctor` |
| `brew/Brewfile` | — | Every package and app |
| `macos/defaults.sh` | — | Finder, Dock, keyboard and screenshot defaults |
| `bootstrap/` | — | Installer modules |

## Switching shells

The two shells share the same environment, aliases and functions, so switching between them loses nothing.

```sh
tobash / tozsh              # exec into the other shell (alias)
whichshell                  # current process and login shell
set-login-shell bash|zsh    # change the login shell permanently (registers in /etc/shells)
```

## Daily tools

| Command | What |
|---|---|
| `cproj` / tmux `prefix P` | Fuzzy-pick a project and open or attach its tmux session (editor, shell and lazygit windows) |
| `gwt add feat/x` · `gwcd` · `gwt tmux` · `gwt rm` | Git worktree manager (worktrees live in `../<repo>.worktrees/`) |
| `devdash` / tmux `prefix D` | Dashboard window with btop, live git status and docker ps |
| `fbr`, `flog` | Fuzzy branch switch and commit browser |
| `dsh`, `dlogs`, `dstop`, `dclean` | Docker helpers |
| `kctx`, `kns`, `klogs`, `kexec` | Kubernetes context, namespace and pod helpers |
| `secret set/get NAME` | Store tokens in the macOS Keychain, never in files |
| `port 8080`, `killport 8080` | Show or kill what's listening on a port |
| `shell-bench`, `ZPROF=1 zsh -i -c exit` | Measure and profile shell startup |
| `dotfiles-doctor` | Health check |

See [docs/keybindings.md](docs/keybindings.md) for all Vim, tmux, shell and macOS shortcuts.

## Per-project runtimes

mise switches versions automatically when you `cd` into a directory. It sets `JAVA_HOME` too.

```sh
mise use java@temurin-17 node@20   # writes mise.toml in the project
```

It also reads the existing `.nvmrc`, `.java-version` and `.python-version` files.

## Machine-local & secrets

These files are never committed:
- `~/.gitconfig.local`: name, email and signing key
- `~/.config/shell/local.sh`: `PROJECT_DIRS`, work-specific env
- `~/.vimrc.local`, `~/.tmux.local.conf`

Store tokens in the Keychain with `secret set`. SSH keys stay in `~/.ssh` and are not stowed.

## Design notes and deviations from the original plan

- **Homebrew only installs prebuilt ("bottled") packages.** On macOS 14 (Sonoma), Homebrew no longer has prebuilt versions of many formulae, so it compiles them from source. `starship` alone pulls in a Rust and LLVM build that takes hours. Those tools come from **mise** instead, which downloads release binaries: starship, sheldon, fzf, atuin, yq, delta, lazygit, gh, git-lfs, uv, ruff, neovim, kubectl and helm. Before adding a formula to the Brewfile, check that it has a bottle (see the Brewfile header).
- **Runtimes come from mise, not Homebrew.** That means no `brew node` or `openjdk@21/25`, so each project can pin its own versions and `JAVA_HOME` is never hardcoded. Rust comes from the official rustup in `~/.cargo`.
- **Vim is MacVim's terminal `vim`.** It has +python3, which vimspector needs; Apple's `/usr/bin/vim` doesn't. **git** is Apple's 2.39, which supports everything in `.gitconfig`.
- **pgcli** (a SQL client with autocomplete) is installed with `uv tool`. For `psql` and a local server, uncomment `postgres-app` in the Brewfile.
- **`cargo check` is `ck`, not `cc`.** `cc` would shadow the C compiler.
- **`grep` is not aliased to `rg`.** Their flags are incompatible; use `rg` directly. `cat` is `bat` in plain mode, and `\cat` gets the real one.
- **Zsh plugin order:** zsh-completions (fpath) → compinit → fzf-tab → autosuggestions → syntax-highlighting → history-substring-search. That last plugin's README asks to be loaded after syntax-highlighting.
- **There is no oh-my-zsh git plugin.** It depends on oh-my-zsh internals. Starship gives the branch-aware prompt, zsh gives native git completion, and the git aliases live in `shell/aliases.sh` and `~/.gitconfig`.
- **Atuin owns Ctrl-R in zsh**, and Up arrow stays with substring search. Set `DOTFILES_NO_ATUIN=1` to give Ctrl-R back to fzf. Bash uses fzf.
- **Terraform** comes from `hashicorp/tap` (a prebuilt binary), because Homebrew core dropped it after the licence change.
- **Dropped from the original plan** because they would have to be compiled on Sonoma: btop (use htop or Stats), coreutils, wget, watchman and cocoapods (React Native iOS: add them when you need them, or upgrade macOS).
- **Docker Desktop** was already installed on this Mac, so its cask is commented out in the Brewfile.
- **Neovim** is installed but not configured. Its configuration is meant to stay separate from Vim's.
