{ stdenv, fetchFromGitHub, libsoundio, lame }:
stdenv.mkDerivation rec {
  pname = "castty";
  version = "2020-11-10";
  src = fetchFromGitHub {
    owner = "dhobsd";
    repo = pname;
    rev = "333a2bafd96d56cd0bb91577ae5ba0f7d81b3d99";
    sha256 = "0p84ivwsp8ds4drn0hx2ax04gp0xyq6blj1iqfsmrs4slrajdmqs";
  };
  postPatch = ''
    substituteInPlace config.mk --replace "/usr/local" "$out/"
  '';

  buildInputs = [ libsoundio lame ];
}
