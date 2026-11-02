SHELL := /bin/bash
DOTFILES := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: help install link unlink brew brew-check toolchains plugins macos doctor update bench lint

help:  ## Show targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install:  ## Full install (brew, symlinks, toolchains, plugins, validation)
	@./install.sh

link:  ## Only (re)create symlinks (backs up conflicts)
	@./install.sh --link-only

unlink:  ## Remove all dotfiles symlinks from $HOME
	@bash -c 'source bootstrap/lib.sh; source bootstrap/link.sh; DOTFILES=$(DOTFILES) unlink_packages'

brew:  ## Install missing Homebrew packages
	@brew bundle install --no-upgrade --file=brew/Brewfile

brew-check:  ## List Brewfile packages that are missing
	@brew bundle check --verbose --file=brew/Brewfile || true

toolchains:  ## Rust (rustup) + mise runtimes
	@./install.sh --skip-brew --skip-plugins

plugins:  ## Update zsh, vim and tmux plugins
	@sheldon lock --update && rm -f $${XDG_CACHE_HOME:-$$HOME/.cache}/zsh/init-sheldon.zsh
	@vim -Es -u ~/.vimrc -i NONE -c 'PlugUpdate --sync' -c 'qa!' </dev/null >/dev/null 2>&1 || true
	@~/.tmux/plugins/tpm/bin/update_plugins all

macos:  ## Apply macOS defaults (asks first)
	@./macos/defaults.sh

doctor:  ## Validate the workstation
	@dotfiles-doctor

update:  ## Pull repo, upgrade brew + runtimes + plugins
	@git pull --rebase
	@brew update && brew bundle install --file=brew/Brewfile && brew upgrade
	@mise upgrade --yes || true
	@rustup update || true
	@$(MAKE) --no-print-directory plugins

bench:  ## Measure shell startup time
	@for s in zsh bash; do printf '%-5s' $$s; /usr/bin/time -p $$s -i -c exit 2>&1 >/dev/null | awk '/real/{print $$2"s"}'; done

lint:  ## shellcheck all scripts
	@shellcheck -x install.sh bootstrap/*.sh macos/*.sh scripts/.local/bin/* shell/.config/shell/*.sh bash/.bashrc
