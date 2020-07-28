{ config, pkgs, lib, ... }:
rec {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./common/base.nix
    ./common/fonts.nix
    ./common/ime.nix
    ./common/xmonad.nix
    ./common/adblock.nix
    <home-manager/nixos>
  ];

  networking.hostName = "athena";

  #hardware.opengl = {
  #  #driSupport32Bit = true;
  #  extraPackages = with pkgs; [
  #    vaapiIntel
  #    vaapiVdpau
  #    libvdpau-va-gl
  #    #intel-ocl
  #  ];
  #};

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelModules = [
      "acpi_call"
      "tpm-rng"
      "sg"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      acpi_call
      exfat-nofuse
    ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };
  };

  boot.supportedFilesystems = [ "btrfs" ];
  boot.loader.grub.copyKernels = true;
  virtualisation.docker.storageDriver = "btrfs";

  #hardware.bluetooth.enable = true;

  #networking.networkmanager.wifi.macAddress = "stable";

  networking.networkmanager.dns = "dnsmasq";
  environment.etc."NetworkManager/dnsmasq.d/lxd".text = ''
    server=/lxd/10.66.205.1
  '';

  programs = {
    light.enable = true;
    kbdlight.enable = true;
  };

  services = {
    #avahi.enable = true;
    #dictd = {
    #  enable = true;
    #  DBs = with pkgs.dictdDBs; [ wiktionary ];
    #};

    tlp = {
      enable = true;
      ## fix audio jack noise issue
      #extraConfig = ''
      #  SOUND_POWER_SAVE_ON_BAT=0
      #'';
    };
    xserver = {
      # c.f. https://github.com/NixOS/nixpkgs/issues/19022
      # c.f. https://github.com/NixOS/nixos-hardware/issues/56
      libinput.enable = true;
      synaptics.enable = false;

      config = ''
        Section "InputClass"
          Identifier "Enable libinput for Trackpoint"
          MatchIsPointer "on"
          Driver "libinput"
          Option "ScrollMethod" "button"
          Option "ScrollButton" "8"
        EndSection
      '';
    };
  };

  #time.timeZone = "Asia/Hong_Kong";
  #time.timeZone = "America/New_York";
  time.timeZone = "Asia/Tokyo";

  #services.usbmuxd.enable = true;

  #networking.firewall.allowedTCPPorts = [ 8000 58829 ];

  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
    adjtime.source = "/persist/etc/adjtime";
    NIXOS.source = "/persist/etc/NIXOS";
  };
  systemd.tmpfiles.rules = [
    "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
    "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
    "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
    "L /var/lib/lxd - - - - /persist/var/lib/lxd"
    "L /var/lib/docker - - - - /persist/var/lib/docker"
  ];
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt
    mount -o subvol=/ /dev/mapper/enc /mnt

    # /root contains subvolumes:
    # - /root/var/lib/portables
    # - /root/var/lib/machines
    #
    # This makes `btrfs subvolume delete /mnt/root` fail;
    # so we list them out and delete them here before
    # attempting to delete /root.
    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done &&
    echo "deleting /root subvolume..." &&
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    umount /mnt
    echo 9a56c3aeb34c421491e82de1ee0c927e > /etc/machine-id
  '';

  environment.systemPackages = with pkgs; [
    compsize # btrfs util
    btrfs-du
  ];

  home-manager.users.delta = import ./home/home.nix networking.hostName;

  system.stateVersion = "20.03";
}
