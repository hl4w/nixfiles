# 系统字体配置模块
# 统一管理系统级字体安装，独立于主题配色配置
# 适用于所有主机类型（桌面、笔记本、服务器）
# 特别优化支持 WPS Office CN 中国版
{ pkgs, lib, ... }:

{
  # 系统级字体安装（NixOS 26.05 官方包名）
  # 字体包必须放在 fonts.packages 中，而不是 environment.systemPackages
  fonts.packages = with pkgs; [
    # 基础字体
    noto-fonts                  # Noto 基础字体
    noto-fonts-cjk              # Noto CJK 字体（中日韩统一包）
    noto-fonts-emoji            # Noto Emoji 字体
    noto-fonts-color-emoji      # Noto 彩色 Emoji 字体
    cantarell-fonts             # Cantarell 字体（GNOME 默认）
    liberation-fonts            # Liberation 字体（替代微软字体）
    
    # 中文字体（支持 WPS Office CN）
    wqy_microhei                # 文泉驿微米黑
    wqy_zenhei                  # 文泉驿正黑
    source-han-sans             # 思源黑体
    source-han-serif            # 思源宋体
    source-han-mono             # 思源等宽
    
    # 编程字体
    jetbrains-mono              # JetBrains Mono 等宽字体
    nerd-fonts.jetbrains-mono   # JetBrains Mono Nerd Font（终端/编辑器图标支持）
    fira-code                   # Fira Code 编程字体（连字支持）
    source-code-pro             # Source Code Pro 编程字体
    iosevka                     # Iosevka 编程字体（高度可定制）
    
    # 图标字体
    font-awesome                # Font Awesome 图标字体
    
    # 其他语言支持
    ipaexfont                   # IPA 字体（日文支持）
  ];

  # 拼写检查器（系统级安装）
  # 使用 nuspell 替代 hunspell，更快且兼容 Hunspell 词典格式
  # 注意：nuspell/hunspell 不支持中文，因为其分词机制基于空格和字母边界
  # 中文拼写检查建议使用 LanguageTool 或其他专门的中文分词工具
  environment.systemPackages = with pkgs; [
    nuspell                    # Nuspell 拼写检查引擎（比 Hunspell 快 3 倍）
    hunspellDicts.en-us        # 英语（美国）拼写词典
    hunspellDicts.en-gb-ise    # 英语（英国）拼写词典（-ise 结尾）
  ];

  # 字体渲染配置
  fonts = {
    enableDefaultPackages = true;  # 启用默认字体配置
    
    # 字体别名配置（默认英文字体，通过 fallback 支持中文）
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Noto Sans" ];           # 默认英文字体
        serif = [ "Noto Serif" ];              # 默认英文衬线字体
        monospace = [ "JetBrains Mono" ];      # 默认英文等宽字体
        emoji = [ "Noto Color Emoji" ];        # Emoji 字体
      };
      
      # WPS Office CN 字体别名映射（兼容常见文档字体名）
      # 使用 localConf 添加自定义 FontConfig XML 配置
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <!-- Windows 字体别名 -> 系统字体映射 -->
          <alias binding="strong">
            <family>SimSun</family>
            <prefer><family>Noto Serif CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>SimHei</family>
            <prefer><family>Noto Sans CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>Microsoft YaHei</family>
            <prefer><family>Noto Sans CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>Microsoft JhengHei</family>
            <prefer><family>Noto Sans CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>KaiTi</family>
            <prefer><family>Noto Serif CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>FangSong</family>
            <prefer><family>Noto Serif CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>STSong</family>
            <prefer><family>Noto Serif CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>STHeiti</family>
            <prefer><family>Noto Sans CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>STKaiti</family>
            <prefer><family>Noto Serif CJK SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>STFangsong</family>
            <prefer><family>Noto Serif CJK SC</family></prefer>
          </alias>
          
          <!-- 思源字体别名 -->
          <alias binding="strong">
            <family>Source Han Sans SC</family>
            <prefer><family>Source Han Sans SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>Source Han Serif SC</family>
            <prefer><family>Source Han Serif SC</family></prefer>
          </alias>
          <alias binding="strong">
            <family>Source Han Mono SC</family>
            <prefer><family>Source Han Mono SC</family></prefer>
          </alias>
          
          <!-- 文泉驿字体别名 -->
          <alias binding="strong">
            <family>WenQuanYi Micro Hei</family>
            <prefer><family>WenQuanYi Micro Hei</family></prefer>
          </alias>
          <alias binding="strong">
            <family>WenQuanYi Zen Hei</family>
            <prefer><family>WenQuanYi Zen Hei</family></prefer>
          </alias>
        </fontconfig>
      '';
    };
  };

  # 字体相关环境变量（针对 WPS Office CN 优化）
  environment.sessionVariables = {
    WPS_FONT_ROOT = "${pkgs.wqy_zenhei}/share/fonts";  # WPS Office 字体路径
    FONTCONFIG_PATH = "/etc/fonts/conf.d";             # FontConfig 配置路径
    XDG_DATA_DIRS = "${pkgs.noto-fonts-cjk}/share:${pkgs.source-han-sans}/share:/usr/share";
  };
}
