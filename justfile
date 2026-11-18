# List justfile targets
default:
  just -l

# Sync stow
stow:
    stow --verbose --target=$HOME --restow .

# Install tools from mise config
mise:
    mise install

# Upgrade mise tools to latest
mise-upgrade:
    mise upgrade

# macOS defaults
# mru-spaces: MRU Space reordering breaks dinky's workspace numbering
macos:
    defaults write com.apple.dock mru-spaces -bool false
    killall Dock

# Brew installation files for mac
brew:
    brew bundle --file=./brewfile
    brew services restart sketchybar
