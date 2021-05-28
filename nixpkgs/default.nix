let
  resolve = nixPath: defaultUrl:
    let
      resolvedNixPath = builtins.tryEval nixPath;
    in
      if resolvedNixPath.success then
        resolvedNixPath.value
      else
        builtins.trace
          "WARNING: could not resolve path, defaulting to '${defaultUrl}'"
          (builtins.fetchTarball defaultUrl);
  channelUrl = channel: "https://channels.nixos.org/${channel}/nixexprs.tar.xz";
  version = "20.09";
  defaultArgs = {
    config = import ./config.nix;
    overlays = [ (import ./overlay.nix) ];
  };
  channels = [
    {
      importPath = <nixos>;
      name = "nixos";
      url = channelUrl "nixos-${version}";
    }
    {
      importPath = <unstable>;
      name = "unstable";
      url = channelUrl "nixos-unstable";
    }
    {
      importPath = <actual-unstable>;
      name = "actual-unstable";
      url = channelUrl "nixpkgs-unstable";
    }
    {
      importPath = <home-manager>;
      name = "home-manager";
      url = "https://github.com/nix-community/home-manager/archive/release-${version}.tar.gz";
    }
  ];
  allNixpkgs =
    builtins.listToAttrs (
      builtins.concatMap (
        { importPath, name, url }:
          let
            path = resolve importPath url;
          in
            [
              {
                inherit name;
                value = import path defaultArgs;
              }
              {
                name = "${name}-nixos";
                value = "${path}/nixos";
              }
            ]
      ) channels
    );
in
allNixpkgs
// rec {
  inherit defaultArgs;

  nix-channels = allNixpkgs.nixos.writeTextFile {
    name = ".nix-channels";
    text =
      builtins.concatStringsSep "\n"
        (builtins.map ({ name, url, ... }: "${url} ${name}") channels);
  };
  home-manager-config = { pkgs, lib, ... }: {
    home.file.".nix-channels".source = nix-channels;
  };
}
