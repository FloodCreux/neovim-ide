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

  telescopeFixupHook = ''
    substituteInPlace $out/scripts/vimg \
      --replace "ueberzug layer" "${pkgs.ueberzug}/bin/ueberzug layer"
    substituteInPlace $out/lua/telescope/_extensions/media_files.lua \
      --replace "M.base_directory .. '/scripts/vimg'" "'$out/scripts/vimg'"
  '';

  buildPlug =
    name: grammars:
    buildVimPlugin {
      pname = name;
      version = "master";
      src = builtins.getAttr name inputs;
      preFixup = ''
        ${writeIf (name == "telescope-media-files") telescopeFixupHook}
      '';
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
