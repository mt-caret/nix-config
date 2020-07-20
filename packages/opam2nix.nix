{ fetchFromGitHub }:
let
  # 2020-07-07
  src =
    fetchFromGitHub {
      owner = "timbertson";
      repo = "opam2nix";
      rev = "aff7deb541587c0ab01512ad357265d5c6e85616";
      sha256 = "1ql1iijhc3cxpwmhyqk8x00zdga0qh08qpdc2kyspi6m532hb3l1";
    };
in
import src {}
