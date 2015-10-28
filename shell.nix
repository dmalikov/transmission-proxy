{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc7102" }: let
  inherit (nixpkgs) pkgs;
  h = pkgs.haskell.packages.${compiler};
  ghc = h.ghcWithPackages(ps: [
    ps.stylish-haskell ps.hasktags ps.cabal2nix
  ]);
  hdevtools = pkgs.haskell.packages.${compiler}.callPackage ./hdevtools.nix { };
  pkg = (import ./default.nix { inherit nixpkgs compiler; });
in
  pkgs.stdenv.mkDerivation rec {
    name = pkg.pname;
    buildInputs = [ ghc h.cabal-install hdevtools pkgs.darwin.apple_sdk.frameworks.Cocoa ] ++ pkg.env.buildInputs;
    shellHook = ''
      ${pkg.env.shellHook}
      export IN_WHICH_NIX_SHELL=${name}
      cabal configure --package-db=$NIX_GHC_LIBDIR/package.conf.d
    '';
  }
