{ nixpkgs ? import <nixpkgs> {}
, compiler ? "ghc822"
 }:
let nixpkgs' = nixpkgs;
in with nixpkgs'.pkgs;
let hp = haskell.packages.${compiler}.override{
    overrides = self: super: {
      bencoding = self.callPackage ./bencoding.nix {};
      hstorrent = self.callPackage ./hstorrent.nix {};
      transmission-proxy = self.callPackage ./transmission-proxy.nix {};
      };};
     getHaskellDeps = ps: path:
        let f = import path;
            gatherDeps = { buildDepends ? [], libraryHaskellDepends ? [], executableHaskellDepends ? [], libraryToolDepends ? [], executableToolDepends ? [], ...}:
               buildDepends ++ libraryHaskellDepends ++ executableHaskellDepends ++ libraryToolDepends ++ executableToolDepends ;
            x = f (builtins.intersectAttrs (builtins.functionArgs f) ps // {stdenv = stdenv; mkDerivation = gatherDeps;});
        in x;
ghc = hp.ghcWithPackages (ps: with ps; stdenv.lib.lists.subtractLists
[transmission-proxy]
([ cabal-install
bencoding hstorrent
  ]  ++ getHaskellDeps ps ./transmission-proxy.nix));
in
pkgs.stdenv.mkDerivation {
  name = "my-haskell-env-0";
  buildInputs = [ ghc ];
  shellHook = ''
 export LANG=en_US.UTF-8
 eval $(egrep ^export ${ghc}/bin/ghc)
'';
}
