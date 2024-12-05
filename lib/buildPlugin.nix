{
  pkgs,
  inputs,
  plugins,
  lib ? pkgs.lib,
  ...
}:
final: prev:
with lib;
with builtins;

let
  inherit (prev.vimUtils) buildVimPlugin;

  ts = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-scala = final.tree-sitter-scala-master;
    };
  };

  buildPlug =
    name: grammars:
    buildVimPlugin {
      pname = name;
      version = "master";
      src = builtins.getAttr name inputs;
    };

  vimPlugins = {
    inherit (pkgs.vimPlugins) nerdcommenter;
  };
in
rec {
  treesitterGrammars =
    t:
    t.withPlugins (p: [
      p.tree-sitter-scala
      p.tree-sitter-nix
    ]);

  neovimPlugins =
    let
      tg = treesitterGrammars ts;
      xs = listToAttrs (map (n: nameValuePair n (buildPlug n tg)) plugins);
    in
    xs // vimPlugins;
}
