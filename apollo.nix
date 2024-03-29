{ pkgs, ... }:
rec {
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ./nixos/base.nix
      ./nixos/fonts.nix
      ./nixos/ime.nix
      ./nixos/xmonad.nix
      ./nixos/adblock.nix
      <home-manager/nixos>
    ];

  # https://github.com/NixOS/nixos-hardware/commit/19b4d5cede55b4a90354890b9e9c82232332c279
  hardware.opengl = {
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
      #intel-ocl
    ];
  };
  hardware.cpu.amd.updateMicrocode = true;
  boot.initrd.kernelModules = [ "i915" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [ "btrfs" ];
  boot.loader.grub.copyKernels = true;
  virtualisation.docker.storageDriver = "btrfs";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "apollo"; # Define your hostname.

  services.tlp.enable = true;
  services.fwupd.enable = true;

  programs = {
    light.enable = true;
    kbdlight.enable = true;
  };

  services.xserver.libinput = {
    enable = true;
    accelSpeed = "1.0";
    disableWhileTyping = true;
    tappingDragLock = false;
  };

  time.timeZone = "Asia/Hong_Kong";
  #time.timeZone = "America/New_York";
  #time.timeZone = "Asia/Tokyo";

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
  boot.initrd = {
    postDeviceCommands = pkgs.lib.mkBefore ''
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
    postMountCommands = ''
      mkdir -p /etc/
      echo "c5c1d4d47d7d4d91a75a07faf6feca60" > /etc/machine-id
    '';
  };

  environment.systemPackages = with pkgs; [
    compsize # btrfs util
    btrfs-du
  ];

  home-manager.users.delta = import ./home/home.nix networking.hostName;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
