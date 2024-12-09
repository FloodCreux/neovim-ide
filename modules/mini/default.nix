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

    completion = {
      enable = mkOption {
        type = types.bool;
        description = "enable mini completion";
      };
    };

    icons = {
      enable = mkOption {
        type = types.bool;
        description = "enable mini icons";
      };
    };

    indentScope = {
      enable = mkOption {
        type = types.bool;
        description = "enable mini indentscope";
      };
    };

    hipatterns = {
      enable = mkOption {
        type = types.bool;
        description = "enable mini hipatterns";
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

      ${writeIf cfg.completion.enable ''
        require("mini.completion").setup{}
      ''}

      ${writeIf cfg.icons.enable ''
        require("mini.icons").setup {}
      ''}

      ${writeIf cfg.indentScope.enable ''
        require("mini.indentscope").setup {
          symbol = '▏',
          options = { try_as_border = true },
        }
      ''}

      ${writeIf cfg.hipatterns.enable ''
        local hipatterns = require 'mini.hipatterns'
        hipatterns.setup {
          highlighters = {
            -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
            fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
            hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
            todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
            note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

            -- Highlight hex color strings (`#rrggbb`) using that color
            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        }
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
