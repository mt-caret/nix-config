{ config, pkgs, ... }:
{
  imports = [
    <nixos/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix>
    <nixos/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  boot.loader.grub.memtest86.enable = true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    gparted
    htop
    keepassxc
    nix-prefetch-scripts
    tmux
    veracrypt
    vim
    wget
  ];
}
