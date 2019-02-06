start:
	startServices
stop:
	kill -QUIT $$( cat nixfiles/mysql/data/mysqld.pid )
	kill -QUIT $$( cat nixfiles/php/tmp/php-fpm.pid )
	kill -QUIT $$( cat nixfiles/nginx/logs/nginx.pid )
