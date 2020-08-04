{ config, pkgs, ... }:
rec {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./common/base.nix
    ./common/fonts.nix
    ./common/ime.nix
    ./common/xmonad.nix
    ./common/adblock.nix
    <home-manager/nixos>
    ./common/etcd-cluster.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "artemis";

  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.screenSection = ''
    Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On, ForceFullCompositionPipeline = On }"
    Option "AllowIndirectGLXProtocol" "off"
    Option "TripleBuffer" "on"
  '';

  environment.systemPackages = with pkgs; [
    nvidia-docker
  ];

  services.openssh.enable = true;
  programs.mosh.enable = true;

  home-manager.users.delta = import ./home/home.nix networking.hostName;

  powerManagement.cpuFreqGovernor = "performance";

  system.stateVersion = "18.03";
}
