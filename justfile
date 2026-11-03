# List justfile targets
default:
  just -l

# Sync stow
sync-stow:
    stow --verbose --target=$HOME --restow .

# Nix switch
switch:
    nix run ~/dotfiles/#dev.switch

# Brew installation files for mac
brew:
    brew bundle --file=./Brewfile
    brew services restart sketchybar

# Nix Garbage collect
garbage:
    nix-store --gc
