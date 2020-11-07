{ pkgs, ... }:
rec {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./nixos/base.nix
    ./nixos/fonts.nix
    ./nixos/ime.nix
    ./nixos/xmonad.nix
    ./nixos/adblock.nix
    <home-manager/nixos>
    ./nixos/dqlite-cluster.nix
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
