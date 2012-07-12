public class GraphicalCard:Card
{
	public string image_file {get; private set;}
	public bool is_selected {get; set;}

	public signal void select ();

	public GraphicalCard (Colour colour, int rank)
	{
		base (colour, rank);
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