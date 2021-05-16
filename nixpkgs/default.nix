let
  resolve = nixPath: defaultUrl:
    let
      resolvedNixPath = builtins.tryEval nixPath;
    in
      if resolvedNixPath.success then
        resolvedNixPath.value
      else
        builtins.fetchTarball defaultUrl;
  #nixosUrl = channel: "https://nixos.org/channels/${channel}/nixexpr.tar.xz";
  nixosUrl = channel: "https://channels.nixos.org/${channel}/nixexprs.tar.xz";
  version = "20.09";
  defaultArgs = {
    config = import ./config.nix;
    overlays = [ (import ./overlay.nix) ];
  };
  home-manager-path =
    resolve
      <home-manager>
      "https://github.com/nix-community/home-manager/archive/release-${version}.tar.gz";
in
rec {
  nixos = import (resolve <nixos> (nixosUrl "nixos-${version}")) defaultArgs;
  unstable = import (resolve <unstable> (nixosUrl "nixos-unstable")) defaultArgs;
  actual-unstable = import (resolve <actual-unstable> (nixosUrl "nixpkgs-unstable")) defaultArgs;
  home-manager = import home-manager-path defaultArgs;
  home-manager-module = import "${home-manager-path}/nixos";
}
