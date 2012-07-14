Tiny 'Nux Tarot
===============

Features
--------
* Basic tarot rules implemented, but special cases are missing
  ("poignee", "misere", "petit au bout", "garde sans")
* Four-player (human or IA) only, but it's the most interesting.
* Possibility to have multiple human players on the same
  computers. That's not really great because one player might see the
  hand of other ones, but well...  
* Very basic IA.
* Bugs?



Installation
------------
If you get the code from a release tarball, you'll probably just need
to do the usual:

    $ ./configure
    $ make
    # make install
    
Assuming you have Gtk+3.x, libgee and libvala.

If you get the code from the git repository, you'll also need a vala
compiler and the autotools, and to do the usual autotools mess before
you can do the steps above.

Running
-------
Simply typing:

    $ tnt
    
should launch the game. You can also specify the number of human
players (default:1) and the names of the players (default: Player
1...4). In this case, the first argument is the number of human
players, and the following ones replace the default names. E.g, you
want to play against 3 CPUs, but you want to be named and not "Player
1":

    $ tnt 1 Your_name
    
Or if you want to play with a friend, you can type:

    $ tnt 2 foo bar
    
Playing
-------
See the rules on Wikipedia: http://en.wikipedia.org/wiki/French_tarot

GUI is pretty basic: click on a card to play it or select/unselect it
for your dog. Click the "OK" button at the end of the turn. The
name of the player name who took is displayed in red (with skulls),
the name of the one who won the precedent turn is displayed in blue.

Contact
-------
liz.henry at ouvaton dot org
