{
  config,
  pkgs,
  lib ? pkgs.lib,
  ...
}:

let
  cfg = config.programs.neovim-ide;
  set = pkgs.neovimBuilder { config = cfg.settings; };
in
with lib;
{
  options.programs.neovim-ide = {
    enable = mkEnableOption "Neovim with LSP enabled fo Scala, Rust, and more.";

    settings = mkOption { };

    finalPackage = mkOption { };

    config = mkIf cfg.enable {
      home.packages = [ set.neovim ];
      programs.neovim-ide.finalPackage = set.neovim;
    };
  };
}
