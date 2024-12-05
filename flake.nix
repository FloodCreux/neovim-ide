{
  description = "A Nix implementation of NeoVim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-schemas.url = "github:/gvolpe/flake-schemas";
    flake-utils.url = "github:/numtide/flake-utils";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tree-sitter-scala = {
      url = "github:tree-sitter/tree-sitter-scala";
      flake = false;
    };

    # LSP plugins
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };

    # Dependency of other plugins
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, flake-utils, ... }:
    {
      inherit (inputs.flake-schema) schemas;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        plugins =
          let
            f = xs: pkgs.lib.attrsets.filterAttrs (k: v: !builtins.elem k xs);

            nonPluginInputNames = [
              "self"
              "nixpkgs"
              "flake-utils"
              "neovim-nightly-flake"
              "nmd"
              "nixd"
              "tree-sitter-scala"
            ];
          in
          builtins.attrNames (f nonPluginInputNames inputs);

        lib = import ./lib { inherit pkgs inputs plugins; };

        inherit (lib) neovimBuilder;

        pluginOverlay = lib.buildPluginOverlay;

        libOverlay = f: p: {
          lib = p.lib.extend (
            _: _: {
              inherit (lib)
                mkVimBool
                withAttrSet
                withPlugins
                writeIf
                ;
            }
          );
        };

        tsOverlay = f: p: {
          tree-sitter-scala-master = p.tree-sitter.buildGrammar {
            language = "scala";
            version = inputs.tree-sitter-scala.rev;
            src = inputs.tree-sitter-scala;
          };
        };

        neovimOverlay = f: p: {
          neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
        };

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            libOverlay
            pluginOverlay
            neovimOverlay
            tsOverlay
          ];
        };

        default-ide = pkgs.callPackage ./lib/ide.nix { inherit pkgs neovimBuilder; };

        searchdocs = pkgs.callPackage ./docs/search { };

        docbook =
          with import ./docs {
            inherit pkgs;
            inherit (pkgs) lib;
          }; {
            inherit manPages jsonModuleMaintainers;
            inherit (manual) html;
            inherit (options) json;
          };
      in
      rec {
        apps = rec {
          nvim = {
            type = "app";
            program = "${packages.default}/bin/nvim";
          };

          default = nvim;
        };

        overlays.default = f: p: {
          inherit neovimBuilder;
          inherit (pkgs) neovim-nightly neovimPlugins;
        };

        homeManagerModules.default = {
          imports = [
            { nipkgs.overlays = [ overlays.default ]; }
          ];
        };

        packages = {
          default = default-ide.full.neovim;

          docs = docbook.html;
          docs-json = searchdocs.json;
          docs-search = searchdocs.html;

          inherit (pkgs.neovimPlugins) nvim-treesitter;

          ide = default-ide.full.neovim;
        };
      }
    );
}
