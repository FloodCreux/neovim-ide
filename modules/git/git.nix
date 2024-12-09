{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
with builtins;

let
  cfg = config.vim.git;
in
{
  options.vim.git = {
    enable = mkOption {
      type = types.bool;
      description = "Enable git plugins";
    };

    gitsigns.enable = mkOption {
      type = types.bool;
      description = "Enable gitsigns";
    };

    lazygit.enable = mkOption {
      type = types.bool;
      description = "Enables LazyGit";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins =
      with pkgs.neovimPlugins;
      [
        diffview
        vim-fugitive
      ]
      ++ (withPlugins cfg.gitsigns.enable [ gitsigns-nvim ])
      ++ (withPlugins cfg.lazygit.enable [ lazygit ]);

    vim.nnoremap = {
      "<leader>gwc" = ":Git commit -m '";
      "<leader>gwp" = "<cmd> Git push <CR>";
      "<leader>gs" = "<cmd> Gvdiffsplit origin/HEAD <CR>";
      "<leader>gg" = "<cmd> LazyGit <CR>";
    };

    vim.luaConfigRC = ''
      wk.add({
        {"<leader>g", group = "Git"},
      })

      ${writeIf cfg.lazygit.enable ''
        require('telescope').load_extension 'lazygit'
      ''}
    '';
  };
}
