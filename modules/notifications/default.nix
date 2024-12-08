{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.vim.notifications;
in
{
  options.vim.notifications = {
    enable = mkOption {
      type = types.bool;
      description = "Enable the snacks plugin";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [ snacks ];

    vim.luaConfigRC = ''
      require("snacks").setup {
        notifier = {
          enabled = true,
          timeout = 3000,
        },
      };
    '';
  };
}
