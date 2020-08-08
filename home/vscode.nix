{ pkgs, ... }:
let
  ionide-fsharp = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "Ionide-fsharp";
      publisher = "Ionide";
      version = "4.14.0";
      sha256 = "0xdlknjmgn770pzpbw00gdqln9kkyksqnm1g9fcnrmclyhs639z4";
    };
    meta.license = pkgs.stdenv.lib.licenses.mit;
  };
in
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ionide-fsharp
    ];
  };
}
