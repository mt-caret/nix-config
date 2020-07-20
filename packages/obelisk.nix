{ fetchFromGitHub, pkgs }:
let
  # 2020-07-10
  src = fetchFromGitHub {
    owner = "obsidiansystems";
    repo = "obelisk";
    rev = "4f2d3f1c1312d833ae814b7a86cf7b65ea0614ec";
    sha256 = "1shk8yy5pbakcw8aq6b8s3g2xblzf24l78mq0ca0asnvifnp83yb";
  };
in
import src
