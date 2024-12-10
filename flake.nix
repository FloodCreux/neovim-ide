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

    nixd.url = "github:nix-community/nixd";

    rust-tools = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };

    crates-nvim = {
      url = "github:Saecki/crates.nvim";
      flake = false;
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

    omnisharp = {
      url = "github:OmniSharp/Omnisharp-vim";
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

    # Harpoon
    harpoon = {
      url = "github:theprimeagen/harpoon?ref=harpoon2";
      flake = false;
    };

    # mini
    mini = {
      url = "github:echasnovski/mini.nvim";
      flake = false;
    };

    # Git
    vim-fugitive = {
      url = "github:tpope/vim-fugitive";
      flake = false;
    };

    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    diffview = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };

    lazygit = {
      url = "github:kdheepak/lazygit.nvim";
      flake = false;
    };

    # File Trees
    yazi = {
      url = "github:DreamMaoMao/yazi.nvim";
      flake = false;
    };

    oil = {
      url = "github:stevearc/oil.nvim";
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

    # Visuals
    noice = {
      url = "github:folke/noice.nvim";
      flake = false;
    };

    # noice dep
    nui-nvim = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };

    # Notifications
    snacks = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };

    # Keybinding
    which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };

    # Autocompletes
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-vsnip = {
      url = "github:hrsh7th/cmp-vsnip";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };

    # Autopairs
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };

    # Snippets
    vim-vsnip = {
      url = "github:hrsh7th/vim-vsnip";
      flake = false;
    };

    # Markdown
    render-markdown-nvim = {
      url = "github:MeanderingProgrammer/render-markdown.nvim";
      flake = false;
    };

    # Dependency of other plugins
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      ...
    }:
    {
      inherit (inputs.flake-schema) schemas;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
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
            # nmdOverlay
            nixdOverlay
            tsOverlay
          ];
        };

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

        nixdOverlay = f: p: {
          inherit (inputs.nixd.packages.${system}) nixd;
        };

        default-ide = pkgs.callPackage ./lib/ide.nix {
          inherit pkgs neovimBuilder;
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
          inherit metalsBuilder neovimBuilder;
          inherit (pkgs) neovim-nightly neovimPlugins;
          lib = p.lib;
        };

        homeManagerModules.nvim = {
          imports = [
            ./lib/hm.nix
            { nixpkgs.overlays = [ overlays.default ]; }
          ];
        };

        packages = {
          default = default-ide.full-nightly.neovim;

          ts-scala = pkgs.tree-sitter-scala-master;
          inherit (pkgs) metals;
          inherit (pkgs.neovimPlugins) nvim-treesitter;

          ide = default-ide.full.neovim;
          nightly = default-ide.full-nightly.neovim;
        };
      }
    );
}
