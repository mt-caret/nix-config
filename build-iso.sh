#!/usr/bin/env bash
set -euxo pipefail

nix-build '<nixos/nixos>' \
  -A config.system.build.isoImage \
  -I nixos-config=./iso.nix
