{ fetchFromGitHub, pkgs }:
let
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixos-generators";
    rev = "d72adc1a0ac1fda485c6b694b2e0a1d75de42955";
    sha256 = "1kammk9aga6a74b77ynaxsrqqf44siy7fa0by3l7czz7inak6z5v";
  };
in
import "${src}/default.nix" { inherit pkgs; }
