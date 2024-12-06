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

    nvim-metals = {
      url = "github:scalameta/nvim-metals";
      flake = false;
    };

    # LSP plugins
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };

    trouble = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };

    # Treesitter
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };

    tree-sitter-scala = {
      url = "github:tree-sitter/tree-sitter-scala";
      flake = false;
    };

    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };

    nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };

    nvim-ts-autotag = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };

    # Telescope
    telescope = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };

    telescope-media-files = {
      url = "github:gvolpe/telescope-media-files.nvim";
      flake = false;
    };

    telescope-tabs = {
      url = "github:FabianWirth/search.nvim";
      flake = false;
    };

    # Formatters
    conform = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };

    # UI
    nvim-web-devicons = {
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };

    # mini
    mini = {
      url = "github:echasnovski/mini.nvim";
      flake = false;
    };

    # Themes
    catppuccin = {
      url = "github:catppuccin/nvim";
      flake = false;
    };

    nightfox = {
      url = "github:EdenEast/nightfox.nvim";
      flake = false;
    };

    onedark = {
      url = "github:navarasu/onedark.nvim";
      flake = false;
    };

    rosepine = {
      url = "github:rose-pine/neovim";
      flake = false;
    };

    tokyonight = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };

    gruber-darker = {
      url = "github:blazkowolf/gruber-darker.nvim";
      flake = false;
    };

    noice = {
      url = "github:folke/noice.nvim";
      flake = false;
    };

    # noice dep
    nui-nvim = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };

    # Keybinding
    which-key = {
      url = "github:folke/which-key.nvim";
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

        inherit (lib) metalsBuilder metalsOverlay neovimBuilder;

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
            metalsOverlay
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

        overlays = {
          default = f: p: {
            inherit metalsBuilder neovimBuilder;
            inherit (pkgs) neovim-nightly neovimPlugins;
          };
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

          ts-scala = pkgs.tree-sitter-scala-master;
          inherit (pkgs) metals;
          inherit (pkgs.neovimPlugins) nvim-treesitter;

          ide = default-ide.full.neovim;
          nightly = default-ide.full-nightly.neovim;
        };
      }
    );
}
