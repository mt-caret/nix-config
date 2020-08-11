{ config, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm.enable = true;
      defaultSession = "none+xmonad";
    };
    windowManager.xmonad.enable = true;
    desktopManager.xterm.enable = false;
  };
  services.upower.enable = true;
  environment = {
    systemPackages = with pkgs; [
      rofi
      feh

      libnotify
      dunst

      # gtk icons & themes
      # c.f. https://github.com/cstrahan/nixos-config/blob/master/system-packages.nix
      gtk2
      gnome3.defaultIconTheme
      gnome3.adwaita-icon-theme
      gnome3.gnome-themes-standard
      gnome3.gnome-themes-extra
      gnome2.gnome_icon_theme
      hicolor-icon-theme
      tango-icon-theme
      shared-mime-info
      breeze-icons
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
      # https://github.com/taffybar/taffybar/issues/403#issuecomment-539916486
      GDK_PIXBUF_MODULE_FILE =
        "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };
  };
  gtk.iconCache.enable = true;
  programs.slock.enable = true;
}
