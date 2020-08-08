{ ... }:
let
  private = import ../../private/default.nix;
in
{
  programs.newsboat = {
    enable = true;
    autoReload = true;

    extraConfig = ''
      cache-file "~/sync/newsboat.db"

      # unbind keys
      unbind-key ENTER
      unbind-key j
      unbind-key k
      unbind-key J
      unbind-key K

      # bind keys - vim style
      bind-key j down
      bind-key k up
      bind-key l open
      bind-key h quit

      # podboat
      podcast-auto-enqueue yes
      player "vlc"
      download-path "/mnt/data0/podboat/"
    '';

    urls = private.rssFeeds;
  };
}
