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

# Brew installation files for mac
brew:
    brew bundle --file=./brewfile
    brew services restart sketchybar
