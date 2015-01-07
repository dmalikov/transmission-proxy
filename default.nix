{ haskellPackages ? (import <nixpkgs> {}).haskellPackages }:

let hstorrent = import ./hstorrent.nix {}; in

haskellPackages.cabal.mkDerivation (self: {
  pname = "transmission-servant";
  version = "0.1.0.0";
  src = builtins.filterSource (_: type: type != "unknown") ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = with haskellPackages; [ aeson bencoding hstorrent filemanip filepath fsnotify lens networkUri systemFilepath ];
  meta = {
    description = "Script watching given directory for a torrents and sending them to remote transmission client";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
  };
})
