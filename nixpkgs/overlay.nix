_self: super:
with super; {
  btrfs-du = callPackage ../packages/btrfs-du.nix {};
  castty = callPackage ../packages/castty.nix {};
  chromium-with-flash = chromium.override { enablePepperFlash = true; };
  comma = callPackage ../packages/comma.nix {};
  ghidra-hidpi = ghidra-bin.overrideAttrs (
    _oldAttrs: {
      postPath = ''
        substituteInPlace ./support/launch.properties \
          --replace "Dsun.java2d.uiScale=1" "Dsun.java2d.uiScale=2"
      '';
    }
  );
  go-dqlite = callPackage ../packages/go-dqlite.nix {};
  mathjax-node-page = callPackage ../packages/mathjax-node-page.nix {};
  nixos-generators = callPackage ../packages/nixos-generators.nix {};
  obelisk = callPackage ../packages/obelisk.nix {};
  suimin = callPackage ../packages/suimin.nix {};
  toolbox = callPackage ../packages/toolbox.nix {};
  weld = callPackage ../packages/weld {};
}
