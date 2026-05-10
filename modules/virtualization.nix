{pkgs,  ...}: 

{
  # 只开启docker、podman其一
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [ "223.5.5.5" ];     # 国内DNS
    };

    # 推荐：rootless 安全模式（可选）
    rootless = {
      enable = false;  # 新手先关，稳定后再开
      setSocketVariable = true;
    };
  };

  virtualisation.podman.enable = false;

  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
      qemu = {
        runAsRoot = false;
        # ovmf submodule REMOVED: All OVMF images are now available by default in nixpkgs-unstable
        swtpm.enable = true; # TPM emulation
        vhostUserPackages = with pkgs; [ virtiofsd ];

        verbatimConfig = ''
          user = "qemu-libvirtd"
          group = "kvm"
          dynamic_ownership = 1
          remember_owner = 0
        '';
      };
      allowedBridges = [
        "virbr0" # Default NAT bridge
        "br0" # Custom bridge if needed
      ];
    };

    # Kernel modules for better VM performance
    spiceUSBRedirection.enable = true;
  };

  programs = {
    virt-manager.enable = true;
    dconf.enable = true; # Required for virt-manager settings
  };

  environment.systemPackages = with pkgs; [
    virt-viewer # View Virtual Machines
    open-vm-tools   # 虚拟工具
    
    docker  docker-compose
    lazydocker
    docker-client
    qemu_kvm # KVM support
    OVMF # UEFI firmware
    swtpm # TPM emulation
    libguestfs # VM disk tools
    virt-top # Monitor VM performance
    spice # SPICE protocol support
    #spice-gtk # SPICE client GTK
    spice-protocol # SPICE protocol headers
    virglrenderer # Virtual GPU support
    mesa # OpenGL support for VMs
    dnsmasq
    bridge-utils
  ];

  # Enable necessary kernel modules for VM performance
  #boot.kernelModules = ["kvm-amd" "kvm-intel" "vfio-pci"];

  # Add boot kernel parameters for better graphics support
  #boot.kernelParams = [
  #  "intel_iommu=on"
  #  "iommu=pt"
  #];

  # Create default ISO and VM directories with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/isos 0755 qemu-libvirtd kvm -"
    "d /var/lib/libvirt/images 0755 qemu-libvirtd kvm -"
  ];
}
