{
  pkgs,
  lib,
  neovimBuilder,
  ...
}:
let
  deepMerge = lib.attrsets.recursiveUpdate;

  cfg = {
    vim = {
      viAlias = false;
      vimAlias = true;
      preventJunkFiles = true;
      cmdHeight = 2;
      customPlugins = with pkgs.vimPlugins; [
        multiple-cursors
        vim-repeat
      ];
      lsp = {
        enable = true;
        folds = true;
        formatOnSave = false;
      };
    };
  };

  langs = {
    vim.lsp = {
      ts = true;
    };
  };

  nightly = {
    vim.neovim.package = pkgs.neovim-nightly;
  };
in
{
  full = neovimBuilder {
    config = deepMerge cfg langs;
  };

  full-nightly = neovimBuilder {
    config = deepMerge (deepMerge cfg langs) nightly;
  };
}
