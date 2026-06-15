{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # C/C++ 开发工具和 LSP
    clang-tools
    clangd
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
