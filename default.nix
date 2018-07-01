{ mkDerivation, aeson, base, base64-bytestring, bencoding
, bytestring, containers, directory, fast-logger, filemanip
, filepath, fsnotify, hstorrent, http-client, http-client-tls
, http-types, lens, network-uri, process, stdenv
}:
mkDerivation {
  pname = "transmission-proxy";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base base64-bytestring bencoding bytestring containers
    directory fast-logger filemanip filepath fsnotify hstorrent
    http-client http-client-tls http-types lens network-uri process
  ];
  description = "Sending torrents to the remote transmission client";
  license = stdenv.lib.licenses.mit;
}
