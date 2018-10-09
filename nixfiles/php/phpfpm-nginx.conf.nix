{pkgs, phpDir}:

pkgs.writeText "phpfpm-nginx.conf" ''
[global]
error_log = syslog
daemonize = true
pid = ${phpDir}/tmp/php-fpm.pid

[nginx]
listen = ${phpDir}/run/phpfpm/nginx
request_terminate_timeout = 300
pm = dynamic
pm.max_children = 20 
pm.start_servers = 3 
pm.min_spare_servers = 2
pm.max_spare_servers = 10
pm.max_requests = 50
''
