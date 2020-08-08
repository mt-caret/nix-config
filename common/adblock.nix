{ pkgs, ... }:
let
  hosts-src =
    pkgs.fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "ca3a99a0499add858969ce8747049e681b85a2e2";
      sha256 = "1mz3axgwv4n8q9k37hr2ajgppnmw2ayg9z18lbybykhwdybimhhc";
    };
  hosts = pkgs.runCommand "hosts" {} ''
    # fix for https://github.com/StevenBlack/hosts/issues/163
    sed '/%lo/d' ${hosts-src}/hosts > $out
  '';
in
{
  networking.extraHosts = builtins.readFile "${hosts}";
}
