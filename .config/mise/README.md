# mise

Global tool config, stowed to `~/.config/mise/config.toml`.
`.zshrc` runs `mise activate zsh`, so tools are put on PATH directly (shims are only
used by things that don't load the shell config).

## Sample commands

```bash
mise install            # install everything in config.toml (just mise)
mise outdated           # show tools with newer versions than the pinned ones
mise upgrade --bump     # upgrade and rewrite the pins in config.toml (or edit the version by hand)
mise ls                 # list installed tools and where they're configured
mise use -g <tool>      # add a tool to the global config and install it
mise doctor             # diagnose activation / PATH problems
```

## Removing a tool

Deleting a line from `config.toml` only stops mise from activating the tool;
the install and shim stay behind.

```bash
mise uninstall --all <tool>   # e.g. github:herdrdev/herdr
mise reshim                   # rebuild shims, dropping ones for removed tools
mise lock --global            # drop the tool from mise.lock
hash -r                       # forget the old path in the current shell
```

## Cleanup

```bash
mise prune --dry-run    # preview unused versions (skips versions used by running processes)
mise prune              # remove versions no config refers to
mise reshim             # rebuild ~/.local/share/mise/shims
mise cache clear        # clear download / version-list cache
```

## Gotchas

- Every tool is pinned to an exact version (no `latest`), so nothing changes until a
  pin is bumped on purpose.

- `python = 'latest'` can move ahead of what pypi tools support. Pin a single tool's
  interpreter with `uvx_args`, e.g.
  `azure-cli = { version = "2.92.0", uvx_args = "--python 3.14" }`.
