{ mkDerivation, base, bencoding, binary, bytestring, criterion
, data-default, directory, fetchgit, filepath, hspec, hspec-contrib
, HUnit, lens, QuickCheck, quickcheck-instances, random, stdenv
}:
mkDerivation {
  pname = "hstorrent";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/hstorrent/hstorrent.git";
    sha256 = "16lbkgx4wy8l8a0g3ygsdyf8dh8h186df4yld21zgkrw4m9q4x4m";
    rev = "3a8887aaeb7e6239685c0ad5fcf370156c840d25";
  };
  libraryHaskellDepends = [
    base bencoding binary bytestring data-default lens QuickCheck
    quickcheck-instances
  ];
  testHaskellDepends = [
    base bencoding binary bytestring data-default directory filepath
    hspec hspec-contrib HUnit lens QuickCheck quickcheck-instances
  ];
  benchmarkHaskellDepends = [ base criterion random ];
  homepage = "https://github.com/hstorrent/hstorrent";
  description = "BitTorrent library in Haskell";
  license = stdenv.lib.licenses.bsd3;
}
