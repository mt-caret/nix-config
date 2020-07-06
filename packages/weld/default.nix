{ stdenv
, fetchFromGitHub
, rustPlatform
, llvmPackages_6
, libxml2
}:

rustPlatform.buildRustPackage rec {
  pname = "weld";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "weld-project";
    repo = pname;
    rev = "e443e2538e164fe2554a4da0f4fa8d9e34d4947a";
    sha256 = "1gnz69f1x37hdrgnr178yr2f35qqfphnq89jm262nwr4i1fvs9ni";
  };

  cargoSha256 = "03frfnl2sz8dx9hca8jgpc4bdas0rpgvdp8ilvxvv4la2kiac3hh";
  cargoPatches = [ ./add-Cargo.lock.patch ./llvm-prefix.patch ];
  buildInputs = with llvmPackages_6;
    [ llvm clang libxml2 ];
}
