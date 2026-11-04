{
  description = "Dev flake";

  inputs = {
    flakey-profile.url = "github:lf-/flakey-profile";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    # Pin a specific version like below. Find shas and versions from https://www.nixhub.io/
    # terragrunt.url = "github:nixos/nixpkgs/785feb91183a50959823ff9ba9ef673105259cd5";
  };

  outputs = { self, nixpkgs, flake-utils, flakey-profile, nix-ai-tools, ...}@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages.dev = flakey-profile.lib.mkProfile {
          inherit pkgs;
          paths = with pkgs; [
            # reference a pinned package like so
            # inputs.terragrunt.legacyPackages.${system}.terragrunt 
            gnupg
            fd
            terraform
            opentofu
            terragrunt
            terraform-docs
            ripgrep
            tldr
            starship
            neovim
            tailwindcss_4
            lua
            tree-sitter
            bat
            tree
            jq
            gh
            fzf
            direnv
            ffmpeg
            lazygit
            lazydocker
            kubectl
            typescript
            go
            gopls
            rustc
            rustup
            cargo-watch
            sqlite
            pack
            just
            python313
            ruff
            uv
            mypy
            gum
            drawio
            openvpn
            # SG stuff
            # claude-code
            kubernetes-helm
            k9s
            k3d
            # AI toolchain
            herdr
            # rtk # Can't compile on v0.43.0 try again soon
            worktrunk
          ];
        };
      });
}

