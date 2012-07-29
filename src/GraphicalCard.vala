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
	public string image_file {get; private set;}
	public bool is_selected {get; set;}

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
		stdout.printf ("%d, %d\n", _colour, _rank);
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
		image_file = Config.PKGDATADIR+"/cards/"+image_file+".png";	
	}

	public void switch_selected ()
	{
		this.is_selected = !this.is_selected;
	}
	
}