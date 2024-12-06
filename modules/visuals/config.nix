{ lib, ... }:

with lib;

{
  config = {
    vim.visuals = {
      enable = mkDefault false;

      miniIcons.enable = mkDefault false;
    };
  };
}
