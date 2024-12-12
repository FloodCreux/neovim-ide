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

  queriesHook = ''
    mkdir -p $out/queries/scala/
    cp ${inputs.tree-sitter-scala}/queries/* $out/queries/scala/
  '';

  telescopeFixupHook = ''
    substituteInPlace $out/scripts/vimg \
      --replace "chafa" "${pkgs.chafa}/bin/chafa"
    substituteInPlace $out/lua/telescope/_extensions/media_files.lua \
      --replace "M.base_directory .. '/scripts/vimg'" "'$out/scripts/vimg'"
  '';

  tsPreFixupHook = ''
    ${queriesHook}
  '';

  tsPostPatchHook = grammars: ''
    rm -r parser
    ln -s ${grammars} parser
  '';

  buildPlug =
    name: grammars:
    buildVimPlugin {
      pname = name;
      version = "master";
      src = builtins.getAttr name inputs;
      preFixup = ''
        ${writeIf (name == "nvim-treesitter") tsPreFixupHook}
        ${writeIf (name == "telescope-media-files") telescopeFixupHook}
      '';
      postPatch = ''
        ${writeIf (name == "nvim-treesitter") (tsPostPatchHook grammars)}
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
      p.tree-sitter-c
      p.tree-sitter-rust
      p.tree-sitter-markdown
      p.tree-sitter-markdown-inline
      p.tree-sitter-comment
      p.tree-sitter-json
      p.tree-sitter-toml
      p.tree-sitter-zig
      p.tree-sitter-vim
      # p.tree-sitter-vimdoc
      p.tree-sitter-hcl
      # p.tree-sitter-terraform
      p.tree-sitter-yaml
      p.tree-sitter-make
      p.tree-sitter-html
      p.tree-sitter-bash
      p.tree-sitter-ocaml
      p.tree-sitter-c-sharp
      p.tree-sitter-lua
      # p.tree-sitter-luadoc
      p.tree-sitter-nu
    ]);

  neovimPlugins =
    let
      tg = treesitterGrammars ts;
      xs = listToAttrs (map (n: nameValuePair n (buildPlug n tg)) plugins);
    in
    xs // vimPlugins;
}
