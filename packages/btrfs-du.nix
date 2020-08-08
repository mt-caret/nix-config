{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "btrfs-du";
  version = "2020-06-16";

  src = fetchFromGitHub {
    owner = "nachoparker";
    repo = pname;
    rev = "239fbb80daeffcd695c0493f04968a5690fb4f80";
    sha256 = "1g295sqplfacjjjz9vw7318wiwqlc633xi9mbdbc7g8x7nzyjjkx";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp btrfs-du $out/bin
  '';
}
