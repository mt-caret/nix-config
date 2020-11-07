{ config, lib, pkgs, ... }:
let
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

        services.etcd =
          let
            peerUrl = "http://${localAddress}:2380";
            clientUrl = "http://${localAddress}:2379";
            toClusterEntry = name: { localAddress, ... }:
              "${name}=http://${localAddress}:2380";
          in
            {
              enable = true;
              name = hostName;

              initialAdvertisePeerUrls = [ peerUrl ];
              listenPeerUrls = [ peerUrl ];

              advertiseClientUrls = [ clientUrl ];
              listenClientUrls = [ clientUrl "http://127.0.0.1:2379" ];

              initialClusterToken = "etcd-cluster";
              initialCluster =
                lib.attrsets.mapAttrsToList toClusterEntry addressMap;
              initialClusterState = "new";

              # Apparently Jepsen can't read journald logs? Unfortunate.
              extraConf.LOG_OUTPUT = "stderr";
            };

        # Workaround for nixos-container issue
        # (see https://github.com/NixOS/nixpkgs/issues/67265 and
        # https://github.com/NixOS/nixpkgs/pull/81371#issuecomment-605526099).
        # The etcd service is of type "notify", which means that
        # etcd would not be considered started until etcd is fully online;
        # however, since networking only works sometime *after*
        # multi-user.target, we forgo etcd's notification entirely.
        systemd.services.etcd.serviceConfig.Type = lib.mkForce "exec";

        systemd.services.etcd.serviceConfig.StandardOutput = "file:/var/log/etcd.log";
        systemd.services.etcd.serviceConfig.StandardError = "file:/var/log/etcd.log";

        networking.firewall.allowedTCPPorts = [ 2379 2380 ];
      };
  };
in
{
  containers = lib.attrsets.mapAttrs nodeConfig addressMap;
  networking = {
    inherit extraHosts;
  };
}
