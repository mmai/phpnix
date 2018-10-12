# PHP NIX

## Environnement de développement PHP Mysql avec Nix (pour linux et mac)

La configuration de l'environnement de développement est définie dans default.nix et nixfiles/.

### Installer l'outil Nix 

```
bash <(curl https://nixos.org/nix/install)
```

Ajout du dernier repo stable contenant les paquets voulus

```
nix-channel --add https://nixos.org/channels/nixos-18.09 nixos
nix-channel --update
```

Note: l'installation se fait dans le répertoire `/nix`, le reste du système n'est pas touché. Il suffit de supprimer ce répertoire pour désinstaller complètement l'outil et les paquets installés.

### Utilisation

La commande suivante permet d'activer l'environnement et de lancer les serveurs (une instance de Nginx,  PHP7 et MySQL): `nix-shell`

Lors de la première exécution, nix va télécharger toutes les dépendances et créer les fichiers de configuration locaux, cela peut prendre un peu de temps.

Pour stopper les services : `make stop`, pour les relancer : `startServices`, pour sortir de l'environnement : `exit`.

Par défaut nginx écoute sur le port 8080 et MySQL sur le port 3307 pour éviter les conflits avec d'éventuels services déjà lancés sur la machine (par défaut 80 pour apache/nginx et 3306 pour mysql) ; il est possible de modifier ces valeurs en créant un fichier `nixfiles/config.nix`  sur le modèle de `nixfiles/config.dist.nix`


Modifiez votre `/etc/hosts` de la façon suivante :
```
127.0.0.1 admin.localhost website.localhost

```

Il est possible d'ajouter d'autre sites virtualhost en modifiant `niwfiles/nginx/nginx.conf.nix` : il suffit d'ajouter une ligne selon le modèle suivant en fin de fichier, juste avant la ligne  `upstream phpfcgi {` :

    include ${makeVirtualHost { domain = "admin.localhost"; path = (rootDir + "/admin");}};

Les sites seront accessibles sur http://admin.localhost:8080 , http://website.localhost:8080 

Leurs logs nginx sont dans _nixfiles/nginx/logs/_

