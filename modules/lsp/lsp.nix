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
  dap = config.vim.dap;

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

    clang = mkEnableOption "C language LSP";

    csharp = {
      enable = mkEnableOption "C# language LSP";
      description = "Enable the C# LSP";

      type = mkOption {
        type = types.enum [
          "omnisharp"
          "csharp_ls"
        ];
        default = "omnisharp";
        description = "Whether to use `omnisharp` or `csharp_ls`";
      };

      omnisharpSettings = mkOption {
        type = types.str;
        default = ''
          {
            FormattingOptions = {
              EnableEditorConfigSupport = true,
              OrganizeImports = true,
            },
            MsBuild = {
              LoadProjectsOnDemand = nil,
            },
            RoslynExtensionsOptions = {
              EnableAnalyzersSupport = true,
              EnableImportCompletion = true,
              AnalyzeOpenDocumentsOnly = true,
            },
            Sdk = {
              IncludePrereleases = true,
            },
          }
        '';
        description = "options to pass to omnisharp";
      };
    };

    go = mkEnableOption "Go language LSP";

    haskell = mkEnableOption "Haskell LSP";

    nix = {
      enable = mkEnableOption "Nix LSP";
      type = mkOption {
        type = types.enum [
          "nixd"
          "nil"
          "rnix-lsp"
        ];
        default = "nil";
        description = "Whether to use `nixd`, `nil`, or `rnix-lsp`";
      };
    };

    rust = {
      enable = mkEnableOption "Rust LSP";
      default = false;
      description = "Enable the Rust LSP";
      rustAnalyzerOpts = mkOption {
        type = types.str;
        default = ''
          ["rust-analyzer"] = {
            experimental = {
              procAttrMacros = true,
            },
          },
        '';
        description = "options to pass to rust analyzer";
      };
    };

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

    terraform = {
      enable = mkEnableOption "Terraform LSP";
    };

    ts = mkEnableOption "TS language LSP";
  };

  config = mkIf cfg.enable {
    vim.startPlugins =
      with pkgs.neovimPlugins;
      [ nvim-lspconfig ]
      ++ (withPlugins cfg.rust.enable [
        crates-nvim
        rust-tools
      ])
      ++ (withPlugins cfg.csharp.enable (if cfg.csharp.type == "omnisharp" then [ omnisharp ] else [ ]))
      ++ (withPlugins cfg.scala.enable [ nvim-metals ]);

    vim.configRC = ''
      ${writeIf cfg.clang ''
        " c syntax for header(otherwise breaks treesitter highlights)
        let g:c_syntax_for_h = 1
      ''}

      ${writeIf cfg.nix.enable ''
        autocmd filetype nix setlocal tabstop=2 shiftwidth=2 softtabstop=2
      ''}

       ${writeIf cfg.rust.enable ''
          function! MapRustTools()
            nnoremap <silent><leader>r1 <cmg>lua require('rust-tools.inlay_hints').toggle_inlay_hints()<CR>
            nnoremap <silent><leader>rr <cmd>lua require('rust-tools.runnables').runnables()<CR>
            nnoremap <silent><leader>re <cmd>lua require('rust-tools.expand_macro').expand_macro()<CR>
            nnoremap <silent><leader>rc <cmd>lua require('rust-tools.open_cargo_toml').open_cargo_toml()<CR>
            nnoremap <silent><leader>rg <cmd>lua require('rust-tools.crate_graph').view_crate_graph('x11', nil)<CR>
          endfunction

         autocmd filetype rust nnoremap <silent><leader>ri <cmd>lua require('rust-tools.inlay_hints').toggle_inlay_hints()<CR>
         autocmd filetype rust nnoremap <silent><leader>rr <cmd>lua require('rust-tools.runnables').runnables()<CR>
         autocmd filetype rust nnoremap <silent><leader>re <cmd>lua require('rust-tools.expand_macro').expand_macro()<CR>
         autocmd filetype rust nnoremap <silent><leader>rc <cmd>lua require('rust-tools.open_cargo_toml').open_cargo_toml()<CR>
         autocmd filetype rust nnoremap <silent><leader>rg <cmd>lua require('rust-tools.crate_graph').view_crate_graph('x11', nil)<CR>
       ''}
    '';

    vim.luaConfigRC = ''
       local attach_keymaps = function(client, bufnr)
         local opts = { noremap=true, silent=true };

        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgn', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgp', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)

        -- Alternative keybinding for code actions for when code-action-menu does not work as expected.
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lsh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ln', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'F', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)

         ${writeIf cfg.scala.enable ''
           -- Metals specific
           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lmc', '<cmd>lua require("metals").commands()<CR>', opts)
           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lmi', '<cmd>lua require("metals").toggle_setting("showImplicitArguments")<CR>', opts)
         ''}
       end

       vim.g.formatsave = ${if cfg.formatOnSave then "true" else "false"};

       -- Enable formatting
       format_callback = function(client, bufnr)
         vim.api.nvim_create_autocmd("BufWritePre", {
           group = augroup,
           buffer = bufnr,
           callback = function()
             if vim.g.formatsave then
                 local params = require'vim.lsp.util'.make_formatting_params({})
                 client.request('textDocument/formatting', params, nil, bufnr)
             end
           end
         })
       end

       default_on_attach = function(client, bufnr)
         attach_keymaps(client, bufnr)
         format_callback(client, bufnr)
       end

       -- Enable lspconfig
       local lspconfig = require('lspconfig')

       local capabilities = vim.lsp.protocol.make_client_capabilities()

       ${writeIf cfg.clang ''
         -- CCLS (clang) config
         lspconfig.ccls.setup {
           capabilities = capabilities;
           on_attach = default_on_attach;
           cmd = {"${pkgs.ccls}/bin/ccls"}
         }
       ''}

       ${writeIf (cfg.csharp.enable && cfg.csharp.type == "omnisharp") ''
         -- C# omnisharp config
         lspconfig.omnisharp.setup {
           capabilities = capabilities;
           on_attach = default_on_attach;
           cmd = {"${pkgs.omnisharp-roslyn}/bin/omnisharp"},
           settings = ${cfg.csharp.omnisharpSettings}
         }
       ''}

       ${writeIf (cfg.csharp.enable && cfg.csharp.type == "csharp_ls") ''
         -- C# csharp_ls config
         lspconfig.csharp_ls.setup { 
          cmd = {"${pkgs.csharp-ls}/bin/csharp-ls"},
         }
       ''}

       ${writeIf cfg.go ''
         -- Go config
         lspconfig.gopls.setup {
           capabilities = capabilities;
           on_attach = default_on_attach;
           cmd = {"${pkgs.gopls}/bin/gopls", "serve"},
         }
       ''}

       ${writeIf cfg.haskell ''
         -- Haskell config
         lsponfig.hls.setup {
           capabilities = capabilities;
           on_attach = default_on_attach;
           cmd = {"${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper", "--lsp"};
           root_dir = lspconfig.util.root_pattern("hie.yaml", "stack.yaml", ".cabal", "cabal.project", "package.yaml");
         }
       ''}

      ${writeIf (cfg.nix.enable && cfg.nix.type == "nixd") ''
        -- Nix config
        lspconfig.nixd.setup{
          capabilities = capabilities;
          on_attach = function(client, bufnr)
            attach_keymaps(client, bufnr)
          end,
          cmd = {"${pkgs.nixd}/bin/nixd"}
        }
      ''}

       ${writeIf (cfg.nix.enable && cfg.nix.type == "nil") ''
         -- Nix config
         lspconfig.nil_ls.setup{
           capabilities = capabilities;
           on_attach = function(client, bufnr)
             attach_keymaps(client, bufnr)
           end,
           settings = {
             ['nil'] = {
               formatting = {
                 command = {"${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"}
               },
               diagnostics = {
                 ignored = { "uri_literal" },
                 excludedFiles = { }
               }
             }
           };
           cmd = {"${pkgs.nil}/bin/nil"}
         }
       ''}

       ${
         writeIf (cfg.nix.enable && cfg.nix.type == "rnix-lsp") ''
           -- Nix config
           lspconfig.rnix.setup{
             capabilities = capabilities;
             on_attach = function(client, bufnr)
               attach_keymaps(client, bufnr)
             end,
             cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"}
           }
         ''
       } 

       ${writeIf cfg.rust.enable ''
         -- Rust config

         local rustopts = {
           tools = {
             autoSetHints = true,
             hover_with_actions = false,
             inlay_hints = {
               only_current_line = false
             }
           },
           server = {
             capabilities = capabilities,
             on_attach = default_on_attach,
             cmd = {"${pkgs.rust-analyzer}/bin/rust-analyzer"},
             settings = {
               ${cfg.rust.rustAnalyzerOpts}
             }
           }
         }

         require('crates').setup {}
         require('rust-tools').setup(rustopts)
       ''}

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

         metals_config.on_attach = function(client, bufnr)
          ${writeIf (dap.enable && dap.scala) ''
            require("metals").setup_dap()
          ''}
           return metals_config
         end
       ''}  

       ${writeIf cfg.terraform.enable ''
         lspconfig.terraformls.setup {}
       ''}
    '';
  };
}
