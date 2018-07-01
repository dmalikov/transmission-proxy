{ mkDerivation, AttoBencode, attoparsec, base, bencode, bytestring
, containers, criterion, deepseq, fetchgit, ghc-prim, hspec
, integer-gmp, mtl, pretty, QuickCheck, stdenv, text
}:
mkDerivation {
  pname = "bencoding";
  version = "0.4.3.0";
  src = fetchgit {
    url = "https://github.com/dmalikov/bencoding";
    sha256 = "0qx4dh80cb44hsxrg1kryrqrvijx6dvypard9zliscdr6iishh4k";
    rev = "c1066e17be04f219dd84c372cf357a34f4c6724e";
  };
  libraryHaskellDepends = [
    attoparsec base bytestring deepseq ghc-prim integer-gmp mtl pretty
    text
  ];
  testHaskellDepends = [
    attoparsec base bytestring containers ghc-prim hspec QuickCheck
  ];
  benchmarkHaskellDepends = [
    AttoBencode attoparsec base bencode bytestring criterion deepseq
    ghc-prim
  ];
  homepage = "https://github.com/cobit/bencoding";
  description = "A library for encoding and decoding of BEncode data";
  license = stdenv.lib.licenses.bsd3;
}
