let
  pkgs = import <nixpkgs> {};
  env = pkgs.haskellPackages.ghcWithPackagesOld (self: ( with self; [
    hlint
    hdevtools
    doctest ] ++
    (self.callPackage ./. { haskellPackages = pkgs.haskellPackages; }).nativeBuildInputs));
in
  pkgs.myEnvFun {
    name = "transmission-servant";
    shell = "/bin/zsh";
    buildInputs = [ pkgs.haskellPackages.cabalInstall env ];
    extraCmds = ''
      $(grep export ${env.outPath}/bin/ghc)
    '';
    }
