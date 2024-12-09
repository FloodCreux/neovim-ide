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
  options.vim.lsp.trouble.enable = mkEnableOption "trouble diagnostics viewer";

  config = mkIf (cfg.enable && cfg.trouble.enable) {
    vim.startPlugins = with pkgs.neovimPlugins; [ trouble ];

    vim.luaConfigRC = ''
      -- Enable trouble diagnostics viewer
      require("trouble").setup {
       ${writeIf keys.enable ''
          keys = {
           {
             "<leader>xx",
             "<cmd>Trouble diagnostics toggle<cr>",
             desc = "Diagnostics (Trouble)",
           },
           {
             "<leader>xX",
             "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
             desc = "Buffer Diagnostics (Trouble)",
           },
           {
             "<leader>xs",
             "<cmd>Trouble symbols toggle focus=false<cr>",
             desc = "Symbols (Trouble)",
           },
           {
             "<leader>xl",
             "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
             desc = "LSP Definitions / references / ... (Trouble)",
           },
           {
             "<leader>xL",
             "<cmd>Trouble loclist toggle<cr>",
             desc = "Location List (Trouble)",
           },
           {
             "<leader>xQ",
             "<cmd>Trouble qflist toggle<cr>",
             desc = "Quickfix List (Trouble)",
           },
         },
       ''} 
      }

      ${writeIf keys.enable ''
        wk.add({
          {"<leader>x", group = "Trouble"},
        })
      ''}
    '';
  };
}
