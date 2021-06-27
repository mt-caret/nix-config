#!/usr/bin/env bash
set -euo pipefail

NIXOS_VERSION="21.05"

run_inside_container() {
  echo "installing nix..."
  curl -L https://nixos.org/nix/install | sh

  echo "setting up nix..."
  . /home/ubuntu/.nix-profile/etc/profile.d/nix.sh

  echo "installing home-manager..."
  cat > .nix-channels << EOF
https://github.com/nix-community/home-manager/archive/release-$NIXOS_VERSION.tar.gz home-manager
EOF
  nix-channel --update

  echo "installing home-manager..."
  nix-shell '<home-manager>' -A install
  ln -sf ~/config/nix-config/ubuntu.nix ~/.config/nixpkgs/home.nix

  echo "switching to new home-manager config..."
  home-manager switch -b old

  echo "container setup done, shutting down..."
  sudo poweroff
}

# c.f. https://www.digitalocean.com/community/questions/how-to-make-sure-that-cloud-init-finished-running
wait_for_container_setup() {
  # possible use `cloud-init status --wait` here?
  # c.f. https://ubuntu.com/blog/cloud-init-v-18-2-cli-subcommands

  while lxc exec "$1" -- [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    sleep 2
    echo "waiting for $1 setup..."
  done

  ERRORS=$(
    lxc exec "$1" -- cat /var/lib/cloud/data/result.json |
      jq '.v1.errors | .[]')

  if [ "$(echo -n "$ERRORS" | wc -l)" != 0 ]; then
    echo "error setting up $1:"
    echo "$ERRORS"
    exit 1
  fi
}

wait_for_container_systemd_resolved() {
  while true; do
    ACTIVE_STATE=$(lxc exec "$1" -- \
      systemctl show systemd-resolved.service --property=ActiveState --value)

    if [ "$ACTIVE_STATE" = "active" ]; then
      break;
    else
      echo "waiting for $1 systemd-resolved (expected 'active' but found '$ACTIVE_STATE')"
      sleep 2
    fi
  done
}

setup() {
  echo "launching container..."
  lxc launch ubuntu:21.04 "$1" \
    --config security.nesting=true << EOF
config:
  user.user-data: |
    #cloud-config
    packages:
    - build-essential
    - pkg-config
    - libgmp-dev
    - libpcre3-dev
EOF

  wait_for_container_setup "$1"
  wait_for_container_systemd_resolved "$1"

  echo "pushing config..."
  lxc file push -r ~/config "$1/home/ubuntu/"

  echo "running setup script..."
  lxc exec "$1" -- \
    sudo --login --user ubuntu bash -c \
      "~/config/nix-config/launch-lxd.sh run_inside_container"

  echo "snapshotting container..."
  lxc snapshot "$1" setup-done

  echo "setup done."
}

eval "$@"
