{ compiler }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = haskellPackagesNew: haskellPackagesOld: rec {
              bencoding = pkgs.haskell.lib.doJailbreak (haskellPackagesNew.callPackage ./bencoding.nix { });
              tp = haskellPackagesNew.callPackage ./default.nix { };
              hstorrent = pkgs.haskell.lib.doJailbreak (haskellPackagesNew.callPackage ./hstorrent.nix { });
              hspec-contrib = haskellPackagesNew.callPackage ./hspec-contrib.nix { };
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

