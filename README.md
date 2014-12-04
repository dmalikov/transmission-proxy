Usage

```
$> nix-shell -p '(haskellPackages.callPackage ./default.nix { haskellPackages = haskellPackages; })' --command 'transmission-servant'
```
