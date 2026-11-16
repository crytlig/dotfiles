# Dotfiles

The dotfiles are managed with stow for symlinking.

## Clone

This repo has submodules. Clone those as well.

```bash
git clone --recursive https://github.com/Crytlig/dotfiles
```

## Update

```bash
git submodule update --recursive --remote
```

## Packages

CLI tools and languages are managed by [mise](https://mise.jdx.dev) via
`.config/mise/config.toml` (stowed to `~/.config/mise/config.toml`).

The `brewfile` only holds macOS-specific things (sketchybar, dinky, GUI casks)
and the few tools mise can't provide, including mise itself.

```bash
just brew   # brew bundle (installs mise + stow first)
just stow   # symlink dotfiles
just mise   # install everything in the mise config
```
