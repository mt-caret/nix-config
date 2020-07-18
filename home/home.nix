host: { config, pkgs, lib, ... }:
let
  unstable = import ./unstable.nix;
  isNixOS = host == "athena" || host == "apollo" || host == "artemis";
  private = import ../../private/default.nix;
in
{
  programs.home-manager.enable = true;

  # pass arguments to all imports: https://stackoverflow.com/a/47713963
  _module.args.host = host;
  _module.args.isNixOS = isNixOS;

  imports =
    if isNixOS
    then [ ./gui.nix ./tex.nix ./delta.nix ./vim.nix ./rust.nix ] else
      if host == "ubuntu-container"
      then [ ./ubuntu.nix ./vim.nix ./rust.nix ] else [];

  home.packages = (
    with pkgs; [
      # ranger-tools
      atool
      ffmpegthumbnailer # for video previews
      mediainfo
      p7zip # for atool
      ranger
      ueberzug # for image previews
      unrar # for atool
      unzip # for atool

      # shell-tools
      aria2
      axel
      bc
      bind
      cmus
      colordiff
      comma
      convmv
      docker_compose
      dstat
      entr
      exiftool
      ffmpeg
      file
      gettext
      gnuplot
      go-pup
      graphviz
      htop
      imagemagickBig
      inotify-tools
      jq
      loc
      lsof
      man-pages
      mathjax-node-page
      mosh
      ncdu
      neofetch
      newsboat
      nload
      nkf
      # unfortunately, nmap clashes with nmap-graphical; nothing we can do about this
      #nmap
      openssl
      optipng
      # haskellPackages.patat # broken in nixos-19.03
      pandoc
      haskellPackages.pandoc-sidenote
      haskellPackages.pandoc-crossref # broken in nixpkgs-unstable
      parallel
      pijul
      poppler_utils
      ripgrep
      runzip
      shellcheck
      tokei
      tree
      whois
      zip

      # admin-utils
      pciutils
      powertop
      usbutils
      lshw

      # dev-tools
      indent
      j
      niv
      nixos-generators
      gnumake
      gnum4
      ninja
      gdb
      valgrind
      opam
      nodejs-12_x
      yarn
      (
        python3.withPackages (
          ps: with ps; [
            ipython
            numpy
            scipy
            notebook
            matplotlib
            pandas
            virtualenv
          ]
        )
      )
    ]
  ) ++ (
    with unstable; [
      dejsonlz4
      youtube-dl
      gallery-dl
      clinfo
      stack
    ] ++ (
      if isNixOS
      then [ haskellPackages.haskell-language-server ]
      else []
    )
  );

  programs = {
    command-not-found.enable = true;
    git = {
      enable = true;
      aliases = {
        co = "checkout";
        d = "diff";
        dc = "diff --cached";
        s = "status";
      };
      userEmail = "mtakeda.enigsol@gmail.com";
      userName = "Masayuki Takeda";
      extraConfig = {
        core.askpass = "";
        credential.helper = "store";
      };
    };
    bash = {
      enable = true;
      # TODO: port from zshenv
      initExtra = ''
        function add_to_path_if_exists {
          [ -d "$1" ] && export PATH="$1:$PATH"
        }

        source ${pkgs.git}/share/git/contrib/completion/git-completion.bash
        source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh

        GIT_PS1_SHOWDIRTYSTATE=1
        GIT_PS1_SHOWUPSTREAM=1
        GIT_PS1_SHOWUNTRACKEDFILES=1
        GIT_PS1_SHOWSTASHSTATE=1

        export PS1='\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w\[\033[1;31m\]$(__git_ps1)\[\033[1;32m\]]\[\033[0m\]\$ '

        if [ -f "/etc/NIXOS" ]; then
          # NixOS
          :
        else
          # non-NixOS
          source ~/.nix-profile/etc/profile.d/nix.sh

          add_to_path_if_exists /usr/local/go/bin
        fi
        add_to_path_if_exists ~/.local/bin

        function r {
          tempfile="$(mktemp -t tmp.XXXXXX)"
          ranger --choosedir="$tempfile" "''${@:-$(pwd)}"
          test -f "$tempfile" &&
          if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
              cd -- "$(cat "$tempfile")"
          fi
          rm -f -- "$tempfile"
        }

        if [ -d ~/.opam ]; then
          eval "$(opam config env)"
        fi
      '';
    };
    tmux = {
      enable = true;
      escapeTime = 10;
      terminal = "screen-256color";
      historyLimit = 10000;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      extraConfig = ''
        bind-key -r C-h select-window -t :-
        bind-key -r C-l select-window -t :+

        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xsel --input --clipboard"
      '';
    };
  };

  nixpkgs = {
    config = import ../common/nixpkgs-config.nix;
    overlays = [ (import ../common/overlay.nix) ];
  };
  xdg.configFile."nixpkgs/config.nix".source = ../common/nixpkgs-config.nix;

  # We would like to use xdg.configFile here as well, but doing that will
  # break the relative imports inside the file, so we symlink it instead.
  # Note this implicitly assumes that the config directory exists at $HOME/config.
  #xdg.configFile."nixpkgs/overlays/overlay.nix".source = ../common/overlay.nix;
  home.activation.linkOverlay = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/nixpkgs/overlays/
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG $HOME/config/nix-config/common/overlay.nix \
      ~/.config/nixpkgs/overlays/mutable-overlay.nix
  '';

  xdg.configFile = {
    "ranger/commands_full.py".source = ../../ranger/commands_full.py;
    "ranger/commands.py".source = ../../ranger/commands.py;
    "ranger/rc.conf".source = ../../ranger/rc.conf;
    "ranger/rifle.conf".source = ../../ranger/rifle.conf;
    "ranger/scope.sh".source = ../../ranger/scope.sh;
  };

  programs.ssh = {
    enable = true;
    extraConfig = private.aicSshConfig + private.nySshConfig;
  };

  home.stateVersion = "20.03";
}
