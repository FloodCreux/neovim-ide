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
      type = with types; listOf packages;
    };
  };
}
