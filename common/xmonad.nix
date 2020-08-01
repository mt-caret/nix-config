{ config, lib, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 220 50
      '';
      defaultSession = "none+xmonad";
    };
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.hostname
      ];
    };
    desktopManager.xterm.enable = false;
  };
  services.upower.enable = true;
  environment = {
    systemPackages = with pkgs; [
      haskellPackages.xmobar
      trayer
      rofi
      feh

      udiskie
      networkmanagerapplet
      copyq

      libnotify
      dunst

      plasma-workspace # for xembedsniproxy

      # gtk icons & themes
      # c.f. https://github.com/cstrahan/nixos-config/blob/master/system-packages.nix
      hicolor-icon-theme
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard
      shared-mime-info
    ];
    pathsToLink = [
      "/share"
    ];

    # c.f. https://www.reddit.com/r/NixOS/comments/6j9zlj/how_to_set_up_themes_in_nixos/
    sessionVariables = {
      GTK_PATH = [
        "${config.system.path}/lib/gtk-3.0"
        "${config.system.path}/lib/gtk-2.0"
      ];
      GTK_DATA_PREFIX = [
        "${config.system.path}"
      ];
    };
  };
  programs.slock.enable = true;
}
