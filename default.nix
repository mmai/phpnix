with import <nixpkgs> { };

# XXX Actuellement en php 7.1 pour bénéficier de xdebug
# pour rétablir 7.0 comme en prod : utiliser la ligne suivante pour lancer php-fpm : 
# ${pkgs.php70}/bin/php-fpm -p ${phpDir} -y ${phpConf} -c ${phpIni}

let
  cfg =
    if builtins.pathExists ./nixfiles/config.nix
    then import ./nixfiles/config.nix 
    else {  # default configuration
      nginxPort = "8080";
      mysqlPort = "3307";
    };

  rootDir   = toString ./.;
  nginxDir  = "${rootDir}/nixfiles/nginx";
  phpDir    = "${rootDir}/nixfiles/php";
  mysqlDir  = "${rootDir}/nixfiles/mysql";

  mysqlConf     = (import ./nixfiles/mysql/mysql.conf.nix) {inherit pkgs mysqlDir; mysqlPort                = cfg.mysqlPort; };
  php71-env-cli = (import ./nixfiles/php/php71-env-cli.nix) {inherit pkgs stdenv phpIni; };
  phpConf       = (import ./nixfiles/php/phpfpm-nginx.conf.nix) {inherit pkgs phpDir ;};
  phpIni        = (import ./nixfiles/php/phpini.nix) {inherit pkgs ;};
  nginxConf     = (import ./nixfiles/nginx/nginx.conf.nix) {inherit pkgs nginxDir rootDir phpDir; nginxPort = cfg.nginxPort; };
in

stdenv.mkDerivation rec {
  name = "mywebapp-${version}";
  version = "0.1.0";
  buildInputs = (with pkgs; [ phpPackages.composer nginx mysql ]) ++ [ php71-env-cli ]; 

  shellHook = ''
    function startServices {
      if test -f ${nginxDir}/logs/nginx.pid && ps -p $(cat ${nginxDir}/logs/nginx.pid) > /dev/null; then
        echo "NGINX already started"
      else
        echo "==============   Starting nginx..."
        ${pkgs.nginx}/bin/nginx -p ${nginxDir}/tmp  -c ${nginxConf}
      fi

      if test -f ${phpDir}/tmp/php-fpm.pid && ps -p $(cat ${phpDir}/tmp/php-fpm.pid) > /dev/null; then
        echo "PHP-FPM already started"
      else
        echo "==============   Starting phpfpm..."
        ${pkgs.php71}/bin/php-fpm -p ${phpDir} -y ${phpConf} -c ${phpIni}
      fi

      if test -f ${mysqlDir}/data/mysqld.pid && ps -p $(cat ${mysqlDir}/data/mysqld.pid) > /dev/null; then
        echo "Mysql already started"
      else
        echo "==============   Starting mysql..."
        echo "pour activer logs mysql:"
        echo "start-stop-daemon --stop --pidfile nixfiles/mysql/data/mysqld.pid"
        echo "${pkgs.mysql}/bin/mysqld --defaults-extra-file=${mysqlConf} --general_log=1 --general_log_file=${mysqlDir}/tmp/requests.log &)"
        echo ""
        echo ""
        test -e ${mysqlDir}/data/mysql || ${pkgs.mysql}/bin/mysql_install_db --basedir=${pkgs.mysql} --datadir=${mysqlDir}/data 
        ${pkgs.mysql}/bin/mysqld --defaults-extra-file=${mysqlConf} &
      fi
    }
    startServices
  '';

}
