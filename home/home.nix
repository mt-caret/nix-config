host: { pkgs, lib, ... }:
let
  unstable = (import ../nixpkgs).unstable;
  isNixOS = host == "athena" || host == "apollo" || host == "artemis" || host == "demeter";
  private = import ../../private/default.nix;
in
{
  programs.home-manager.enable = true;

  # pass arguments to all imports: https://stackoverflow.com/a/47713963
  _module.args.host = host;
  _module.args.isNixOS = isNixOS;

  imports =
    if isNixOS
    then [
      ./gui.nix
      ./tex.nix
      ./delta.nix
      ./vim.nix
      ./rust.nix
      ./newsboat.nix
      (import ../nixpkgs).home-manager-config
    ] else
      if host == "ubuntu-container"
      then
        [
          ./ubuntu.nix
          ./vim.nix
          ./rust.nix
          (import ../nixpkgs).home-manager-config
        ] else [];

  home.packages = (
    with pkgs; [
      # ranger-tools
      atool
      atop
      ffmpegthumbnailer # for video previews
      mediainfo
      # what a shame:
      # https://github.com/NixOS/nixpkgs/blob/54f5bff2b5e02a5a6ac0d8f8caf6716cd2a22bd5/pkgs/tools/archivers/p7zip/default.nix#L65
      # p7zip # for atool
      ranger
      ueberzug # for image previews
      unrar # for atool
      unzip # for atool

      # shell-tools
      aria2
      axel
      bat
      bc
      bind
      cachix
      cmus
      colordiff
      comma
      convmv
      dstat
      entr
      exiftool
      ffmpeg
      file
      gettext
      gnuplot
      go-pup
      graphviz
      hledger
      hledger-web
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
      nix-linter
      nload
      nkf
      # unfortunately, nmap clashes with nmap-graphical; nothing we can do about this
      #nmap
      openssl
      optipng
      # haskellPackages.patat # broken in nixos-19.03
      pandoc
      # haskellPackages.pandoc-sidenote # broken in nixos-20.09
      haskellPackages.pandoc-crossref # broken in nixpkgs-unstable
      parallel
      pijul
      poppler_utils
      ripgrep
      runzip
      shellcheck
      tokei
      toolbox
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

      unstable.dejsonlz4
      unstable.youtube-dl
      unstable.gallery-dl
      unstable.clinfo
      unstable.stack
    ]
    ++ (
      if isNixOS
      then [ unstable.haskell.packages.ghc884.haskell-language-server ]
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

        export LEDGER_FILE="$HOME/sync/finance/$(date '+%Y').journal"

        alias p=pijul
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

        set-option -g set-titles on
        set-option -g set-titles-string "#S / #W"
      '';

      # https://github.com/NixOS/nixpkgs/issues/91185#issuecomment-647155143
      secureSocket = host != "ubuntu-container";
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };

  nixpkgs = {
    config = import ../nixpkgs/config.nix;
    overlays = [ (import ../nixpkgs/overlay.nix) ];
  };
  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs/config.nix;

  # We would like to use xdg.configFile here as well, but doing that will
  # break the relative imports inside the file, so we symlink it instead.
  # Note this implicitly assumes that the config directory exists at $HOME/config.
  #xdg.configFile."nixpkgs/overlays/overlay.nix".source = ../nixpkgs/overlay.nix;
  home.activation.linkOverlay = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/nixpkgs/overlays/
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG $HOME/config/nix-config/nixpkgs/overlay.nix \
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
    extraConfig = private.SSHConfig;
  };

  home.stateVersion = "20.03";
}
