Tiny 'Nux Tarot
===============

Warning
-------
It's great if you want to test this, but currently it's really a
pre-alpha version, so don't expect too much of either the software or
its documentation, right?

Features
--------
* Basic tarot rules implemented, but special cases are missing
  ("poignee", "misere", "petit au bout")
  
* Four-player (human or IA) only, but it's the most interesting.

* Possibility to have multiple human players on the same
  computers. That's not really great because one player might see the
  hand of other ones, but well...  
  
* Very limited IA: IA doesn't take, it can only defend.

* No internalization, but a mixture of "frenglish" (interface is
  supposed to be in english, but many tarot terms are only available
  in french, or so it seems)

* Bugs!



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

Using
-----
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
    
But actually you probably don't want to do that, since multi-player
mode means having one additional instance of the game and the same
computer and it's not really practical. 

Contact
-------
liz.henry at ouvaton dot org
