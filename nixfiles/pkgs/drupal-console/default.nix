{ stdenv, fetchurl, php72Packages }:

stdenv.mkDerivation rec {
  name = "drupalconsole-${version}";
  version = "1.8.0";

  meta = with stdenv.lib; {
    description = "The Drupal CLI. A tool to generate boilerplate code, interact with and debug Drupal.";
    homepage    = http://drupalconsole.com/;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ mmai ];
    platforms   = platforms.all;
  };

  # buildInputs = [ php72Packages.box php72Packages.composer ];

  src = fetchurl {
    url    = https://drupalconsole.com/installer;
    sha256 = "1nilz6b5g1bm05nv9nlprzvhsqwhdpca7qq4a0yn6w2g7qyyz6qw";

    # url    = "https://github.com/hechoendrupal/drupal-console/archive/${version}.tar.gz";
    # sha256 = "0nj9yim8xwlvp8v0lx9scm8n1j3ymqbkv14jif1zljzmddp9q78n";
  };

  # disable unpack phase
  unpackPhase = ''
    ls
  '';
  installPhase = ''
    mkdir -p "$out/bin"
    cp $src "$out/bin/drupal"
    chmod a+x "$out/bin/drupal"
  '';
  # buildPhase = ''
  #   composer install
  #   box build
  #   '';
  # installPhase = ''
  #   mkdir -p "$out/bin"
  #   cp $src/drupal.phar "$out/bin/drupal"
  #   chmod a+x "$out/bin/drupal"
  # '';
}
