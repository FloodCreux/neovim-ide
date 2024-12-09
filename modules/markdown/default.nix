{
  pkgs,
  config,
  lib,
  ...
}:

with lib;
with builtins;

let
  cfg = config.vim.markdown;
in
{
  options.vim.markdown = {
    enable = mkEnableOption "markdown tools and plugins";

    render.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable render-markdown.nvim plugin";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = withPlugins cfg.render.enable [ pkgs.neovimPlugins.render-markdown-nvim ];

    vim.luaConfigRC = writeIf cfg.render.enable ''
      require("render-markdown").setup{};
    '';

    vim.configRC = writeIf cfg.render.enable ''
      autocmd FileType markdown noremal <leader>rt <cmd>RenderMarkdown toggle<cr>
    '';
  };
}
