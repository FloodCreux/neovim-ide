{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;

let
  cfg = config.vim.lsp;
  keys = config.vim.keys.whichKey;
in
{
  options.vim.lsp = {
    enable = mkEnableOption "neovim lsp support";
    folds = mkEnableOption "Folds via nvim-ufo";
    formatOnSave = mkEnableOption "Format on save";

    ts = mkEnableOption "TS language LSP";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [ nvim-lspconfig ];
  };
}
