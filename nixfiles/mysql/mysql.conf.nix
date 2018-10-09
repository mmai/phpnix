{pkgs, mysqlDir, mysqlPort}:

pkgs.writeText "my.cnf" ''
    [mysqld]
    port=${mysqlPort}
    socket=${mysqlDir}/tmp/mysql.sock
    datadir=${mysqlDir}/data
    pid-file=${mysqlDir}/data/mysqld.pid
''
