% Tiny 'Nux Tarot

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

# Dépendances #

Pour pouvoir être lancé, Tiny 'Nux Tarot a besoin des bibliothèques
suivantes :

* libgtk-3.0 (>= 3.4)
* libgee2

Si vous voulez le compiler, vous aurez également besoin des outils
habituels pour cela, comme gcc et make.

# Installation depuis un paquet #

Currently, Tiny 'Nux Tarot is not available in distribution repositories,
but I try to make Debian packages and would gladfully host other
packages. If you are under Debian, you can look at the [download
page](http://tnt.ouvaton.org/dl/) and see if there is a package that
fits your architecture.

# Installing from a source tarball #

The simplest way is to download the code from the [latest tarball](http://tnt.ouvaton.org/dl/tnt-latest.tar.bz2), and
to run the usual:

    $ tar xjf tnt-latest.tar.bz2
    $ cd tnt-0.3
    $ ./configure
    $ make
    $ sudo make install

Note: as Vala source files are already precompiled in C, you won't need a
Vala compiler in order to achieve this.

If everything goes well, all you have to do now is launch `tnt`, either
by the command line or from the menu. 

# Downloading the latest version #

If you want the latest version, you can use `git' to download the sources:

    git://github.com/lady-segfault/tnt.git

In this case, you will additionally need the Vala compiler and yelp-tools.

Usage
-----
Simply typing:

    $ tnt
    
should launch a new game if you just installed it, or resume your
previous game if you already played (only the scores are saved at the
end of each game, though).
    
Playing
-------
See the [rules on Wikipedia](http://en.wikipedia.org/wiki/French_tarot)

GUI is pretty basic: click on a card to play it or select/unselect it
for your dog. Click the "OK" button at the end of the turn. The
name of the player name who took is displayed in red (with skulls),
the name of the one who won the precedent turn is displayed in
blue. Some messages also appear at the right to give you some
information about who distributes or what are the bids and scores.

Contact
-------
liz.henry at ouvaton dot org
