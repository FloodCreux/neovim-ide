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
  options.vim.lsp.codeActions.enable = mkEnableOption "nvim code actions menu";

  config = mkIf (cfg.enable && cfg.codeActions.enable) {
    vim.startPlugins = with pkgs.neovimPlugins; [ actions-preview ];

    vim.luaConfigRC = ''
      local actions = require 'actions-preview'

      actions.setup {
        backend = { "telescope", "nui" },
        telescope = vim.tbl_extend(
          "force",
          require("telescope.themes").get_dropdown(),
          {
            make_value = nil,
            make_make_display = nil,
          }
        ),
        nui = {
          dir = "col",
          keymap = nil,
          layout = {
            position = "50%",
            size = {
              width = "60%",
              height = "90%",
            },
            min_width = 40,
            min_height = 10,
            relative = "editor",
          },
          -- options for preview area: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup
          preview = {
            size = "60%",
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
          },
          -- options for selection area: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/menu
          select = {
            size = "40%",
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
          },
        },
      }

      vim.keymap.set({ "v", "n" }, "<leader>ac", require("actions-preview").code_actions)

      ${writeIf keys.enable ''
        wk.add({
          {"<leader>a", group = "Code Actions"}
        })
      ''}
    '';
  };
}
