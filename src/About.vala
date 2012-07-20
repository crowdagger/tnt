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
    along with ASpiReNN; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307  USA.

***********************************************************************/

/**
 * Displays the About dialog. Really all the core algorithms are in this class.
 **/
public class About:Gtk.AboutDialog
{
	public About ()
	{
		set_program_name (Config.PACKAGE_STRING);
		set_version (Config.PACKAGE_VERSION);
		set_authors ({"Élisabeth Henry"});
		set_license_type (Gtk.License.GPL_2_0);
		set_wrap_license (true);
		set_copyright ("©2011-2012, Élisabeth Henry.\n This is free software; see License for more information.");
	}

	/**
	 * Delete the dialog when we get a response (ie, "close")
	 **/
	public override void response (int response_id)
	{
		this.destroy ();
	}
}