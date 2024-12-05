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

        scala = {
          enable = true;
          metals = {
            package = pkgs.metals;
            # best effort compilation + vs code default settings
            # see https://github.com/scalameta/metals-vscode/blob/1e10e1a71cf81569ea65329ec2aa0aa1cb6ad682/packages/metals-vscode/package.json#L232
            serverProperties = [
              "-Dmetals.enable-best-effort=true"
              "-Xmx2G"
              "-XX:+UseZGC"
              "-XX:ZUncommitDelay=30"
              "-XX:ZCollectionInterval=5"
              "-XX:+IgnoreUnrecognizedVMOptions"
            ];
          };
        };
      };
      treesitter = {
        enable = true;
        autotagHtml = true;
        context.enable = true;
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
