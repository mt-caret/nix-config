{ pkgs, ... }:
let
  unstable = import ../common/unstable.nix;
  # bumped on 2020-06-27
  rust-overlay-src =
    builtins.fetchGit {
      url = "https://github.com/mozilla/nixpkgs-mozilla";
      ref = "master";
      rev = "e912ed483e980dfb4666ae0ed17845c4220e5e7c";
    };
in
{
  nixpkgs.overlays = [
    (import "${rust-overlay-src}/rust-overlay.nix")
  ];

  home.packages = with pkgs; [] ++ (
    with unstable; [
      rustup
      rust-analyzer
    ]
  );
}
