#!/usr/bin/env bash
# Sensible macOS defaults for development. Review before running — some keys
# change between macOS releases. Tested on macOS 14 (Sonoma).
#   ./macos/defaults.sh            (asks for confirmation)
#   ./macos/defaults.sh --yes      (no prompt)
set -euo pipefail

if [[ "${1:-}" != "--yes" ]]; then
  read -r -p "Apply macOS defaults (Finder, Dock, keyboard, screenshots)? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo "Skipped."; exit 0; }
fi

# Close System Settings so it doesn't overwrite what we change
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

echo "› Keyboard"
defaults write NSGlobalDomain KeyRepeat -int 2                 # fast repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15         # short delay
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false   # key repeat instead of accent popup (vim hjkl)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false  # no smart quotes in code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3       # Tab moves through all controls

echo "› Finder"
defaults write com.apple.finder AppleShowAllFiles -bool true   # show dotfiles
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "› Save / print dialogs"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

echo "› Dock & Mission Control"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock tilesize -int 42
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false           # don't reorder Spaces
defaults write com.apple.dock expose-group-apps -bool true     # helps window managers

echo "› Screenshots"
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string png
defaults write com.apple.screencapture disable-shadow -bool true

echo "› Misc"
defaults write com.apple.TextEdit RichText -int 0              # plain text by default
defaults write com.apple.ActivityMonitor ShowCategory -int 0   # all processes

killall Finder Dock SystemUIServer 2>/dev/null || true
echo "Done. Keyboard changes need a logout/login to take full effect."
