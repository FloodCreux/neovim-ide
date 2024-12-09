{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.vim.harpoon;
  keys = config.vim.keys.whichKey;
  tele = config.vim.telescope;
in
{
  options.vim.harpoon = {
    enable = mkOption {
      type = types.bool;
      description = "Enable the Harpoon plugin";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ pkgs.neovimPlugins.harpoon ];

    vim.luaConfigRC = ''
      local harpoon = require 'harpoon'

      harpoon:setup()

      ${writeIf tele.enable ''
        local themes = require("telescope.themes")
        local hm_actions = require("telescope._extensions.harpoon_marks.actions")

        vim.keymap.set(
          "n",
          "<leader>hl",
          function()
            require("telescope").extensions.harpoon.marks(themes.get_dropdown({
              previewer = false,
              layout_config = { width = 0.6 },
              path_display = { truncate = 10 },
              attach_mappings = function(_, map)
                map("i", "<c-d>", h,_actions.delete_mark_selections)
                map("n", "<c-d>", h,_actions.delete_mark_selections)
                return true
              end,
            }))
          end,
          { desc = "List" }
        )
      ''}

      ${writeIf keys.enable ''
        wk.add({
          {"<leader>h", group = "Harpoon"},
          {"<leader>ha", "<cmd>lua require('harpoon'):list():add()<CR>", desc = "Add"},
          {"<leader>hd", "<cmd>lua require('harpoon'):list():remove()<CR>", desc = "Del"},
          {"<leader>ht", "<cmd>lua require('harpoon.ui'):toggle_quick_menu(harpoon:list())<CR>", desc = "Toggle Menu"},
          {"<leader>hh", "<cmd>lua require('harpoon'):list():select(1)<CR>", desc = "Go To 1"},
          {"<leader>hj", "<cmd>lua require('harpoon'):list():select(2)<CR>", desc = "Go To 2"},
          {"<leader>hk", "<cmd>lua require('harpoon'):list():select(3)<CR>", desc = "Go To 3"},
          {"<leader>hl", "<cmd>lua require('harpoon'):list():select(4)<CR>", desc = "Go To 4"},
          {"<leader>hn", "<cmd>lua require('harpoon'):list():prev()<CR>", desc = "Go To Prev"},
          {"<leader>hp", "<cmd>lua require('harpoon'):list():next()<CR>", desc = "Go To Next"},
        })
      ''}
    '';
  };
}
