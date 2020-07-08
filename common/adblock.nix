{ config, pkgs, ... }:
let
  hosts =
    pkgs.fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "a9a4aa2fe7adc1b0f8395e24e89f5fd09143f4e2";
      sha256 = "1yr3r558zchxic8922z1b9zfmw9zmdy4ja17nncv91r1rgxvvvm4";
    };
in
{
  networking.extraHosts = builtins.readFile "${hosts}/hosts";
}
