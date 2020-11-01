#!/usr/bin/env bash
set -euxo pipefail

nix-build '<nixpkgs/nixos>' \
  -A config.system.build.isoImage \
  -I nixos-config=./iso.nix
