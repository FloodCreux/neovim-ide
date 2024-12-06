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

    vim.nnoremap = {
      "<leader>xx" = "<cmd>Trouble diagnostics toggle<cr>";
      "<leader>xX" = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      "<leader>cs" = "<cmd>Trouble symbols toggle focus=false<cr>";
      "<leader>cl" = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>";
      "<leader>xL" = "<cmd>Trouble loclist toggle<cr>";
      "<leader>xQ" = "<cmd>Trouble qflist toggle<cr>";
    };

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
             "<leader>cs",
             "<cmd>Trouble symbols toggle focus=false<cr>",
             desc = "Symbols (Trouble)",
           },
           {
             "<leader>cl",
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
    '';
  };
}
