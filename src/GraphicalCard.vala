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
 * This class manages the display and all Gtk stuff to manipulate a card.
 **/
public class GraphicalCard:Card
{
	public bool is_selected {get; set;}
	private string image_file;

	public signal void select ();

	public GraphicalCard (Colour colour, int rank)
	{
		GLib.Object (colour: colour, rank: rank);
	}

	public GraphicalCard.from_string (string str)
	{
		Colour _colour;
		int _rank;
		str.scanf ("%d, %d", out _rank, out _colour);
	    GLib.Object (colour: _colour, rank: _rank);
	}

	
	construct
	{
		this.is_selected = false;
		
		/* Set image_file */
		if (colour==Colour.CLUB)
		{
			this.image_file = (rank-1).to_string ();
			if (rank-1 < 10)
			{
				image_file = "0" + image_file;
			}
		}
		else if (colour == Colour.SPADE)
		{
			image_file = (rank+13).to_string ();
		}
		else if (colour == Colour.HEART)
		{
			image_file = (rank+27).to_string ();
		}
		else if (colour == Colour.DIAMOND)
		{
			image_file = (rank+41).to_string ();
		}
		else if (colour == Colour.TRUMP)
		{
			if (rank == 0)
				image_file = "77";
			else
				image_file = (rank+55).to_string ();
		}
		image_file = "cards_marseille/"+image_file+".png";
	}

	/**
	 * Return a (new) pixbuf displaying the card.
	 **/
	public Gdk.Pixbuf get_pixbuf ()
	{
		Gdk.Pixbuf pixbuf = null;
		/* Try to load the pixbuf; first from Config.PKGDATADIR, then from local dir (if TnT is not installed) */
		try {
			pixbuf = new Gdk.Pixbuf.from_file (Config.PKGDATADIR + "/" + image_file);
		}
		catch (GLib.Error e)
		{
			try {
				pixbuf = new Gdk.Pixbuf.from_file ("data/" + image_file);
			}
			catch (GLib.Error error)
			{
				stderr.printf (_("Error: could not open card picture.\n"));
				stderr.printf ("%s\n", error.message);
				tnt.quit ();
			}
		}
		return pixbuf;
	}

	/**
	 * Return a (new) Gtk.Image displaying the card
	 **/
	public Gtk.Image get_image ()
	{
		Gtk.Image image = new Gtk.Image ();
		image.set_from_pixbuf (this.get_pixbuf ());
		return image;		
	}

	public void switch_selected ()
	{
		this.is_selected = !this.is_selected;
	}
	
}