{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc7101" }:
nixpkgs.pkgs.haskell.packages.${compiler}.callPackage ./transmission-servant.nix {
  hstorrent = nixpkgs.pkgs.haskell.packages.${compiler}.callPackage ./hstorrent.nix { };
}
