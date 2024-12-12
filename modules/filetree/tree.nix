{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
with builtins;

let
  cfg = config.vim.filetree;
in
{
  options.vim.filetree = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable filetree";
    };

    yazi = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable yazi";
      };
    };

    oil = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable oil";
      };
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins =
      with pkgs.neovimPlugins;
      [ ] ++ (withPlugins cfg.yazi.enable [ yazi ]) ++ (withPlugins cfg.oil.enable [ oil ]);

    vim.luaConfigRC = ''
      wk.add({
        {"<leader>p", group = "Explore"},
      })

      ${writeIf cfg.yazi.enable ''
        vim.keymap.set('n', '<leader>pv', function() require('yazi').yazi() end, { desc = 'Open parent directory' })
      ''}

      ${writeIf cfg.oil.enable ''
        require('oil').setup {
          columns = { 'icon' },
          keymaps = {
            ['<C-h>'] = false,
            ['<M-h>'] = 'actions.select_split',
          },
          view_options = {
            show_hidden = true,
          },
          skip_confirm_for_simple_edits = true,
          float = {
            padding = 10,
          },
        }

        vim.keymap.set('n', '<leader>pv', require('oil').toggle_float, { desc = 'Open parent directory' })
      ''}
    '';
  };
}
