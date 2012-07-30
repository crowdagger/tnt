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
void synthethic_data_func (Gtk.CellLayout layout, Gtk.CellRendererText renderer, Gtk.TreeModel model, Gtk.TreeIter iter)
{
	renderer.foreground = "#000000";
	renderer.cell_background = "#FFFFFF";
}



/**
 * Displays a synthetic score table 
 **/
public class SynthethicScore:Gtk.TreeView
{
	private Gtk.ListStore store;
	private int nb_cols;
	private Gtk.TreeIter[] iters;
	public weak Game game {get; construct set;}

	public SynthethicScore (Game game)
	{
		GLib.Object (game:game);
	}

	construct
	{
		nb_cols = 2;
		/* Sets store */
		store = new Gtk.ListStore (nb_cols, typeof (string), typeof (int));
		assert (store != null);
		this.set_model (store);

		/* Add renderer and columns */
		Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
		Gtk.TreeViewColumn names = new Gtk.TreeViewColumn.with_attributes ("Names", renderer, "text", 0);
		Gtk.TreeViewColumn scores = new Gtk.TreeViewColumn.with_attributes ("Scores", renderer, "text", 1);
		this.append_column (names);
		this.append_column (scores);
		this.set_sensitive (false);
		names.set_cell_data_func (renderer, (Gtk.CellLayoutDataFunc) synthethic_data_func);
		scores.set_cell_data_func (renderer, (Gtk.CellLayoutDataFunc) synthethic_data_func);

		iters = new Gtk.TreeIter[game.nb_players];
		for (int i = 0; i < game.nb_players; i++)
		{
			store.append (out iters[i]);
		}
		this.refresh ();

		store.set_sort_column_id (1, Gtk.SortType.DESCENDING);
	}

	/**
	 * Refresh the scores 
	 **/
	public void refresh ()
	{
		for (int i = 0; i < game.nb_players; i++)
		{
			store.set (iters[i], 0, game.players[i].name);
			store.set (iters[i], 1, game.players[i].score);
		}
	}
}