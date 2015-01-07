# transmission-servant

Simple script for sending huge amounts of torrent files to a remote transmission server with ability to set location directory according to a tracker name.

`transmission-servant` just watches given directory for a new torrent file, lookups for a directory name based on a tracker name and calls `transmission-remote` with a necessary `--download-dir` argument. Simple as that.

**Q**:* well wait, who cares about different directories for a different trackers?*  
**A**:* you cannot have one torrent pointing at 2 different trackers in transmission* 

## Usage

Create a `~/.servantrc` configuration file like:

```
{
  "baseDir":"<local dir to watch>",
  "transmission":{
    "host":"<server hostname or IP adress with transmission>",
    "downloadDirPrefix":"<directory prefix where data will be downloaded to>",
    "trackers":{
      "please.passthepopcorn.me":"ptp",
      "tracker.broadcasthe.net":"btn",
      "tracker.what.cd":"wcd",
      ...
    }
  }
}
```

Install and run it via `cabal install && transmission-servant`.

Better approach is to use isolated and clean `nix-shell`:
```
$> nix-shell -p '(haskellPackages.callPackage ./default.nix { haskellPackages = haskellPackages; })' --command 'transmission-servant'
```