{ compiler ? "ghc822" }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = haskellPackagesNew: haskellPackagesOld: rec {
              # optparse-applicative =
              #   pkgs.haskell.lib.addBuildDepend
              #     (haskellPackagesNew.callPackage ./optparse-applicative-2.nix { })
              #     haskellPackagesNew.semigroups;

              transmission-proxy = haskellPackagesNew.callPackage .styx/transmission-proxy.nix { };
              bencoding = haskellPackagesNew.callPackage .styx/bencoding.nix { };
              hstorrent = haskellPackagesNew.callPackage .styx/hstorrent.nix { };
            };
          };
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };

in
  { transmission-proxy = pkgs.haskell.packages.${compiler}.transmission-proxy;
  }
