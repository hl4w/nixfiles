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
      #
      # 补全链已移除：nvim-cmp / cmp-nvim-lsp / cmp-buffer / cmp-path
      # 原因：这些插件需从 github.com 拉取源码（cache.nixos.org 与国内镜像
      # 均缺少对应 unstable 版本的二进制缓存），而 github 在国内网络不可达，
      # 导致构建时 curl 超时并连带 home-manager-generation 全链失败。
      # LSP 本身仍可用（nvim-lspconfig 保留），补全依靠 Neovim 0.12 内置
      # 的 vim.lsp.omnifunc（见下方 extraConfig）。
      #
      nvim-treesitter
      gruvbox-nvim
      lualine-nvim
      bufferline-nvim
      which-key-nvim
      comment-nvim
      gitsigns-nvim
      nvim-lspconfig
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