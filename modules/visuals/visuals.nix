{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
with builtins;

let
  cfg = config.vim.visuals;
  keys = config.vim.keys.whichKey;
in
{
  options.vim.visuals = {
    enable = mkOption {
      type = types.bool;
      description = "visual enhancements";
    };

    miniIcons.enable = mkOption {
      type = types.bool;
      description = "enable the mini icons plugin";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; ((withPlugins cfg.miniIcons.enable [ mini-icons ]));

    vim.luaConfigRC = ''
      ${writeIf cfg.miniIcons.enable ''
        require("mini.icons").setup {}
      ''}
    '';
  };
}
