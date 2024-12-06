{ lib, ... }:

with lib;

{
  config = {
    vim.visuals = {
      enable = mkDefault false;

      noice.enable = mkDefault true;
      nvimWebDevIcons.enable = mkDefault false;
    };
  };
}
