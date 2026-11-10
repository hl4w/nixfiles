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
      # treesitter 语法解析器随 Nix 一起安装（走 nixpkgs 二进制缓存），
      # 避免运行时由 nvim-treesitter 从 github 下载/编译（国内网络不可达）
      (nvim-treesitter.withPlugins (p: [
        p.nix
        p.lua
        p.python
        p.javascript
        p.typescript
        p.tsx
        p.json
        p.yaml
        p.toml
        p.markdown
        p.markdown_inline
        p.bash
        p.rust
        p.go
        p.html
        p.css
        p.vim
        p.vimdoc
      ]))
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
    '';
    # extraConfig 是 Vimscript，Lua 代码必须放在 extraLuaConfig
    extraLuaConfig = ''
      -- nixpkgs 26.05 的 nvim-treesitter 跟踪上游重写的 main 分支，
      -- 旧的 require('nvim-treesitter.configs').setup() 模块已被移除。
      -- 解析器由 Nix 的 withPlugins 随包安装（见上方 plugins 列表），
      -- 高亮用 Neovim 0.12 内置的 vim.treesitter 启用：
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          -- 无对应解析器的文件类型静默跳过
          pcall(vim.treesitter.start)
        end,
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