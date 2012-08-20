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
public static Tnt tnt;

/**
 * This class inherits Gtk.Application and lauches new games
 **/
public class Tnt:Gtk.Application
{

	private string[] names;
	private bool[] human = {true, false, false, false};
	public string file_name;
	private GLib.FileStream stream;
	public Game game;

	construct
	{
		names = new string[4];
		names[0] = GLib.Environment.get_real_name ();
		names[1] = _("Player 2");
		names[2] = _("Player 3");
		names[3] = _("Player 4");
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
			stdout.printf (_("Ooops: could not register application\n"));
			return;
		}
	}

	/**
	 * Method called when program is activated (e.g, runned)
	 * If there is a game to resume to, do it, else launch new game with default settings
	 **/
	public override void activate ()
	{
		if (this.stream != null)
		{
			this.resume_game (stream);
		}
		else
		{
			this.new_game ();
		}
	}

	/**
	 * Override the 'startup' signal of GLib.Application.
	 **/
	protected override void startup () {
		base.startup ();
		Gtk.Builder builder = new Gtk.Builder ();
		builder.set_translation_domain (Config.PACKAGE_NAME);
		try
		{
			builder.add_from_file (GLib.Path.build_filename (Config.PKGDATADIR, "/app_menu.ui", null));
			this.app_menu = builder.get_object ("app-menu") as GLib.MenuModel;

			var new_game = new SimpleAction ("new_game", null);
			new_game.activate.connect (() =>
				{
					this.new_game ();
				});
			this.add_action (new_game);
			
			var view_score = new SimpleAction ("scores", null);
			view_score.activate.connect (() =>
				{
					if (this.game != null)
					{
						this.game.scores.toggle_view ();
					}
				});
			this.add_action (view_score);
			
			var help = new SimpleAction ("help", null);
			help.activate.connect (() =>
				{
					unowned GLib.List<Gtk.Window> windows = this.get_windows ();
					try
					{
						Gtk.show_uri (windows.data.get_screen (), "help:tnt", Gdk.CURRENT_TIME);
					}
					catch (Error e)
					{
						stderr.printf (_("Could not open the help: %s"), e.message);
					}
				});
			this.add_action (help);
			

			var about_action = new SimpleAction ("about", null);
			about_action.activate.connect (() => 
				{
					About dialog = new About ();
					dialog.run ();
				});
			this.add_action (about_action);
			var quit_action = new SimpleAction ("quit", null);
			quit_action.activate.connect (() => {this.quit ();});
			this.add_action (quit_action);
		}
		catch (GLib.Error e)
		{
			stderr.printf (_("Error creating application menu: %s\n"), e.message);
		}
			
			
		}
		
		
		/**
	 * End a game, but don't quit the game
	 **/
	public void end_game ()
	{
		stdout.printf ("%d\n", (int) game.ref_count);
		this.game = null;
		this.stream = GLib.FileStream.open (file_name, "r");
	}

	/**
	 * Resumes a game 
	 **/
	private void resume_game (FileStream stream)
	{
		this.game = new Game ();
		this.game.file_to_save = file_name;
		this.game.load (stream);
		this.game.distribute ();
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
		
	public void new_game ()
	{
		Gtk.Dialog dialog = new Gtk.Dialog.with_buttons (_("New game"), null, Gtk.DialogFlags.DESTROY_WITH_PARENT, Gtk.Stock.OK, Gtk.ResponseType.ACCEPT, Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL, null);
		dialog.set_application (this);


		Gtk.Box box = dialog.get_content_area () as Gtk.Box;
		Gtk.Label label = new Gtk.Label (_("Players settings"));
		box.add (label);
		Gtk.Entry[] entries = new Gtk.Entry[4];
		Gtk.ToggleButton[] buttons = new Gtk.ToggleButton[4];
		for (int i = 0; i < 4 ; i++)
		{
			Gtk.HBox hbox = new Gtk.HBox (true, 10);
			Gtk.Label name_label = new Gtk.Label (_("Name: "));
			hbox.add (name_label);
			entries[i] = new Gtk.Entry ();
			entries[i].set_text (names[i]);
			hbox.add (entries[i]);
			buttons[i] = new Gtk.ToggleButton.with_label (_("Human"));
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

					if (this.game != null)
					{
						this.end_game ();
					}
					
					this.game = new Game ();
					this.game.file_to_save = file_name;
					this.game.init_players (names, human);
					this.game.distribute ();
				}
				else 
				{
					/* If cancel, do nothing most of the time, but if no game is running, quit the app */
					if (this.game == null)
					{
						this.quit ();
					}
				}
				dialog.destroy ();
				
			}); 

		box.show_all ();

		dialog.run ();
	}

	public static int main (string[] args)
	{
		Intl.bindtextdomain (Config.PACKAGE_NAME, Config.LOCALEDIR);
		Intl.bind_textdomain_codeset (Config.PACKAGE_NAME, "UTF-8");
		Intl.textdomain (Config.PACKAGE_NAME);
		tnt = new Tnt ();
		tnt.run (args);

		return 0;
	}
}