import <unstable> {
  config = import ../common/nixpkgs-config.nix;
  overlays = [ (import ../common/overlay.nix) ];
}
