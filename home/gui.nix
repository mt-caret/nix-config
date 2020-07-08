{ host, config, pkgs, ... }:
let
  unstable = import ./unstable.nix;
  xmonad = pkgs.xmonad-with-packages.override {
    packages = self: [
      self.xmonad-contrib
      self.hostname
    ];
  };
  hidpi = host == "artemis" || host == "apollo";
in
{
  imports = [ ./vscode.nix ];
  home.packages = with pkgs; [
    anki
    arandr
    discord
    dragon-drop
    evince
    gimp
    gksu
    gparted
    libreoffice
    unoconv # cli tool, but depends on libreoffice
    mpv
    nmap-graphical
    obs-studio
    pavucontrol
    puddletag
    pdfpc
    signal-desktop
    thunderbird
    transmission-gtk
    vlc
    #(vlc.override { libbluray = libbluray.override {
    #  withAACS = true;
    #  withBDplus = true;
    #}; })
    #aacskeys # keys for Blu-ray
    wireshark
    xdotool
    xorg.xhost
    xsel
    xorg.xmessage
    xdg_utils
  ] ++ (
    with unstable; [
      # unstable-packages
      keepassxc
      torbrowser
      veracrypt
      slack
    ]
  );

  programs = {
    firefox.enable = true;
    chromium = {
      enable = true;
      extensions = [
        "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
        "dpaohcncbmkojcpcjaojcehdlnjfbjkl" # Pinboard
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
        "cgmnfnmlficgeijcalkgnnkigkefkbhd" # Strict Workflow
        "ophjlpahpchlmihnnnihgmmeilfjmjjc" # LINE
        "ldaamcmpjjabpmmopdjknbobifnkbhhd" # 社会人ブラウザ
      ];
    };
    alacritty = {
      enable = true;
      settings = import ./alacritty-settings.nix hidpi;
    };
  };

  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          font = "M+ 1mn 11";
          markup = "yes";
          plain_text = "no";
          format = "<b>%s</b>\n%b";
          sort = "yes";
          indicate_hidden = "yes";
          alignment = "center";
          word_wrap = "yes";
          stack_duplicates = "yes";
          geometry = "300x50-15+49";
          startup_notification = true;
          dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst";
          browser = "${pkgs.firefox}/bin/firefox -new-tab";
          frame_width = 3;
          frame_color = "#8EC07C";
        };
        shortcuts = {
          close = "mod4+x";
          close_all = "mod4+shift+x";
          history = "ctrl+grave";
          context = "ctrl+shift+period";
        };
        urgency_low = {
          frame_color = "#A1E2ED";
          foreground = "#A1E2ED";
          background = "#191311";
          timeout = 4;
        };
        urgency_normal = {
          frame_color = "#C1E89A";
          foreground = "#C1E89A";
          background = "#191311";
          timeout = 6;
        };
        urgency_critical = {
          frame_color = "#FFAD90";
          foreground = "#FFAD90";
          background = "#191311";
          timeout = 0;
        };
        play_sound = {
          summary = "*";
          script = "/home/delta/config/bin/notification-sound.sh";
        };
      };
    };
    network-manager-applet.enable = true;
    syncthing.tray = true;
    udiskie = {
      enable = true;
      tray = "always";
    };
  };

  xresources.properties =
    if host == "artemis" then { "Xft.dpi" = 163; } else
      if host == "apollo" then { "Xft.dpi" = 188; } else {};

  xsession = {
    enable = true;
    profileExtra =
      let
        trayerHeight =
          if host == "artemis" then 36 else
            if host == "apollo" then 42 else 30;
      in
        ''
          ${pkgs.xorg.xset}/bin/xset r rate 220 50
          light -S 0.2
          amixer -q sset Master 0%
          amixer -q sset Master mute

          case $(hostname) in
            artemis)
              xrandr \
                --output DVI-D-0 --mode 1920x1080 --pos 0x0 --rotate normal \
                --output HDMI-0 --off \
                --output DP-0 --off \
                --output DP-1 --off \
                --output DP-2 --off \
                --output DP-3 --off \
                --output DP-4 --primary --mode 3840x2160 --pos 1920x0 --rotate normal \
                --output DP-5 --off
              ;;
            *)
              echo unknown host
              ;;
          esac

          feh --bg-fill ~/sync/wallpapers/hit_the_floor_4k.png
          trayer \
            --edge top \
            --align right \
            --SetDockType true \
            --SetPartialStrut true \
            --expand true \
            --width 8 \
            --height ${builtins.toString trayerHeight} \
            --transparent true \
            --tint 0x000000 \
            --monitor primary \
            & disown
          xhost +local:
          [ -d /root-blank ] &&
            notify-send -u critical "opt-in state" "rollback failed"
        '';
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };
    windowManager.command = "${xmonad}/bin/xmonad";
  };
}
