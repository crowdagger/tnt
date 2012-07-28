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
   Class managing a single tarot card 
**/
public class Card:GLib.Object 
{
	public int rank { get; set construct;} 	/* The rank (1-13 for colour, 0-21 for trumps) of a card */
	public Colour colour {get; set construct;} /* The colour of a card */
	public double value {get; private set;} /* The value of a card, ie. the points it allows to earn */

	/* Return the name of the card */
	public string get_label ()
	{
		if (colour != Colour.TRUMP)
		{
			string str_rank;
			switch (rank)
			{
			case 14:
				str_rank = "roi";
				break;
			case 13:
				str_rank = "dame";
				break;
			case 12:
				str_rank = "cavalier";
				break;
			case 11:
				str_rank = "valet";
				break;
			case 1:
				str_rank = "as";
				break;
			default:
				str_rank = rank.to_string ();
				break;
			}
			return str_rank + " de " + colour.to_string();
		}
		else
		{
			switch (rank)
			{
			case 0:
				return "excuse";
			case 1:
				return "petit";
			case 21:
				return "21";
			default:
				return rank.to_string () + " d'" + colour.to_string ();
			}
		}
	}

	/* Return true if the card is an oudler (excuse, petit or the 21),
	   false else */ 
	public bool is_oudler ()
	{
		if (colour == Colour.TRUMP && (rank == 0 || rank == 1 || rank == 21))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/* Return true if this card can defeat the other one.
	   Not usable for sorting cards, only to determine whether
	   this card might win in this specific case or not */
	public bool is_better_than (Card card)
	{
		/* Handle the excuse case */
		if (this.rank == 0)
			return false;
		if (card.rank == 0)
			return true;
		
		/* If it's the same colour, our card must be stronger */
		if (this.colour == card.colour)
		{
			return this.rank > card.rank;
		}
		/* The only case where we can win with a lower rank is if we cut */
		else if (this.colour == Colour.TRUMP)
		{
			return true;
		}
		else 
		{
			return false;
		}
	}
	
	public Card (Colour colour, int rank)
	{
		this.rank = rank;
		this.colour = colour;
		
		/* Set the value of the card */
		if (colour != Colour.TRUMP)
		{
			switch (rank)
			{
			case 14:
				/* King -> 4.5 pts */
				this.value = 4.5;
				break;
			case 13:
				/* Queen -> 3.5 pts */
				this.value = 3.5;
				break;
			case 12:
				/* Knight -> 2.5 pts */
				this.value = 2.5;
				break;
			case 11:
				/* Jack -> 1.5 pts */
				this.value = 1.5;
				break;
			default:
				/* Other -> 0.5 pts */
				this.value = 0.5;
				break;
			}
		}
		else /* TRUMP */
		{
			if (this.is_oudler ())
			{
				/* 4.5 for oudlers */
				this.value = 4.5;
			}
			else
			{
				/* 0.5 for other trumps */
				this.value = 0.5;
			}
		}
	}
}

