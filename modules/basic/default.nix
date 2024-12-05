{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins;

let
  cfg = config.vim;
in
{
  options.vim = {
    colorTerm = mkOption {
      type = types.bool;
      description = "Set terminal up for 256 colors";
    };

    cmdHeight = mkOption {
      type = types.int;
      description = "Height of the command pane";
    };

    customPlugins = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "List of custom plugins";
    };

    preventJunkFiles = mkOption {
      type = types.bool;
      description = "Prevent swapfile, backupfile from being created";
    };
  };

  config = {
    vim.cmdHeight = mkDefault 1;

    vim.startPlugins = [ pkgs.neovimPlugins.plenary-nvim ] ++ cfg.customPlugins;
  };
}
