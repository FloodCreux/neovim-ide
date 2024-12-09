{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.vim.notifications;
  neovim = config.vim.neovim.package;
  keys = config.vim.keys.whichKey;
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
        bigfile = { enabled = false },
        dashboard = {
          enabled = true,
          width = 60,
          preset = {
            keys = {
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
              { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              { icon = " ", key = "q", desc = "Exit", action = ":qa" },
            },
          },
          sections = {
            { section = "header" },
            { text = "Version: ${neovim.version}", align = "center", padding = 1 },
            { section = "keys", gap = 1, padding = 1 },
          },
        },
        notifier = {
          enabled = true,
          timeout = 3000,
        },
        quickfile = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
      };

      ${writeIf keys.enable ''
        wk.add({
          {"<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer"},
          {"<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History"},
          {"<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit"},
          {"<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)"},
          {"<leader>z", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications"},
        })
      ''}
    '';
  };
}
