{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # Nix 开发工具和 LSP（editor.nix 中 vim.lsp.enable('nil_ls') 依赖）
    nil
    nixpkgs-fmt

    # C/C++ 开发工具和 LSP
    clang-tools          # 包含 clangd、clang、clang-tidy 等
    llvm
    cmake
    ninja
    gdb
    lldb
    
    # Go 开发工具和 LSP
    go
    gopls
    
    # Python 开发工具和 LSP
    python3
    pyright
    
    # Rust 开发工具和 LSP
    rustc
    rust-analyzer
    rustfmt
    cargo
  ];
}
