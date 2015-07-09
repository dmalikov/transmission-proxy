{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc7101" }: let
  inherit (nixpkgs) pkgs;
  h = pkgs.haskell.packages.${compiler};
  ghc = h.ghcWithPackages(ps: [
    ps.hdevtools ps.stylish-haskell ps.hasktags
  ]);
  hdevtools = pkgs.haskell.packages.${compiler}.callPackage ./hdevtools.nix { };
  pkg = (import ./default.nix { inherit nixpkgs compiler; });
in
  pkgs.stdenv.mkDerivation rec {
    name = pkg.pname;
    buildInputs = [ ghc h.cabal-install hdevtools ] ++ pkg.env.buildInputs;
    shellHook = ''
      ${pkg.env.shellHook}
      export IN_WHICH_NIX_SHELL=${name}
      cabal configure --package-db=$NIX_GHC_LIBDIR/package.conf.d
    '';
  }
