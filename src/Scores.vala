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

/**
 * Callback for TreeViewColumn
 **/
private void data_func (Gtk.CellLayout layout, Gtk.CellRendererText renderer, Gtk.TreeModel model, Gtk.TreeIter iter)
{
	GLib.Value value;
	model.get_value (iter, 4, out value);
	string content = value.get_string ();
	int i = int.parse (content);
	renderer.foreground = "#000000";
	
	if (i == 1)
	{
		renderer.cell_background = "#CC93CD";
	}
	else
	{
		renderer.cell_background = "#FFFFFF";
	}
}

/**
 * This class allows to manages score and to display them in a table.
 **/
public class Scores:Gtk.TreeView
{
	private Gtk.ListStore store;
	private int nb_cols;
	private Gtk.TreeIter total;
	private weak Game game;
	private Gtk.Window window;

	/* Signal telling some data has been added */
	public signal void new_data ();

	public Scores (Game game)
	{
		this.game = game;
		nb_cols = game.nb_players;

		/* Sets store */
		GLib.Type[] types = new GLib.Type[nb_cols];
		foreach (GLib.Type t in types)
		{
			t = typeof (string);
		}
		//store = new Gtk.ListStore.newv (types);
		/* TODO: make varialbe list */
		store = new Gtk.ListStore (nb_cols + 1, typeof(string), typeof (string), typeof (string), typeof (string), typeof (string));
		assert (store != null);
		this.set_model (store);

		/* Add renderer and columns */
		Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
		renderer.set_sensitive (false);
		for (int i = 0; i < game.nb_players; i++)
		{
			Gtk.TreeViewColumn column = new Gtk.TreeViewColumn.with_attributes ("", renderer, "text", i);
			this.append_column (column);
			column.set_cell_data_func (renderer, (Gtk.CellLayoutDataFunc) data_func);
		}
		Gtk.TreeViewColumn invisible_column = new Gtk.TreeViewColumn.with_attributes ("Invisible anyway", renderer, "text", game.nb_players);
		invisible_column.set_visible (false);
		this.append_column (invisible_column);

		/* Add the total iter */
		store.append (out total);
		for (int i = 0; i < nb_cols; i++)
		{
			store.set (total, i, "0");
		}
		store.set (total, nb_cols, "1");
		this.set_sensitive (false);
		this.set_grid_lines (Gtk.TreeViewGridLines.BOTH);
	}

	/**
	 * Show / hide scores 
	 **/
	public void toggle_view ()
	{
		if (window != null)
		{
			if (window.visible)
			{
				window.hide ();
			}
			else
			{
				window.show_all ();
			}
		}
		else
		{
			window = new Gtk.Window ();
			window.set_title ("Scores");
			window.set_default_size (500, 500);
			var win = new Gtk.ScrolledWindow (null, null);
			win.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
			win.add (this);
			window.add (win);
			window.delete_event.connect (() =>
				{
					window.hide ();
					return true;
				});

			window.show_all ();
		}
	}

	/**
	 * Add the score from a game 
	 **/
	public void add_scores (int[] scores)
	{
		assert (scores.length == nb_cols);
		Gtk.TreeIter iter;
		store.insert_before (out iter, total);
		for (int i = 0; i < nb_cols; i++)
		{
			store.set (iter, i, scores[i].to_string ());
			store.set (total, i, game.players[i].score.to_string ());
		}
		store.set (iter, nb_cols, "0");
		store.set (total, nb_cols, "1");
		new_data ();
	}

	/**
	 * Refresh total scores and names
	 **/
	public void refresh ()
	{
		for (int i = 0; i < nb_cols; i++)
		{
			store.set (total, i, game.players[i].score.to_string ());
			get_column (i).set_title (game.players[i].name);
		}
	}

	/**
	 * Save scores (except total) to a file
	 **/
	public void save (GLib.FileStream stream)
	{
		Gtk.TreeModel model = this.get_model ();
		Gtk.TreeIter iter;
		model.get_iter_first (out iter);
		while (true)
		{
			GLib.Value value;
			model.get_value (iter, nb_cols, out value);
			if (value.get_string () == "1")
			{
				/* Stop when we get to the total scores */
				break;
			}
			else
			{
				for (int i = 0; i < nb_cols; i++)
				{
					GLib.Value this_score;
					model.get_value (iter, i, out this_score);
					stream.printf ("%s ", this_score.get_string ());
				}
				stream.printf ("\n");
			}
			if (model.iter_next (ref iter) == false)
			{
				break;
			}
		}
	}

	/**
	 * Loads score (except total) from a stream
	 **/
	public void load (GLib.FileStream stream)
	{
		int[] scores = new int[nb_cols];
		
		while (true)
		{
			for (int i = 0; i < nb_cols; i++)
			{
				int ret = stream.scanf ("%d ", out scores[i]);
				if (ret == 0)
				{
					return;
				}
					
			}
			this.add_scores (scores);
			stream.scanf ("\n");
			if (stream.eof ())
			{
				break;
			}
		}
	}
}