using Gtk;

int main (string[] args)
{
	Gtk.init (ref args);

	Game game = new Game ();
	game.init_players (args);
	game.distribute ();

    Gtk.main ();
    return 0;
}
