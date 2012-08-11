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
 * This class displays the hand of the player, and allows to select which card to play.
 **/
public class GraphicalHand:Gtk.Frame
{
	public Hand hand {get; private set;}
	private int width = 500;
	private Gtk.Fixed fixed = null;

	public GraphicalHand (Hand hand)
	{
		this.hand = hand;
		this.size_allocate.connect ((allocation) => {this.width=allocation.width;});
		refresh ();
	}

	// public override void size_allocate (Gtk.Allocation allocation)
	// {
	// 	this.width = allocation.width;
	// 	stdout.printf ("%d\n", this.width);
	// }

	/**
	 * Refresh the display. Necessary if a new hand is given. 
	 **/
	public void refresh (Hand? new_hand = null)
	{
		if (new_hand != null)
			this.hand = new_hand;

		if (fixed != null)
		{
			fixed.destroy ();
		}
		fixed = new Gtk.Fixed ();
		this.add (fixed);

 		int x = 0;
		int y = 0;

		foreach (Card c in hand.list)
		{
			assert (c is GraphicalCard);
			GraphicalCard card = (GraphicalCard) c;

			var box = new Gtk.EventBox ();
			var image = card.get_image ();
			box.add (image);

			box.button_press_event.connect (() =>
				{
					card.select ();
					refresh ();
					return true;
				});
			if (card.is_selected)
			{
				y = 0;
			}
			else
			{
				y = 20;
			}
			
			fixed.put (box, x, y);
			x +=  (int) ((width - 50)/ this.hand.list.size);
		}

		this.show_all ();
	}
}