with import <nixpkgs> {};

pkgs.myEnvFun {
  name = "torrents-handler";
  buildInputs = with pkgs; [
    haskellPackages.ghc
    haskellPackages.networkUri
    haskellPackages.filemanip
    myHaskellPackages.hstorrent
  ];
}
