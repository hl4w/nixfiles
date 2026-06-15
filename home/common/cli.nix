# 用户级 CLI 工具配置模块
# 包含用户级安装的命令行工具和相关配置
{ pkgs, config, ... }:

{
  # 用户级安装的 CLI 工具
  home.packages = with pkgs; [
    # ===== 搜索工具 =====
    ripgrep  # 快速文本搜索工具
    fd       # 快速文件查找工具
    fzf      # 模糊搜索工具
    
    # ===== 文件工具 =====
    bat      # 增强版 cat（语法高亮）
    eza      # 增强版 ls（替代 exa）
    yazi     # 快速终端文件管理器（用 Rust 编写）
    dust     # 磁盘使用分析工具
    duf      # 磁盘空间查看工具
    
    # ===== 系统工具 =====
    fastfetch # 快速系统信息展示工具
    btop     # 系统资源监控工具
    
    # ===== 开发工具 =====
    tokei    # 代码统计工具
    hyperfine # 命令性能测试工具
    procs    # 增强版 ps 命令
    
    # ===== 导航工具 =====
    zoxide   # 智能目录导航
    starship # 跨 Shell 提示符
  ];

  # FZF 配置
  programs.fzf = {
    enable = true;                 # 启用 FZF
    enableZshIntegration = true;   # 启用 Zsh 集成
  };

  # Zoxide 配置
  programs.zoxide = {
    enable = true;                 # 启用 Zoxide
    enableZshIntegration = true;   # 启用 Zsh 集成
  };

  # Yazi 配置
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # Yazi 内部 shell 启用 zoxide 集成（按 `Ctrl+G` 然后 `z` 使用 zoxide 跳转）
    shell = {
      enableZoxideIntegration = true;
    };
  };
}