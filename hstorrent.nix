{ mkDerivation, base, bencoding, binary, bytestring, data-default
, directory, fetchgit, filepath, hspec, hspec-contrib, HUnit, lens
, QuickCheck, quickcheck-instances, stdenv
}:
mkDerivation {
  pname = "hstorrent";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/hstorrent/hstorrent";
    sha256 = "a35099d1d65007d1b97fac2353aac876ed638a4c6d0aaeed1ecff8b2762426ee";
    rev = "3a8887aaeb7e6239685c0ad5fcf370156c840d25";
  };
  buildDepends = [
    base bencoding binary bytestring data-default lens QuickCheck
    quickcheck-instances
  ];
  testDepends = [
    base bencoding binary bytestring data-default directory filepath
    hspec hspec-contrib HUnit lens QuickCheck quickcheck-instances
  ];
  homepage = "https://github.com/hstorrent/hstorrent";
  description = "BitTorrent library in Haskell";
  license = stdenv.lib.licenses.bsd3;
}
