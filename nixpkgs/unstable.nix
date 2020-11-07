import <unstable> {
  config = import ./config.nix;
  overlays = [ (import ./overlay.nix) ];
}
