import <unstable> {
  config = import ./nixpkgs-config.nix;
  overlays = [ (import ./overlay.nix) ];
}
