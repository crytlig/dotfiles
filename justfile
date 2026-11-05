# List justfile targets
default:
  just -l

# Sync stow
stow:
    stow --verbose --target=$HOME --restow .

# Nix switch
nix:
    nix run ~/dotfiles/#dev.switch

# Brew installation files for mac
brew:
    brew bundle --file=./Brewfile
    brew services restart sketchybar

# Nix Garbage collect
garbage:
    nix-store --gc

# Update flake.lock
flake-update:
    nix flake update
