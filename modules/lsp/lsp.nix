{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;

let
  cfg = config.vim.lsp;
  keys = config.vim.keys.whichKey;

  metalsServerProperties =
    let
      str = builtins.toJSON cfg.scala.metals.serverProperties;
    in
    lib.strings.removePrefix "[" (lib.strings.removeSuffix "]" str);
in
{
  options.vim.lsp = {
    enable = mkEnableOption "neovim lsp support";
    folds = mkEnableOption "Folds via nvim-ufo";
    formatOnSave = mkEnableOption "Format on save";

    scala = {
      enable = mkEnableOption "Scala LSP (Metals)";
      metals = {
        package = mkOption {
          type = types.package;
          default = pkgs.metals;
          description = "The Metals package to use. Default pkgs.metals";
        };

        serverProperties = mkOption {
          type = types.listOf types.str;
          default = [
            "-Xmx2G"
            "-XX:+UseZGC"
            "-XX:ZUncommitDelay=30"
            "-XX:ZCollectionInterval=5"
            "-XX:+IgnoreUnrecognizedVMOptions"
          ];
          description = "The Metals server properties";
          example = [
            "-Dmetals.enable-best-effort=true"
            "-XX:+UseStringDeduplication"
            "-XX:+IgnoreUnrecognizedVMOptions"
          ];
        };
      };
    };

    ts = mkEnableOption "TS language LSP";
  };

  config = mkIf cfg.enable {
    vim.startPlugins =
      with pkgs.neovimPlugins;
      [ nvim-lspconfig ] ++ (withPlugins cfg.scala.enable [ nvim-metals ]);

    vim.configRC = '''';

    vim.luaConfigRC = ''
      local attach_keymaps = function(client, bufnr)
        ${writeIf cfg.scala.enable ''
          -- Metals specific
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lmc', '<cmd>lua require("metals").commands()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lmi', '<cmd>lua require("metals").toggle_setting("showImplicitArguments")<CR>', opts)
        ''}
      end

      vim.g.formatsave = ${if cfg.formatOnSave then "true" else "false"};

      ${writeIf cfg.scala.enable ''
        -- Scala nvim-metals config
        metals_config = require('metals').bare_config()
        metals_config.capabilities = capabilities
        metals_config.on_attach = default_on_attach

        metals_config.settings = {
           metalsBinaryPath = "${cfg.scala.metals.package}/bin/metals",
           autoImportBuild = "off",
           defaultBspToBuildTool = true,
           showImplicitArguments = true,
           showImplicitConversionsAndClasses = true,
           showInferredType = true,
           superMethodLensesEnabled = true,
           excludedPackages = {
             "akka.actor.typed.javadsl",
             "com.github.swagger.akka.javadsl"
           },
           serverProperties = {
             ${metalsServerProperties}
           }
        }

        metals_config.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
          vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = {
              prefix = '',
            }
          }
        )

        -- without doing this, autocommands that deal with filetypes prohibit messages from being shown
        vim.opt_global.shortmess:remove("F")

        vim.cmd([[augroup lsp]])
        vim.cmd([[autocmd!]])
        vim.cmd([[autocmd FileType java,scala,sbt lua require('metals').initialize_or_attach(metals_config)]])
        vim.cmd([[augroup end]])
      ''}  
    '';
  };
}
