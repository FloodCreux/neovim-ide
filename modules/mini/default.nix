{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.vim.mini;
in
{
  options.vim.mini = {
    enable = mkOption {
      type = types.bool;
      description = "enable mini packages";
    };

    ai = {
      enable = mkOption {
        type = types.bool;
        description = "enable mini ai";
      };
    };

    icons = {
      enable = mkOption {
        type = types.bool;
        description = "enable mini icons";
      };
    };

    statusLine = {
      enable = mkOption {
        type = types.bool;
        description = "enable mini status line";
      };
    };

    surround = {
      enable = mkOption {
        type = types.bool;
        description = "enable mini surrround";
      };
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [ mini ];

    vim.luaConfigRC = ''
      ${writeIf cfg.ai.enable ''
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [']quote
        --  - ci'  - [C]hange [I]nside [']quote
        require('mini.ai').setup { n_lines = 500 }
      ''}

      ${writeIf cfg.icons.enable ''
        require("mini.icons").setup {}
      ''}

      ${writeIf cfg.statusLine.enable ''
        -- Simple and easy statusline.
        --  You could remove this setup call if you don't like it,
        --  and try some other statusline plugin
        local statusline = require 'mini.statusline'
        -- set use_icons to true if you have a Nerd Font
        statusline.setup { use_icons = vim.g.have_nerd_font }

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
          return '%2l:%-2v'
        end
      ''}

      ${writeIf cfg.surround.enable ''
        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup()
      ''}
    '';
  };
}
