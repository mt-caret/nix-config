{ lib, pkgs, ... }:
let
  private = import ../../private/default.nix;
in
{
  system.copySystemConfiguration = true;

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
  };

  console = {
    keyMap = "us";
    font = "lat9w-16";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "en_DK.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
  };

  time.timeZone = lib.mkDefault "Asia/Tokyo";

  users = {
    mutableUsers = false;
    users = {
      delta = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "libvirtd"
          "lxd"
          "vboxusers"
          "dialout"
          "kvm"
          "render"
          "video"
        ];
        hashedPassword = private.deltaHashedPassword;
      };
      root = {
        subGidRanges = [ { count = 1; startGid = 100; } ];
        subUidRanges = [ { count = 1; startUid = 1000; } ];
        hashedPassword = private.rootHashedPassword;
      };
    };
  };

  environment.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "${pkgs.less}/bin/less -R";
    LANGUAGE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_DK.UTF-8"; # for ISO 8601 date formats i.e. "YYYY-MM-DD"
  };

  security.sudo.enable = true;

  virtualisation.podman.enable = true;
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
  };

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    git
    tmux
    zsh

    nix-prefetch-scripts
    nix-index
  ];

  programs.command-not-found.enable = true;

  location = {
    latitude = 36.0;
    longitude = 140.0;
  };

  services = {
    # DBus error fix https://github.com/NixOS/nixpkgs/issues/16327
    gnome.at-spi2-core.enable = true;

    redshift = {
      enable = true;
      extraOptions = [ "-m randr" ];
    };
    syncthing = {
      enable = true;
      group = "users";
      user = "delta";
      dataDir = "/home/delta/syncthing";
      openDefaultPorts = true;
    };
    udev.extraRules = ''
      # android devices should be owned by me
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_MODEL}=="Android", OWNER="delta", GROUP="users"
    '';
    xserver = {
      enable = true;
      layout = "us";
      defaultDepth = 24;
      deviceSection = ''
        Option "TearFree" "true"
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime"     "0"
        Option "BlankTime"   "0"
      '';
      xkbOptions = "ctrl:nocaps";
      desktopManager.wallpaper.mode = "fill";
    };
  };

  documentation.dev.enable = true;

  boot = {
    cleanTmpDir = true;
    tmpOnTmpfs = true;
  };

  nix = {
    useSandbox = true;
    daemonNiceLevel = 10;
    daemonIONiceLevel = 5;
    maxJobs = "auto";
    trustedUsers = [ "root" "delta" ];
  };
  nixpkgs = (import ../nixpkgs).defaultArgs;
  systemd.tmpfiles.rules = [
    "L+ /root/.nix-channels - - - - ${(import ../nixpkgs).nix-channels}"
  ];
}
