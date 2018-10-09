start:
	startServices
stop:
	start-stop-daemon --stop --pidfile nixfiles/mysql/data/mysqld.pid
	start-stop-daemon --stop --pidfile nixfiles/php/tmp/php-fpm.pid
	kill -QUIT $$( cat nixfiles/nginx/logs/nginx.pid )
