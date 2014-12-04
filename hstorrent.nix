{ haskellPackages ? (import <nixpkgs> {}).haskellPackages }:

let pkgs = import <nixpkgs> {}; in

haskellPackages.cabal.mkDerivation (self: {
  pname = "hstorrent";
  version = "0.1.0.0";
  src = pkgs.fetchgit {
    url = "git@github.com:hstorrent/hstorrent.git";
    sha256 = "a35099d1d65007d1b97fac2353aac876ed638a4c6d0aaeed1ecff8b2762426ee";
    rev = "3a8887aaeb7e6239685c0ad5fcf370156c840d25";
    fetchSubmodules = false;
  };
  buildDepends = with haskellPackages; [
    bencoding binary dataDefault lens QuickCheck quickcheckInstances
  ];
  testDepends = with haskellPackages; [
    bencoding binary dataDefault filepath hspec hspecContrib HUnit lens QuickCheck
    quickcheckInstances
  ];
  meta = {
    homepage = "https://github.com/hstorrent/hstorrent";
    description = "BitTorrent library in Haskell";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
