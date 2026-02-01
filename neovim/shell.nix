{
  pkgs ? import <nixpkgs> {},
}:
let
  my-neovim = pkgs.callPackage ./neovim.nix {};
in
  pkgs.mkShell {
    nativeBuildInputs = [
      my-neovim
    ];
}
