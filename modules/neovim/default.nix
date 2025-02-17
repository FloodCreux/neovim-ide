{ lib, pkgs, ... }:
with lib;
{
  options.vim.neovim.package = mkOption {
    type = types.package;
    default = pkgs.neovim-unwrapped;
    description = "The Neovim package to use. Default pkgs.neovim-unwrapped";
    example = "pkgs.neovim-nightly";
  };
}
