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

  boot.supportedFilesystems = [ "btrfs" ];
  boot.loader.grub.copyKernels = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.acpilight.enable = true;

  networking.hostName = "aphrodite"; # Define your hostname.

  time.timeZone = "Asia/Hong_Kong";
  #time.timeZone = "America/New_York";
  #time.timeZone = "Asia/Tokyo";

  programs.light.enable = true;

  services.xserver.libinput = {
    enable = true;
    touchpad = {
      accelSpeed = "1.0";
      disableWhileTyping = true;
      tappingDragLock = false;
    };
  };

  environment.systemPackages = with pkgs; [
    compsize # btrfs util
    btrfs-du
    xorg.xbacklight
  ];

  home-manager.users.delta = import ./home/home.nix networking.hostName;

  system.stateVersion = "21.05"; # Did you read the comment?
}
