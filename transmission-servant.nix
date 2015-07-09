{ mkDerivation, aeson, base, bencoding, bytestring, containers
, directory, filemanip, filepath, fsnotify, hstorrent, lens
, network-uri, process, stdenv, system-filepath
}:
mkDerivation {
  pname = "transmission-servant";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [
    aeson base bencoding bytestring containers directory filemanip
    filepath fsnotify hstorrent lens network-uri process
    system-filepath
  ];
  description = "Sending torrents to the remote transmission client";
  license = stdenv.lib.licenses.mit;
}
