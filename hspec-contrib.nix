{ mkDerivation, base, hspec, hspec-core, HUnit, QuickCheck, stdenv
}:
mkDerivation {
  pname = "hspec-contrib";
  version = "0.5.0";
  sha256 = "dba7348e75572f7cd79f3f0719ab39973431927f9bb5bec1445e2f8e5b4fa78c";
  libraryHaskellDepends = [ base hspec-core HUnit ];
  testHaskellDepends = [ base hspec hspec-core HUnit QuickCheck ];
  homepage = "http://hspec.github.io/";
  description = "Contributed functionality for Hspec";
  license = stdenv.lib.licenses.mit;
}
