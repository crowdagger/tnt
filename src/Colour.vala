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
 * Enum handling card colour. Trumps is considered a fifth colour –
 * and the excuse is number 0
 **/
public enum Colour 
  {
	  SPADE, HEART, CLUB, DIAMOND, TRUMP;
    
    public string to_string ()
    {
      switch (this) 
        {
        case SPADE:
          return "pique";

        case HEART:
          return "coeur";

        case DIAMOND:
          return "carreau";
          
        case CLUB:
          return "trèfle";

        case TRUMP:
          return "atout";

        default:
          assert_not_reached ();
        }
      
	}

	public static Colour[] all ()
	{
		return {SPADE, HEART, CLUB, DIAMOND, TRUMP};
	}
}
