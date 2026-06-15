# 音频配置模块
# 包含完整的音频系统配置（PipeWire + rtkit）
# 参考：https://nixos.wiki/wiki/PipeWire
{ pkgs, lib, ... }:

{
  # ============================================
  # 实时音频服务
  # ============================================
  # rtkit 确保音频进程以实时优先级运行
  security.rtkit.enable = true;

  # ============================================
  # PipeWire 音频服务器
  # ============================================
  # PipeWire 是现代多媒体框架，支持 PulseAudio/JACK/ALSA 兼容
  services.pipewire = {
    enable = true;

    # ALSA 兼容支持
    alsa.enable = true;
    alsa.support32Bit = true;

    # PulseAudio 兼容支持
    pulse.enable = true;

    # JACK 兼容支持（按需启用）
    # jack.enable = true;
  };

  # ============================================
  # PulseAudio 兼容性
  # ============================================
  # 禁用系统级 PulseAudio，使用 PipeWire 替代
  hardware.pulseaudio.enable = false;
}
