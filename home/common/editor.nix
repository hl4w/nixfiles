{ pkgs, config, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      telescope-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      lspconfig
      nvim-treesitter
      gruvbox-nvim
      lualine-nvim
      bufferline-nvim
      which-key-nvim
      comment-nvim
      autopairs-nvim
      gitsigns-nvim
      nvim-lspconfig
      nixvim
      nix-syntax-vim
    ];
    extraConfig = ''
      set number
      set relativenumber
      set mouse=a
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set termguicolors
      colorscheme gruvbox

      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'nix',
          'lua',
          'python',
          'javascript',
          'typescript',
          'tsx',
          'json',
          'yaml',
          'toml',
          'markdown',
          'bash',
          'rust',
          'go',
          'html',
          'css'
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })

      require('lspconfig').nil_ls.setup({
        on_attach = function(client, bufnr)
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        end,
        settings = {
          ['nil'] = {
            formatting = {
              command = { 'nixpkgs-fmt' },
            },
            diagnostics = {
              enable = true,
            },
          },
        },
      })

      require('lspconfig').clangd.setup({
        on_attach = function(client, bufnr)
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        end,
      })

      require('lspconfig').gopls.setup({
        on_attach = function(client, bufnr)
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        end,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
          },
        },
      })

      require('lspconfig').pyright.setup({
        on_attach = function(client, bufnr)
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        end,
      })

      require('lspconfig').rust_analyzer.setup({
        on_attach = function(client, bufnr)
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        end,
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = 'clippy',
            },
          },
        },
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'nix',
        callback = function()
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
          vim.opt_local.softtabstop = 2
        end,
      })
    '';
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      paging = true;
      decorations = "always";
      showLineNumbers = true;
      showFileNames = true;
      showGitChanges = true;
    };
  };
}