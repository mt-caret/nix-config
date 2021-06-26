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
      #<home-manager/nixos>
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

  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
    adjtime.source = "/persist/etc/adjtime";
    NIXOS.source = "/persist/etc/NIXOS";
    machine-id.source = "/persist/etc/machine-id";
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
  '';

  environment.systemPackages = with pkgs; [
    compsize # btrfs util
    btrfs-du
  ];

  home-manager.users.delta = import ./home/home.nix networking.hostName;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
