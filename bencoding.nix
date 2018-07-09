{ mkDerivation, AttoBencode, attoparsec, base, bencode, bytestring
, containers, criterion, deepseq, fetchgit, ghc-prim, hspec
, integer-gmp, mtl, pretty, QuickCheck, stdenv, text
}:
mkDerivation {
  pname = "bencoding";
  version = "0.4.3.0";
  src = fetchgit {
    url = "https://github.com/dmalikov/bencoding";
    sha256 = "1hps8k2g98yljfckw9s9xwwykmbq3jh1i1whdwzv34cxkid1rzc4";
    rev = "59b6159d964d395c2992882b2e249f330655bd41";
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
