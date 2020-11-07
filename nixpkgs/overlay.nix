_self: super:
with super; {
  weld = callPackage ../packages/weld {};
  comma = callPackage ../packages/comma.nix {};
  btrfs-du = callPackage ../packages/btrfs-du.nix {};
  nixos-generators = callPackage ../packages/nixos-generators.nix {};
  mathjax-node-page = callPackage ../packages/mathjax-node-page.nix {};
  ghidra-hidpi = ghidra-bin.overrideAttrs (
    _oldAttrs: {
      postPath = ''
        substituteInPlace ./support/launch.properties \
          --replace "Dsun.java2d.uiScale=1" "Dsun.java2d.uiScale=2"
      '';
    }
  );
  obelisk = callPackage ../packages/obelisk.nix {};
  go-dqlite = callPackage ../packages/go-dqlite.nix {};
  chromium-with-flash = chromium.override { enablePepperFlash = true; };
  toolbox = callPackage ../packages/toolbox.nix {};
}
