# PHP NIX

[Voir la version française](Readme.fr.md)

## Nginx + MariaDB + PHP development environment with Nix 

Configuration is defined in default.nix and nixfiles/. www/ and admin/ are websites examples.

### Installing  Nix

```
bash <(curl https://nixos.org/nix/install)
```

Add the last stable nix channel containing the packages we want

```
nix-channel --add https://nixos.org/channels/nixos-18.09 nixos
nix-channel --update
```

Note: installation put all files in the `/nix` folder, the rest of the system is not touched. Just remove this directory to completely uninstall the tool and installed packages.

### Usage

The following command activates the environment : `nix-shell`
You can then start the services (an instance of Nginx, PHP7, and MariaDB) with `startServices`

During the first run, nix will download all the dependencies and create the local configuration files, this may take a little while.

To stop the services: `make stop`, to restart them:` startServices`, to exit the environment: `exit`.

By default nginx listens on port 8080 and MariaDB on port 3307 to avoid conflicts with any services already launched on the machine (default 80 for apache/nginx and 3306 for mysql/mariadb); it is possible to modify these values by creating a file `nixfiles/config.nix` on the model of `nixfiles/config.dist.nix`

The MariaDB root password is set to `admin`.

Edit your `/etc/hosts` as follows:

```
127.0.0.1 admin.localhost website.localhost

```

Websites are visible at http://admin.localhost:8080 , http://website.localhost:8080 

It is possible to add other virtualhost sites by modifying `nixfiles/nginx/nginx.conf.nix`: just add a line according to the following template at the end of the file, just before the line `upstream phpfcgi {` :

    include ${makeVirtualHost { domain = "admin.localhost"; path = (rootDir + "/admin");}};

Nginx logs are in _nixfiles/nginx/logs/_

**Database administration with _adminer_ :**

Go to http://admin.localhost:8080/adminer.php and connect with the following elements (default configuration) : 

- System : Mysql
- Server : 127.0.0.1:3307
- Username : root
- Password : admin

