/***********************************************************************
    Copyright (C) 2012 Élisabeth Henry <liz.henry@ouvaton.org>

    This file is part of TnT.

    TnT is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published 
    by the Free Software Foundation; either version 2 of the License,
    or (at your option) any later version.

    TnT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of 
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License 
    along with this software; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307  USA.

***********************************************************************/

public static extern void exit (int status);

/**
 * This class inherits Gtk.Application and lauches new games
 **/
public class Tnt:Gtk.Application
{
	private Gtk.ApplicationWindow window;

	private string[] names;
	private bool[] human = {true, false, false, false};
	public string file_name;
	private GLib.FileStream stream;

	construct
	{
		names = new string[4];
		names[0] = GLib.Environment.get_real_name ();
		names[1] = "Player 2";
		names[2] = "Player 3";
		names[3] = "Player 4";
		file_name = GLib.Environment.get_home_dir () + "/.tnt";
		stream = GLib.FileStream.open (file_name, "r");

		this.set_application_id ("org.gtk.games.tnt");
		this.set_flags (GLib.ApplicationFlags.FLAGS_NONE);
		
		try
		{
			this.register ();
		}
		catch (GLib.Error e)
		{
			stdout.printf ("Ooops: could not register application\n");
			return;
		}
		window = null;
	}

	/**
	 * Method called when program is activated (e.g, runned)
	 **/
	public override void activate ()
	{
		if (window == null)
		{
			Gtk.MenuBar menu = get_tnt_menu ();
			window = new Gtk.ApplicationWindow (this);
			window.set_application (this);
			window.add (menu);
			window.destroy.connect (() => {this.quit ();});
			window.show_all ();
		}
	}

	/**
	 * Get the application-wide menu
	 **/
	public Gtk.MenuBar get_tnt_menu ()
	{
		Gtk.MenuBar menu = new Gtk.MenuBar ();

		Gtk.MenuItem game = new Gtk.MenuItem.with_label ("Game");
		menu.append (game);
		Gtk.Menu game_submenu = new Gtk.Menu ();
		game.set_submenu (game_submenu);
		Gtk.MenuItem resume_game = new Gtk.MenuItem.with_label ("Resume game");
		if (stream == null)
		{
			resume_game.set_sensitive (false);
		}
		else
		{
			resume_game.activate.connect (() =>
				{
					Game tnt_game = new Game ();
					tnt_game.file_to_save = file_name;
					tnt_game.load (stream);
					if (this.window != null)
					{
						this.window.hide ();
					}
					tnt_game.distribute ();
				});
		}
		game_submenu.append (resume_game);
				
		Gtk.MenuItem new_game = new Gtk.MenuItem.with_label ("New game");
		new_game.activate.connect (() =>
			{
				Game tnt_game = new Game ();
				tnt_game.file_to_save = file_name;
				tnt_game.init_players (names, human);
				if (this.window != null)
				{
					this.window.hide ();
				}
				tnt_game.distribute ();

			});
		game_submenu.append (new_game);
		Gtk.MenuItem preferences = new Gtk.MenuItem.with_label ("Preferences");
		preferences.activate.connect (() => {this.show_settings_dialog ();});
		game_submenu.append (preferences);
		
		Gtk.MenuItem help = new Gtk.MenuItem.with_label ("Help");
		menu.append (help);
		Gtk.Menu help_submenu = new Gtk.Menu ();
		help.set_submenu (help_submenu);
		Gtk.MenuItem about = new Gtk.MenuItem.with_label ("About");
		about.activate.connect (() => 
			{
				About dialog = new About ();
				dialog.run ();
			});
		help_submenu.append (about);
		
		return menu;
	}

	/**
	 * Just quit the program 
	 *
	 * TODO: oh-kay, there is some trouble: if I do *not* put override,
	 * the Vala compilater isn't very happy because Gtk.Application has
	 * this signal; but if I do put it, GCC is the one who isn't happy
	 * because it actually doesn't have it. WTF? (vala version:0.16.1)
	 **/
	public new void quit ()
	{
		exit (0);
	}

	public void show_settings_dialog ()
	{
		Gtk.Dialog dialog = new Gtk.Dialog.with_buttons ("Settings", null, Gtk.DialogFlags.DESTROY_WITH_PARENT, Gtk.Stock.OK, Gtk.ResponseType.ACCEPT, Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL, null);
		dialog.set_application (this);


		Gtk.Box box = dialog.get_content_area () as Gtk.Box;
		Gtk.Label label = new Gtk.Label ("Players settings");
		box.add (label);
		Gtk.Entry[] entries = new Gtk.Entry[4];
		Gtk.ToggleButton[] buttons = new Gtk.ToggleButton[4];
		for (int i = 0; i < 4 ; i++)
		{
			Gtk.HBox hbox = new Gtk.HBox (true, 10);
			Gtk.Label name_label = new Gtk.Label ("Name: ");
			hbox.add (name_label);
			entries[i] = new Gtk.Entry ();
			entries[i].set_text (names[i]);
			hbox.add (entries[i]);
			buttons[i] = new Gtk.ToggleButton.with_label ("Human");
			buttons[i].set_active (human[i]);
			hbox.add (buttons[i]);
			box.add (hbox);
		}
		dialog.response.connect ((response_id) => 
			{
				if (response_id == Gtk.ResponseType.ACCEPT)
				{
					for (int i = 0; i < 4; i++)
					{
						names[i] = entries[i].get_text ();
						human[i] = buttons[i].get_active ();
					}
				}
				dialog.destroy ();
			}); 

		box.show_all ();

		dialog.run ();
	}
}