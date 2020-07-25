{ config, pkgs, lib, ... }:
{
  # https://github.com/NixOS/nixpkgs/issues/9735#issuecomment-500164017
  systemd.services."console-getty".enable = false;
  systemd.services."getty@".enable = false;

  imports = [ <nixpkgs/nixos/modules/virtualisation/lxc-container.nix> ];
  networking.hostName = lib.mkDefault "nixos";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    vim
    htop
    tmux
    wget
  ];

  networking.useDHCP = true;
}
