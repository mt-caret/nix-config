{ lib
, fetchFromGitHub
, buildGoModule
, go-md2man
, podman
}:
buildGoModule rec {
  pname = "toolbox";
  version = "0.0.97";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "toolbox";
    rev = "3cbd2a1343e614a4064f9650c5e0b466ae3cfb94";
    sha256 = "0x46sn8wcrnhkv63gcnh54n6g47b3rzzmnh0apcs62xywvfkcvir";
  };
  sourceRoot = "source/src";

  vendorSha256 = "06s97kpbw40571jjp96jpld1qxb2frd4akcrwwxi1minvs24lb5p";

  nativeBuildInputs = [
    go-md2man
  ];

  buildInputs = [
    podman
  ];

  postBuild = ''
    cd ../
    mkdir -p $out/man/man1
    find ./doc -name '*.md' | while read markdown_path; do
      go-md2man \
        -in $markdown_path \
        -out $out/man/man1/$(basename -s .md $markdown_path)
    done
  '';

  postInstall = ''
    install -Dm444 completion/bash/toolbox \
      $out/share/bash-completion/completions/toolbox

    install -Dm444 profile.d/toolbox.sh \
      $out/share/profile.d/toolbox.sh
  '';

  meta = with lib; {
    description = "Unprivileged development environment";
    homepage = "https://github.com/containers/toolbox";
    license = licenses.asl20;
    maintainers = with maintainers; [ mt-caret ];
    platforms = platforms.linux;
  };
}
