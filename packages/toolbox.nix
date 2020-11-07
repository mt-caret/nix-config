{ lib
, fetchFromGitHub
, buildGoModule
, go-md2man
, podman
}:
buildGoModule rec {
  pname = "toolbox";
  version = "0.0.92";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "toolbox";
    rev = "cb5c77eae5b4cf4ea2d2970aaf88efeb1ccfc338";
    sha256 = "0lqrhqpi012m9qadh9lgqmqshfwfkmfd0h5nfg7692rza0gkiy85";
  };
  sourceRoot = "source/src";

  vendorSha256 = "1dvcwg0hzababiww3r2zv188nkxrisppng1izx9j1d3zs4h3bx22";

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
  '';

  meta = with lib; {
    description = "Unprivileged development environment";
    homepage = "https://github.com/containers/toolbox";
    license = licenses.asl20;
    maintainers = with maintainers; [ mt-caret ];
    platforms = platforms.linux;
  };
}
