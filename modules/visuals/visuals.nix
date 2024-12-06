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

    noice.enable = mkOption {
      type = types.bool;
      description = "enable the noice plugin";
    };

    nvimWebDevIcons.enable = mkOption {
      type = types.bool;
      description = "enable dev icons. required for certain plugins";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins =
      with pkgs.neovimPlugins;
      (
        (withPlugins cfg.noice.enable [
          noice
          nui-nvim
        ])
        ++ (withPlugins cfg.nvimWebDevIcons.enable [ nvim-web-devicons ])
      );

    vim.luaConfigRC = ''
      ${writeIf cfg.noice.enable ''
        ${writeIf keys.enable ''
          wk.register({
            ["<leader>n"] = {
              name = "Noice",
              d = { "<cmd> NoiceDismiss <CR>", "Dismiss notifications"},
            },
          })
        ''}

        require("noice").setup {
          lsp = {
            override = {
              ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
              ['vim.lsp.util.stylize_markdown'] = true,
              ['cmp.entry.get_documentation'] = true,
            },
          },
          routes = {
            {
              filter = {
                event = 'msg_show',
                any = {
                  { find = '%d+L, %d+B' },
                  { find = '; after #%d+' },
                  { find = '; before #%d+' },
                },
              },
              view = 'mini',
            },
          },
          presets = {
            bottom_search = true,
            command_palette = true,
            long_message_to_split = true,
            inc_rename = true,
          },
        }
      ''}
    '';
  };
}
