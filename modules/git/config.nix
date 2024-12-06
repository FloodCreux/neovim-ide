{ lib, ... }:

with lib;

{
  config.vim.git = {
    enable = mkDefault false;
    gitsigns.enable = mkDefault false;
    lazygit.enable = mkDefault false;
  };
}
