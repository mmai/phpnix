{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "drush-launcher-${version}";
  version = "0.6.0";

  meta = with stdenv.lib; {
    description = "A small wrapper around Drush for your global $PATH.";
    homepage    = https://github.com/drush-ops/drush-launcher;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ mmai ];
    platforms   = platforms.all;
  };

  src = fetchurl {
    url    = https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar;
    sha256 = "0kix7wgxr1mnx77ywcc1gw45rvs9kv273k8h005lf61g1a02mwy3";
  };

  # disable unpack phase
  unpackPhase = ''
    ls
  '';
  installPhase = ''
    mkdir -p "$out/bin"
    cp $src "$out/bin/drush"
    chmod a+x "$out/bin/drush"
  '';
}
