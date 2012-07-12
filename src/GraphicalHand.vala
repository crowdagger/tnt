/**
 * This class displays the hand of the player, and allows to select which card to play.
 **/
public class GraphicalHand:Gtk.VBox
{
	public Hand hand {get; private set;}
	private Gtk.Fixed fixed = null;

	public GraphicalHand (Hand hand)
	{
		this.hand = hand;
		refresh ();
	}

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
			var image = new Gtk.Image.from_file (card.image_file);
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
			x += 30;
		}

		this.show_all ();
	}
}