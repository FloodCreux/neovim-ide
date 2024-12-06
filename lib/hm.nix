# Home Manager module
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
  meta.maintainers = [ maintainers.FloodCreux ];

  options.programs.neovim-ide = {
    enable = mkEnableOption "NeoVim with LSP enabled for Scala, Haskell, Rust and more.";

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      example = literalExpression ''
        {
          vim.viAlias = false;
          vim.vimAlias = true;
          vim.lsp = {
            enable = true;
            formatOnSave = true;
            lightbulb.enable = true;
            lspsaga.enable = false;
            nvimCodeActionMenu.enable = true;
            trouble.enable = true;
            lspSignature.enable = true;
            rust.enable = false;
            nix = true;
            dhall = true;
            elm = true;
            haskell = true;
            scala = true;
            sql = true;
            python = false;
            clang = false;
            ts = false;
            go = false;
          };
        }
      '';
      description = "Attribute set of neovim-ide preferences.";
    };

    finalPackage = mkOption {
      type = types.package;
      visible = false;
      readOnly = true;
      description = "The NeoVim package including as configured by the HM module";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ set.neovim ];
    programs.neovim-ide.finalPackage = set.neovim;
  };
}
