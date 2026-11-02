# 安全配置模块
# 参考: https://nixos.wiki/wiki/Security
{ pkgs, lib, ... }:

{
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;    # wheel 组用户免密 sudo（仅限受信主机）
    };

    # faillock / pam_faillock: 在 NixOS 中通过 security.pam 添加自定义规则实现，
    # 没有 security.faillock.enable 直接选项。默认 PAM 已包含基本的登录失败限制。

    # SSH Agent 授权登录（可选）：启用后 sudo 可通过 SSH agent 中的密钥授权
    # pam.enableSSHAgentAuth = true;

    # 安全加固（可选）：内核模块加载锁定、Page Table Isolation 等
    # lockKernelModules = true;
    # forcePageTableIsolation = true;
  };

  # Firejail 沙箱（可选，需要在系统级安装时使用）
  programs.firejail.enable = true;

  # 防火墙配置
  networking.firewall = {
    enable = true;
    # 仅开放 TCP 80/443（HTTP/HTTPS 均为 TCP 协议，UDP 规则无意义）
    allowedTCPPorts = [ 80 443 ];
    # allowedUDPPorts 留空（服务器按需添加 DNS/VoIP 等）
  };
}