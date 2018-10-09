{pkgs, nginxDir, rootDir, phpDir, nginxPort}:

let
  fastcgiParamsFile = pkgs.writeText "fastcgi_params" (builtins.readFile ./fastcgi_params);
  makeVirtualHost = { domain, path }:
    pkgs.writeText (domain + ".conf") ''
  server {
    listen ${nginxPort};
    listen [::]:${nginxPort};
    server_name ${domain};
    root ${path}/;

    location / {
      try_files $uri /app.php$is_args$args;
    }

    location ~ (^/php/|\.php$) {
      try_files $uri =404;
# this links to the defined upstream in 'appendHttpConfig'
      fastcgi_pass phpfcgi;
      fastcgi_index index.php;
      include ${fastcgiParamsFile};
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_param DOCUMENT_ROOT $document_root;

    }

    access_log ${nginxDir}/logs/${domain}_access.log;
    error_log ${nginxDir}/logs/${domain}_error.log;
  }
     '';

in

 pkgs.writeText "nginx.conf" ''
error_log stderr;
daemon on;
pid ${nginxDir}/logs/nginx.pid;

events {
}

http {
  include ${pkgs.writeText "mime.types" (builtins.readFile ./mime.types)};
  include ${pkgs.writeText "fastcgi.conf" (builtins.readFile ./fastcgi.conf)};

  access_log ${nginxDir}/logs/fifpl_access.log;

# optimisation
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 2048;

  ssl_protocols TLSv1.2;
  ssl_ciphers EECDH+aRSA+AESGCM:EDH+aRSA:EECDH+aRSA:+AES256:+AES128:+SHA1:!CAMELLIA:!SEED:!3DES:!DES:!RC4:!eNULL;

  ssl_session_cache shared:SSL:42m;
  ssl_session_timeout 23m;
  ssl_ecdh_curve secp384r1;
  ssl_prefer_server_ciphers on;
  ssl_stapling on;
  ssl_stapling_verify on;

  gzip on;
  gzip_disable "msie6";
  gzip_proxied any;
  gzip_comp_level 9;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

  proxy_set_header        Host $host;
  proxy_set_header        X-Real-IP $remote_addr;
  proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header        X-Forwarded-Proto $scheme;
  proxy_set_header        X-Forwarded-Host $host;
  proxy_set_header        X-Forwarded-Server $host;
  proxy_set_header        Accept-Encoding "";

  proxy_redirect          off;
  proxy_connect_timeout   90;
  proxy_send_timeout      90;
  proxy_read_timeout      90;
  proxy_http_version      1.0;

  client_max_body_size 10m;
  server_tokens off;


  server {
    listen ${nginxPort};
    listen [::]:${nginxPort};

    server_name website.localhost;
    root ${rootDir}/www/;

    location / {
      index index.html index.php;
    }

    location ~ (^/php/|\.php$) {
      try_files $uri =404;
# this links to the defined upstream in 'appendHttpConfig'
      fastcgi_pass phpfcgi;
      fastcgi_index index.php;
      include ${fastcgiParamsFile};
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_param DOCUMENT_ROOT $document_root;

    }
    error_log ${nginxDir}/logs/website_error.log;
  }

  include ${makeVirtualHost { domain = "admin.localhost"; path = (rootDir + "/admin");}};

  upstream phpfcgi {
    server unix:${phpDir}/run/phpfpm/nginx;
  }

}
''
