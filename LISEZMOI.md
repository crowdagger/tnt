Tiny 'Nux Tarot
===============

À propos
--------
Tiny 'Nux Tarot (TnT) est un jeu de tarot. Sa fonctionnalité principale est de permettre de jouer aux tarots même lorsque vous n'avez pas d'ami-e-s sous la main. La dernière version est la 0.3.

TnT est écrit en Vala, utilise la bibliothèque Gtk+, et est publié sous la licence GNU GPL.

Fonctionnalités
---------------
* Jeu à quatre
* Les règles basiques du tarot sont implémentées, mais certains cas
particuliers ne sont pas pris en charge ("poignée", "misere", "petit au bout").
* Possiblité de jouer à plusieurs humains sur le même ordinateur, même
  si ce n'est pas très utile.

Screenshots
-----------
![Version 0.3 (en français)](http://tnt.ouvaton.org/screenshots/0.3/gnome-shell.png)

Installation
------------

### Dépendances ###

Pour pouvoir être lancé, Tiny 'Nux Tarot a besoin des bibliothèques
suivantes :

* libgtk-3.0 (>= 3.4)
* libgee2

Si vous voulez le compiler, vous aurez également besoin des outils
habituels pour cela, comme gcc et make.

### Installation depuis un paquet ###

Actuellement, Tiny 'Nux Tarot n'est pas disponible dans les archives
des distributions, mais je suis en train d'essayer de faire des
paquets Debian (et serais heureuse d'accueillir des paquets pour
d'autres distributions). Si vous êtes sous Debian, vous pouvez
regarder la [page de téléchargements](http://tnt.ouvaton.org/dl/) et
voir s'il y a un paquet qui correspond à votre architecture.

### Installer depuis les sources (tarball) ###

Le plus simple est de télécharger la
[dernière tarball](http://tnt.ouvaton.org/dl/tnt-latest.tar.bz2), et
de faire les habituels :

    $ tar xjf tnt-latest.tar.bz2
    $ cd tnt-0.3
    $ ./configure
    $ make
    $ sudo make install

Remarque: comme les fichiers sources Vala sont déjà précompilés en C,
vous n'avez pas besoin du compilateur Vala, juste de Gcc.

Si tout va bien, vous pouvez maintenant lancer `tnt`, soit par ligne
de commande, soit par le menu.

### Compiler la dernière version ###

Vous pouvez utiliser `git' pour télécharger les dernière sources :

    git://github.com/lady-segfault/tnt.git

Dans ce cas, vous aurez également besoin du compilateur Vala et de yelp-tools.

Utilisation
-----------
Au lancement, Tiny 'Nux Tarot vous propose de lancer une nouvelle
partie si vous venez de l'installer, ou reprend automatiquement un jeu
existant si vous avez déjà joué (seuls les scores sont sauvés, à la
fin de chaque partie).
    
Jeu
---
L'interface graphique est assez basique : cliquer sur une carte permet
de la jouer ou de la choisir pour le chien. Cliquez aussi sur le
bouton "OK" à la fin du tour. Le nom du joueur qui a pris est indiqué
en rouge (avec des têtes de mort), le nom de celle qui a commencé le
tour est affiché en bleu. Des messages apparaissent aussi à droite de
l'écran pour vous donner quelques informations sur qui distribuet ou
quels sont les enchères et les scores.

Contact
-------
liz.henry at ouvaton dot org
