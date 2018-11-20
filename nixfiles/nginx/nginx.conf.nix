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
    access_log ${nginxDir}/logs/${domain}_access.log;
    error_log ${nginxDir}/logs/${domain}_error.log;

    location / {
      index index.php;
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

  }
    '';

  makeVirtualHostDrupal = { domain, path }:
    pkgs.writeText (domain + ".conf") ''
  server {
    listen ${nginxPort};
    listen [::]:${nginxPort};
    server_name ${domain};
    root ${path}/;
    access_log ${nginxDir}/logs/${domain}_access.log;
    error_log ${nginxDir}/logs/${domain}_error.log;

    location / {
        # try_files $uri @rewrite; # For Drupal <= 6
        try_files $uri /index.php?$query_string; # For Drupal >= 7
    }

    location @rewrite {
        rewrite ^/(.*)$ /index.php?q=$1;
    }

    # Don't allow direct access to PHP files in the vendor directory.
    location ~ /vendor/.*\.php$ {
        deny all;
        return 404;
    }

    # In Drupal 8, we must also match new paths where the '.php' appears in
    # the middle, such as update.php/selection. The rule we use is strict,
    # and only allows this pattern with the update.php front controller.
    # This allows legacy path aliases in the form of
    # blog/index.php/legacy-path to continue to route to Drupal nodes. If
    # you do not have any paths like that, then you might prefer to use a
    # laxer rule, such as:
    #   location ~ \.php(/|$) {
    # The laxer rule will continue to work if Drupal uses this new URL
    # pattern with front controllers other than update.php in a future
    # release.
    location ~ '\.php$|^/update.php' {
      fastcgi_pass phpfcgi;
      fastcgi_index index.php;
      include ${fastcgiParamsFile};
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_param DOCUMENT_ROOT $document_root;
    }

    # Fighting with Styles? This little gem is amazing.
    # location ~ ^/sites/.*/files/imagecache/ { # For Drupal <= 6
    location ~ ^/sites/.*/files/styles/ { # For Drupal >= 7
        try_files $uri @rewrite;
    }

    # Handle private files through Drupal. Private file's path can come
    # with a language prefix.
    location ~ ^(/[a-z\-]+)?/system/files/ { # For Drupal >= 7
        try_files $uri /index.php?$query_string;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        try_files $uri @rewrite;
        expires max;
        log_not_found off;
    }
  }
    '';
    
# virtualhost pour symfony 4
  makeVirtualHostSymfony = { domain, path }:
    pkgs.writeText (domain + ".conf") ''
  server {
    listen ${nginxPort};
    listen [::]:${nginxPort};
    server_name ${domain};
    root ${path}/;
    access_log ${nginxDir}/logs/${domain}_access.log;
    error_log ${nginxDir}/logs/${domain}_error.log;

    location / {
        # try to serve file directly, fallback to index.php
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {
      fastcgi_split_path_info ^(.+\.php)(/.*)$;
  # this links to the defined upstream in 'appendHttpConfig'
      fastcgi_pass phpfcgi;
      fastcgi_index index.php;
      include ${fastcgiParamsFile};
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_param DOCUMENT_ROOT $document_root;
    }

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

  access_log ${nginxDir}/logs/website_access.log;

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
    error_log ${nginxDir}/logs/website_error.log;

    location / {
      index index.html index.php;
    }

    location ~ (^/php/|\.php$) {
#      try_files $uri =404;
# this links to the defined upstream in 'appendHttpConfig'
      fastcgi_pass phpfcgi;
      fastcgi_index index.php;
      include ${fastcgiParamsFile};
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_param DOCUMENT_ROOT $document_root;

    }
  }

  include ${makeVirtualHost { domain = "admin.localhost"; path = (rootDir + "/admin");}};

  upstream phpfcgi {
    server unix:${phpDir}/run/phpfpm/nginx;
  }

}
''
