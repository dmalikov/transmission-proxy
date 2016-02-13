{ nixpkgs ? import <nixpkgs> {}
, compiler ? "ghc7103"
} :

nixpkgs.pkgs.haskell.packages.${compiler}.callPackage ./transmission-servant.nix {
  hstorrent = nixpkgs.pkgs.haskell.packages.${compiler}.callPackage ./hstorrent.nix { };
}
