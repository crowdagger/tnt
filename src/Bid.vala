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
 * Enumeration to handle bidding
 **/
public enum Bid
{
	PASSE, PETITE, GARDE, GARDE_SANS, GARDE_CONTRE, NULL;

	public string to_string ()
	{
		switch (this)
		{
		case PASSE:
			return _("passe");

		case PETITE:
			return _("petite");

		case GARDE:
			return _("garde");
		
		case GARDE_SANS:
			return _("garde sans");

		case GARDE_CONTRE:
			return _("garde contre");

		default:
		assert_not_reached ();
		}
	}
	
	public static Bid[] all ()
	{
		return {PASSE, PETITE, GARDE, GARDE_SANS, GARDE_CONTRE};
	}
	
	public double get_multiplier ()
	{
		switch (this)
		{
		case PETITE:
			return 1.0;

		case GARDE:
			return 2.0;

		case GARDE_SANS:
			return 4.0;
			
		case GARDE_CONTRE:
			return 6.0;

		default:
			assert_not_reached ();
		}
	}
}