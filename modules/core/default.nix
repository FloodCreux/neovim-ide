{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins;

let
  cfg = config.vim;

  mkMappingOption =
    it:
    mkOption (
      {
        default = { };
        type = with types; attrsOf (nullOr str);
      }
      // it
    );
in
{
  options.vim = {
    viAlias = mkOption {
      description = "Enable vi alias";
      type = types.bool;
      default = true;
    };

    vimAlias = mkOption {
      description = "Enable vi alias";
      type = types.bool;
      default = true;
    };

    startConfigRC = mkOption {
      description = "start of vimrc contents";
      type = types.lines;
      default = "";
    };

    finalConfigRC = mkOption {
      description = "built vimrc contents";
      type = types.lines;
      default = "";
    };

    finalKeybindings = mkOption {
      description = "built Keybindings in vimrc contents";
      type = types.lines;
      internal = true;
      default = "";
    };

    configRC = mkOption {
      description = "vimrc contents";
      type = types.lines;
      default = "";
    };

    startLuaConfigRC = mkOption {
      description = "start of vim lua config";
      type = types.lines;
      default = "";
    };

    luaConfigRC = mkOption {
      description = "vim lua config";
      type = types.lines;
      default = "";
    };

    startPlugins = mkOption {
      description = "List of plugins to startup";
      default = [ ];
      type = with types; listOf package;
    };

    optPlugins = mkOption {
      description = "List of plugins to optionally load";
      default = [ ];
      type = with types; listOf package;
    };

    runtime = mkOption {
      default = { };
      example = literalExpression ''
        { "ftplugin/c.vim".text = "setlocal omnifunc=v:lua.vim.lsp.omnifunc"; }
      '';
      description = ''
        Set of files that have to be linked in {file}`runtime`.
      '';

      type =
        with types;
        attrsOf (
          submodule (
            { name, config, ... }:
            {
              options = {

                enable = mkOption {
                  type = types.bool;
                  default = true;
                  description = ''
                    Whether this /etc file should be generated.  This
                    option allows specific /etc files to be disabled.
                  '';
                };

                target = mkOption {
                  type = types.str;
                  description = ''
                    Name of symlink.  Defaults to the attribute
                    name.
                  '';
                };

                text = mkOption {
                  default = null;
                  type = types.nullOr types.lines;
                  description = "Text of the file.";
                };

                source = mkOption {
                  type = types.path;
                  description = "Path of the source file.";
                };

              };

              config = {
                target = mkDefault name;
                source = mkIf (config.text != null) (
                  let
                    name' = "neovim-runtime" + baseNameOf name;
                  in
                  mkDefault (pkgs.writeText name' config.text)
                );
              };
            }
          )
        );
    };
  };
}
