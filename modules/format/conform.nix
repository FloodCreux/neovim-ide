{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
with builtins;
let
  cfg = config.vim.format.conform;
in
{
  options.vim.format.conform = {
    enable = mkOption {
      type = types.bool;
      description = "enable conform [conform.nvim]";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [ conform ];

    vim.luaConfigRC = ''
      -- Conform config
      local slow_format_filetypes = { 'scala' }
      require 'conform'.setup {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          return {
            timeout_ms = 500,
            lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
          }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          -- Conform can also run multiple formatters sequentially
          -- python = { "isort", "black" },
          javascript = { { 'prettier' } },
          cs = { 'csharpier' },
          xml = { 'xmllint' },
          -- sql = { 'sqlfmt' },
          markdown = { 'prettier' },
          nix = { 'nixfmt' },
        },
        format_after_save = function(bufnr)
          if not slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
          end
          return { lsp_fallback = true }
        end,
        formatters = {
          csharpier = {
            command = 'dotnet-csharpier',
            args = { '--write-stdout' },
          },
        },
      }
    '';
  };
}
