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
        local tele_conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            require("telescope.pickers").new({}, {
                prompt_title = "Harpoon",
                finder = require("telescope.finders").new_table({
                    results = file_paths,
                }),
                previewer = tele_conf.file_previewer({}),
                sorter = tele_conf.generic_sorter({}),
            }):find()
        end

        vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
            { desc = "Open harpoon window" })
      ''}

      ${writeIf keys.enable ''
        wk.add({
          {"<leader>h", group = "Harpoon"},
          {"<leader>ha", "<cmd> lua require('harpoon'):list():add()<CR>", desc = "Add"},
          {"<leader>hd", "<cmd> lua require('harpoon'):list():remove()<CR>", desc = "Del"},
          {"<leader>ht", "<cmd> lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())<CR>", desc = "Toggle Menu"},
          {"<leader>hh", "<cmd> lua require('harpoon'):list():select(1)<CR>", desc = "Go To 1"},
          {"<leader>hj", "<cmd> lua require('harpoon'):list():select(2)<CR>", desc = "Go To 2"},
          {"<leader>hk", "<cmd> lua require('harpoon'):list():select(3)<CR>", desc = "Go To 3"},
          {"<leader>hl", "<cmd> lua require('harpoon'):list():select(4)<CR>", desc = "Go To 4"},
          {"<leader>hn", "<cmd> lua require('harpoon'):list():prev()<CR>", desc = "Go To Prev"},
          {"<leader>hp", "<cmd> lua require('harpoon'):list():next()<CR>", desc = "Go To Next"},
        })
      ''}
    '';
  };
}
