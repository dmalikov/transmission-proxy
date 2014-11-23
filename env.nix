let
  pkgs = import <nixpkgs> {};
  env = pkgs.haskellPackages.ghcWithPackagesOld (hsPkgs: ( with hsPkgs; [
    hlint
    hdevtools
    doctest ] ++
    (hsPkgs.callPackage ./. { haskellPackages = hsPkgs; }).nativeBuildInputs));
in
  pkgs.myEnvFun {
    name = "transmission-watcher";
    shell = "/bin/zsh";
    buildInputs = [ pkgs.haskellPackages.cabalInstall env ];
    extraCmds = ''
      $(grep export ${env.outPath}/bin/ghc)
    '';
    }
