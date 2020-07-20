# see https://www.colabug.com/2017/0803/750573/
{ runCommand, fetchFromGitHub, nodePackages }:
let
  # 2020-07-16
  src = fetchFromGitHub {
    owner = "pkra";
    repo = "mathjax-node-page";
    rev = "858955628a6565e68e35a0d6ca4b9787530c7b22";
    sha256 = "158mr6bkl4n0ssbnr32v5nsv4cnddb9gjvvfc4bzwb2p49cckp14";
  };
  fixedSrc = runCommand "mathjax-node-page-nix" {} ''
    cp -r ${src} $out
    chmod +w -R $out
    cd $out
    ${nodePackages.node2nix}/bin/node2nix -l package-lock.json
  '';
in
"${fixedSrc}"
