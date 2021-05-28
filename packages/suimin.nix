{ pkgs, fetchFromGitHub }:
let
  # 2021-05-18
  src = fetchFromGitHub {
    owner = "mt-caret";
    repo = "suimin";
    rev = "9ef73b78315e155af9915e9fbc50d0c37c39049f";
    sha256 = "0rlwgwnnr3g30cr7qji95b6i906ifb01mzpd6dv28iv8si15sic8";
  };
in
(import src {}).suimin.components.exes.suimin
