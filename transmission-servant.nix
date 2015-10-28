{ mkDerivation, aeson, base, bencoding, bytestring, containers
, directory, filemanip, filepath, fsnotify, hstorrent, lens
, network-uri, process, stdenv
}:
mkDerivation {
  pname = "transmission-servant";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base bencoding bytestring containers directory filemanip
    filepath fsnotify hstorrent lens network-uri process
  ];
  description = "Sending torrents to the remote transmission client";
  license = stdenv.lib.licenses.mit;
}
