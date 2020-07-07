self: super:
with super; {
  weld = callPackage ../packages/weld {};
  comma = callPackage (callPackage ../packages/comma.nix {}) {};
  btrfs-du = callPackage ../packages/btrfs-du.nix {};
}
