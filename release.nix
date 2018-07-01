{ compiler ? "ghc822" }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = haskellPackagesNew: haskellPackagesOld: rec {
              bencoding = haskellPackagesNew.callPackage ./bencoding.nix { };
              tp = haskellPackagesNew.callPackage ./default.nix { };
              hstorrent = haskellPackagesNew.callPackage ./hstorrent.nix { };
            };
          };
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };

in
  { project = pkgs.haskell.packages.${compiler}.tp;
  }
