{ config, lib, pkgs, ... }:
let
  #unstable = import ../nixpkgs/unstable.nix;
  unstable = import (fetchTarball https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz) {
    config = import ../nixpkgs/config.nix;
    overlays = [ (import ../nixpkgs/overlay.nix) ];
  };
  addressMap =
    {
      "n1" = { localAddress = "10.233.0.101"; hostAddress = "10.233.1.101"; };
      "n2" = { localAddress = "10.233.0.102"; hostAddress = "10.233.1.102"; };
      "n3" = { localAddress = "10.233.0.103"; hostAddress = "10.233.1.103"; };
      "n4" = { localAddress = "10.233.0.104"; hostAddress = "10.233.1.104"; };
      "n5" = { localAddress = "10.233.0.105"; hostAddress = "10.233.1.105"; };
    };
  toHostsEntry = name: { localAddress, ... }: "${localAddress} ${name}";
  extraHosts =
    builtins.concatStringsSep "\n"
      (lib.attrsets.mapAttrsToList toHostsEntry addressMap);
  nodeConfig = hostName: { localAddress, hostAddress }: {
    inherit localAddress hostAddress;

    ephemeral = true;
    autoStart = true;
    privateNetwork = true;

    config = { config, pkgs, ... }:
      {
        networking = {
          inherit hostName extraHosts;
        };

        services.openssh = {
          enable = true;
          permitRootLogin = "yes";
        };
        users.users.root.initialPassword = "root";

        system.stateVersion = "20.03";

        systemd.services.dqlite = {
          description = "dqlite distributed SQL database";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          serviceConfig = {
            Type = "exec";
            ExecStart =
              if hostName == "n1" then
                ''
                  ${unstable.go-dqlite}/bin/dqlite-demo \
                    --api ${localAddress}:8000 \
                    --db ${localAddress}:9000 \
                    --dir /run/dqlite \
                    --verbose
                ''
              else
                ''
                  ${unstable.go-dqlite}/bin/dqlite-demo \
                    --api ${localAddress}:8000 \
                    --db ${localAddress}:9000 \
                    --join 10.233.0.101:9000 \
                    --dir /run/dqlite \
                    --verbose
                '';
            User = "dqlite";
            RuntimeDirectory = "dqlite";

            StandardOutput = "file:/var/log/dqlite.log";
            StandardError = "file:/var/log/dqlite.log";
          };
        };

        environment.systemPackages = [ unstable.go-dqlite ];

        users.users.dqlite = {
          uid = config.ids.uids.etcd; # some random unused uid here
          description = "Dqlite daemon user";
          home = "/var/lib/dqlite";
        };

        networking.firewall.allowedTCPPorts = [ 8000 9000 ];
      };
  };
in
{
  containers = lib.attrsets.mapAttrs nodeConfig addressMap;
  networking = {
    inherit extraHosts;
  };
}
