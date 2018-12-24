[![Build Status](http://img.shields.io/travis/dmalikov/transmission-proxy/master.svg?style=flat-square)](http://travis-ci.org/dmalikov/transmission-proxy)

# transmission-proxy

Simple script for sending torrent files to a remote transmission server with ability to set location directory according to a tracker name.

`transmission-proxy` just watches given directory for a new torrent file, lookups for a directory name based on a tracker name and calls `transmission-remote` with a necessary `--download-dir` argument.

Yep, just that. Nothing more.

## Usage

Create a `~/.transmission.proxy.rc` configuration file like:

```
{
  "baseDir":"<local dir to watch>",
  "transmission":{
    "host":"<server hostname or IP adress with transmission>",
    "downloadDirPrefix":"<directory prefix where data will be downloaded to>",
    "auth":{
      "username":"<username if needed>",
      "password":"<password if needed>"
    },
    "trackers":{
      "please.passthepopcorn.me":"ptp",
      "tracker.broadcasthe.net":"btn",
      "tracker.what.cd":"wcd",
      ...
    }
  }
}
```

```
$> stack exec transmission-proxy
```
