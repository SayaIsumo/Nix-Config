{ pkgs, ... }:

let
  concatFiles = files: pkgs.lib.strings.concatMapStringsSep "\n" builtins.readFile files;
in
{

  programs.neovim = {
    withRuby = false;
    withPython3 = true;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    initLua = (
      concatFiles [
        ./luafiles/set.lua
        ./luafiles/remap.lua
        ./luafiles/claude.lua
      ]
    );
    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      telescope-fzf-native-nvim
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = ''
          	        require("catppuccin").setup({
                          integrations = {
                              cmp = true,
                              gitsigns = true,
                              nvimtree = true,
                              telescope = true,
                              fidget = true,
                              treesitter = true,
                              illuminate = true,
                              lsp_saga = true,
                          }
                      })
          	        vim.cmd.colorscheme "catppuccin"
          	      '';
      }
      {
        plugin = (
          nvim-treesitter.withPlugins (
            plugins: with plugins; [
              tree-sitter-bash
              tree-sitter-c
              tree-sitter-cpp
              tree-sitter-go
              tree-sitter-python
              tree-sitter-latex
              tree-sitter-lua
              tree-sitter-rust
              tree-sitter-scss
              tree-sitter-typescript
              tree-sitter-html
              tree-sitter-css
              tree-sitter-javascript
              tree-sitter-yaml
              tree-sitter-toml
              tree-sitter-markdown
              tree-sitter-markdown-inline
              tree-sitter-nix
            ]
          )
        );
        type = "lua";
        config = ''
          -- nvim-treesitter's main branch no longer has a `highlight` module;
          -- highlighting is started per buffer through the built-in API.
          vim.api.nvim_create_autocmd('FileType', {
              group = vim.api.nvim_create_augroup('TreesitterHighlight', {}),
              callback = function(args)
                  pcall(vim.treesitter.start, args.buf)
              end,
          })
        '';
      }
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = "  vim.g.loaded_netrw = 1\n  vim.g.loaded_netrwPlugin = 1\n  vim.opt.termguicolors = true\n  require(\"nvim-tree\").setup()\n";
      }
      nvim-web-devicons
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          	        require("lualine").setup {
          	          options = {
          	            theme = "catppuccin",
          	          },
                        extensions = {
                            'nvim-tree',
                        },
          	        }
          	      '';
      }
      vim-fugitive
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = "require('nvim-autopairs').setup {}";
      }
      {
        plugin = nvim-ts-autotag;
        type = "lua";
        config = ''
          require('nvim-ts-autotag').setup({
            opts = {
              -- Defaults
              enable_close = true, -- Auto close tags
              enable_rename = true, -- Auto rename pairs of tags
              enable_close_on_slash = false -- Auto close on trailing </
            },
            -- Also override individual filetype configs, these take priority.
            -- Empty by default, useful if one of the "opts" global settings
            -- doesn't work well in a specific filetype
            per_filetype = {
              ["html"] = {
                enable_close = false
              }
            }
          })
        '';
      }
      nvim-surround
      vim-illuminate
      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = ''require("colorizer").setup()'';
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = "require('gitsigns').setup()";
      }
      {
        plugin = dashboard-nvim;
        type = "lua";
        config = "require('dashboard').setup {}";
      }
      claudecode-nvim
      # completion plugin setup
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      friendly-snippets
      lspkind-nvim
      {
        plugin = crates-nvim;
        type = "lua";
        config = ''
          require('crates').setup()
          require('crates').show()
        '';
      }
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile (./luafiles/cmp.lua);
      }
      # LSP Setup
      {
        plugin = lspsaga-nvim;
        type = "lua";
        config = ''
          require('lspsaga').setup({
              ui = {
                  title = true,
                  border = 'rounded',
                  kind = require('catppuccin.groups.integrations.lsp_saga').custom_kind(),
              },
              definition = {
                  keys = {
                      edit = '<CR>',
                  },
              },
          })
        '';
      }
      rustaceanvim
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile (./luafiles/lsp-config.lua);
      }
      none-ls-extras-nvim
      {
        plugin = none-ls-nvim;
        type = "lua";
        config = builtins.readFile (./luafiles/null-ls.lua);
      }
      vim-tmux-navigator
      vim-tmux-clipboard
      lazygit-nvim
      {
        plugin = fidget-nvim;
        type = "lua";
        config = ''
          require('fidget').setup()
        '';
      }
    ];
  };
}
