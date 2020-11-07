{ pkgs, ... }:
let
  unstable = import ../nixpkgs/unstable.nix;
in
{
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      emacs-all-the-icons-fonts
      ipafont
      ipaexfont
      latinmodern-math
      mplus-outline-fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      source-code-pro
      unstable.rictydiminished-with-firacode
      vistafonts
      source-han-code-jp
      yanone-kaffeesatz
    ];
    # c.f. https://functor.tokyo/blog/2018-10-01-japanese-on-nixos 
    fontconfig = {
      defaultFonts = {
        monospace = [
          "Noto Mono"
          "M+ 1mn"
          "IPAGothic"
          "Noto Emoji"
        ];
        serif = [
          "Noto Serif"
          "IPAPMincho"
          "Noto Emoji"
        ];
        sansSerif = [
          "Noto Sans"
          "IPAPGothic"
          "Noto Emoji"
        ];
      };
    };
  };
}
