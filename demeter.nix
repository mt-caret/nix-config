{ config, pkgs, ... }:
rec {
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ./nixos/base.nix
      ./nixos/fonts.nix
      ./nixos/ime.nix
      ./nixos/xmonad.nix
      ./nixos/adblock.nix
      (import ./nixpkgs).home-manager-nixos
    ];

  hardware.cpu.amd.updateMicrocode = true;

  boot.supportedFilesystems = [ "btrfs" ];
  boot.loader.grub.copyKernels = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "demeter"; # Define your hostname.

  time.timeZone = "Asia/Hong_Kong";
  #time.timeZone = "America/New_York";
  #time.timeZone = "Asia/Tokyo";

  environment.systemPackages = with pkgs; [
    compsize # btrfs util
    btrfs-du
  ];

  home-manager.users.delta = import ./home/home.nix networking.hostName;

  system.stateVersion = "20.09"; # Did you read the comment?
}
