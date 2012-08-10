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
 * Gtk+ interface for human player class
 **/
public class GraphicalPlayer:Player
{
	public GraphicalHand g_hand {get; private set;}

	private ulong old_callback;	

	/* Widgets for differents elements */
	public Gtk.ApplicationWindow window;
	private Gtk.Grid board;
	private Gtk.Button button;
	private GraphicalHand g_dog;
	private Gtk.Label[] players_labels;
	private Gtk.Image[] players_cards;
	private Gtk.Grid grid;
	private SynthethicScore synthetic_score;
	private Gtk.Dialog dialog;

	/* Const parameters for the positions of differents elements */
	private static const int[] WINDOW_SIZE = {800,600};
	private static const int[] HAND_POS = {0, 12};
	private static const int[] DOG_POS = {0, 7};
	private static const int[] BUTTON_POS = {1, 11};
	/* Two followings should be const, but there seems to be a bug in the vala
	   compiler for const multi-dimensionnal arrays... let's change that
	   when it's fixed. */
	private static int[,] PLAYERS_LABELS_POS = {{1, 5}, {2, 2}, {1, 0},{0,2}};
	private static int[,] PLAYERS_CARDS_POS = {{1, 6}, {2, 3}, {1, 1},{0,3}};

	private int beginner;
	private Card[] cards;


	/**
	 * Refresh players' names, that is, update the markup to reflect
	 * who won last turn and who took this game
	 *
	 * Winner: the id of last turn winner, or -1 if n/a.
	 **/
	private void refresh_players_names (int winner)
	{
		string name;
		
		for (int i = 0; i < game.nb_players; i++)
		{
			if (i == game.taker)
			{
				name = "☠ " + game.players[i].name + " ☠";
			}
			else
			{
				name = game.players[i].name;
			}
			if (i == winner && i == game.taker)
			{
				players_labels[i].set_markup ("<span color = \"#FF00FF\"><b>" + name+"</b></span>");
			}
			else if (i == winner)
			{
				players_labels[i].set_markup ("<span color = \"#0000FF\"><b>"+name+"</b></span>");
			}
			else if (i == game.taker)
			{
				players_labels[i].set_markup ("<span color = \"#FF0000\"><b>"+name+"</b></span>");
			}
			else
			{
				players_labels[i].set_markup ("<b>"+name+"</b>");
			}
		}

	}

	/**
	 * Delete the window 
	 **/
	~GraphicalPlayer ()
	{
		if (this.window != null)
		{
			this.window.destroy ();
		}
		if (this.dialog != null)
		{
			this.dialog.destroy ();
		}
	}

	/**
	 * GraphicalPlayer constructor
	 *
	 * Init a window and the elements to display game information 
	 **/
	public GraphicalPlayer (Game game, string? name = null)
	{
		Object (score: 0, game: game, name: name);
	}

	construct {
		button = null; 
		g_dog = null;
		
		/* Initialize the window */
		window = new Gtk.ApplicationWindow (tnt);
		window.set_application (tnt);
		window.title = name;
		window.set_hide_titlebar_when_maximized (true);
		window.set_default_size (WINDOW_SIZE[0], WINDOW_SIZE[1]);
		window.window_position = Gtk.WindowPosition.CENTER;
		window.delete_event.connect (() => {tnt.quit ();});

		/* Initialize the grid */
		grid = new Gtk.Grid ();
		grid.set_column_homogeneous (true);
		grid.set_row_spacing (10);
		grid.set_column_homogeneous (false);
		grid.set_column_spacing (10);
		window.add (grid);
	   
		/* Initialize the fixed */
		board = new Gtk.Grid ();
		board.vexpand = true;
		board.hexpand = true;
		board.set_row_spacing (2);
		board.set_column_spacing (5);
		board.set_row_homogeneous (true);
		board.set_column_homogeneous (true);
		
		grid.attach (board, 0, 1, 1, 4);

		/* ... the score sheet */
		synthetic_score = new SynthethicScore (game);
		
		var win = new Gtk.ScrolledWindow (null, null);
		win.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		win.add (synthetic_score);
		var frame = new Gtk.Frame (_("Scores"));
		frame.add (win);
		frame.set_shadow_type (Gtk.ShadowType.ETCHED_IN);
		grid.attach (frame, 1, 1, 1, 1);

		/* ... the messages text view */
		Gtk.TextView view = new Gtk.TextView.with_buffer (game.buffer);
		view.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);
		view.set_editable (false);
		var win2 = new Gtk.ScrolledWindow (null, null);
		game.new_message.connect (() =>
			{
				Gtk.Adjustment adjustment = win2.get_vadjustment ();
				adjustment.set_value (adjustment.get_upper () - adjustment.get_page_size ());
				adjustment.value_changed ();
			});
		win2.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		win2.add (view);
		var frame2 = new Gtk.Frame (_("Messages"));
		frame2.set_shadow_type (Gtk.ShadowType.ETCHED_IN);
		frame2.add (win2);
		grid.attach (frame2, 1, 2, 1, 3);

		/* Initialize the hand */
		g_hand = new GraphicalHand (hand);
		g_hand.hexpand = true;
		board.attach (g_hand, HAND_POS[0], HAND_POS[1], 3, 4);

		players_labels = new Gtk.Label[3];
		players_cards = new Gtk.Image[4];
		for (int i = 0; i < 4; i++)
		{
			players_labels[i] = null;
			players_cards[i] = new Gtk.Image ();
			players_cards[i].halign = Gtk.Align.CENTER;
			board.attach (players_cards[i], PLAYERS_CARDS_POS[i,0], PLAYERS_CARDS_POS[i,1], 1, 4);
			players_cards[i].show ();
		}

		window.show_all ();
	}

	/**
	 * At the end of turn...
	 *
	 * Clean displayed player cards
	 **/
	public override void treat_turn_info (int winner, Card[] cards)
	{
		/* TODO: rewrite this code */
		for (int i = 0; i < players_cards.length; i++)
		{
			players_cards[i].clear ();
		}
		for (int i = 0; i < cards.length; i++)
		{
			players_cards[i].set_from_pixbuf ((cards[i] as GraphicalCard).get_pixbuf ());
			players_cards[i].show ();
		}
		refresh_players_names (winner);

		button = new Gtk.Button.with_label (_("%s won").printf (game.players[winner].name));
		button.halign = Gtk.Align.CENTER;
		board.attach (button, BUTTON_POS[0], BUTTON_POS[1], 1, 1);
		button.clicked.connect (clear_cards);
		button.show ();
	}

	public void clear_cards ()
	{
		if (button != null)
		{
			button.destroy ();
		}
		for (int i = 0; i < players_cards.length; i++)
		{
			players_cards[i].clear ();
		}
		game.approve_new_turn (this);
	}
		
	/**
	 * Display the card played by a player (by id)
	 **/
	public override void treat_move_info (int player, Card c)
	{
	}
	 

	public override void receive_hand (Hand hand)
	{
		synthetic_score.refresh ();

		this.hand = hand;
		this.hand.sort ();
		g_hand.refresh (hand);

		/* Initialize other player displays */
		/* TODO: not hard-code for 4-player game */

		for (int i = 0; i < 4; i++)
		{
			/* Delete labels and cards widgets from previous game */   
			players_cards[i].clear ();

			if (players_labels[i] != null)
			{
				players_labels[i].destroy ();
				players_labels[i] = null;
			}
			players_labels[i] = new Gtk.Label (null);
			players_labels[i].set_markup ("<b>"+game.players[i].name+"</b>");
			players_labels[i].halign = Gtk.Align.CENTER;
			board.attach (players_labels[i], PLAYERS_LABELS_POS[i,0], PLAYERS_LABELS_POS[i,1], 1, 1);
			players_labels[i].show ();
		}


		foreach (Card c in hand.list)
		{
			assert (c is GraphicalCard);
			GraphicalCard card = (GraphicalCard) c;
			if (old_callback != 0)
			{
				card.disconnect (old_callback);
				old_callback = 0;
			}
		}
	}

	public void send_bid (Bid bid)
	{
		game.give_bid (this, bid);
	}

	/**
	 * Display a dialog to select a bid
	 **/
	public override void select_bid (Bid max_bid)
	{
		dialog = new Gtk.Dialog.with_buttons (_("Select bid"), window, Gtk.DialogFlags.DESTROY_WITH_PARENT, Gtk.Stock.OK, 0, null);
		Gtk.Container content_area = (Gtk.Container) dialog.get_content_area ();

		/* Display one radiobutton per possible bid */
		Bid[] bids = Bid.all ();
		Gtk.RadioButton[] buttons = new Gtk.RadioButton[bids.length];

		for (int i = 0; i < bids.length; i++)
		{
			if (i == 0)
			{
				buttons[i] = new Gtk.RadioButton.with_label (null, bids[i].to_string ());
			}
			else 
			{
				buttons[i] = new Gtk.RadioButton.with_label_from_widget (buttons[0], bids[i].to_string ());
				/* Only authorize bidding if it is superior to current bid */
				if (bids[i] <= max_bid)
				{
					buttons[i].set_sensitive (false);
				}
			}
			content_area.add (buttons[i]);
			
		}

		dialog.response.connect (() => 
			{
				int active = 0;
				for (int i = 0; i < bids.length; i++)
				{
					if (buttons[i].get_active ())
					{
						active = i;
					}
				}
				dialog.destroy ();
				dialog = null;
				send_bid (bids[active]);
			});
				
		dialog.show_all ();
	}

	/**
	 * Ask the player when she is ready to start a new game
	 **/
	public override void request_new_game ()
	{
		button = new Gtk.Button.with_label (_("New game"));
		button.halign = Gtk.Align.CENTER;
		board.attach (button, BUTTON_POS[0], BUTTON_POS[1], 1, 1);
		button.clicked.connect (() =>
			{
				button.destroy ();
				button = null;
				game.ack_new_game ();
			});
		button.show ();
	}

	/**
	 * Show the dog
	 **/
	public override void receive_dog (Hand dog)
	{
		g_dog = new GraphicalHand (dog);
		g_dog.halign = Gtk.Align.CENTER;
		board.attach (g_dog, DOG_POS[0], DOG_POS[1], 3, 4);
		
		button = new Gtk.Button.with_label (_("OK"));
		button.halign = Gtk.Align.CENTER;
		board.attach (button, BUTTON_POS[0], BUTTON_POS[1], 1, 1);
		
		/* If the player took, she gets the dogs; else, she only sees
		   it. */
		if (game.players[game.taker] == this)
		{
			button.clicked.connect (add_to_dog);
		}
		else
		{
			button.clicked.connect (ack_dog);
		}
		button.show ();
	}

	public void add_to_dog ()
	{
		foreach (Card c in g_dog.hand.list)
		{
			hand.add (c);
		}
		hand.sort ();

		g_dog.destroy ();
		g_dog = null;
		button.clicked.disconnect (add_to_dog);
		button.clicked.connect (check_dog);

		foreach (Card c in hand.list)
		{
			assert (c is GraphicalCard);
			GraphicalCard card = (GraphicalCard) c;
			card.is_selected = false;
			card.select.connect (card.switch_selected);
		}
		g_hand.refresh (hand);			
	}

	/**
	 * Acknowledge that the player have seen the dog.
	 **/
	public void ack_dog ()
	{
		button.destroy ();
		button = null;
		g_dog.destroy ();
		g_dog = null;
		this.refresh_players_names (-1);
		
		game.give_dog (this, null);
	}


	/**
	 * Check that there are six cards in the dog, and if ok, send them
	 * to game
	 **/
	public void check_dog ()
	{
		int number_selected = 0;
		/* First pass to check the number of select cards */
		foreach (Card c in hand.list)
		{
			assert (c is GraphicalCard);
			GraphicalCard card = (GraphicalCard) c;
			if (card.is_selected)
			{
				number_selected++;
			}
		}
		if (number_selected != 6)
		{
			var dialog = new Gtk.MessageDialog (null,Gtk.DialogFlags.MODAL,Gtk.MessageType.INFO, Gtk.ButtonsType.OK, _("The dog must contain six cards")); 
			dialog.set_title(_("Dog error"));
			dialog.run();
			dialog.destroy ();
		}
		else
		{
			button.destroy ();
			button = null;

			Hand dog = new Hand ();
			foreach (Card c in hand.list)
			{
				assert (c is GraphicalCard);
				GraphicalCard card = (GraphicalCard) c;
				card.select.disconnect (card.switch_selected);
				if (card.is_selected)
				{
					card.is_selected = false;
					dog.add (card);
				}
			}
			foreach (Card c in dog.list)
				hand.list.remove (c);
			g_hand.refresh (hand);
			this.refresh_players_names (-1);
			game.give_dog (this, dog);
		}
	}

	/**
	 * Activate signals to select a card and call play_card
	 **/
	public override void select_card (int beginner, Card[] cards)
	{
		/** TODO: factorize this code **/
		for (int i = 0; i < cards.length; i++)
		{
			players_cards[i].clear ();

			if (cards[i] != null)
			{
				assert (cards[i] is GraphicalCard);
				GraphicalCard c = (GraphicalCard) cards[i];
				players_cards[i].set_from_pixbuf (c.get_pixbuf ());
				players_cards[i].show ();
			}
		}
		


		this.beginner = beginner;
		this.cards = cards;

		foreach (Card c in hand.list)
		{
			assert (c is GraphicalCard);
			GraphicalCard card = (GraphicalCard) c;
			card.select.connect (play_card);
		}
	}
	
	/**
	 * Called by selected card to give it to game.
	 * 
	 * TODO: check if we have the right to play a card
	 **/
	public void play_card (GraphicalCard card)
	{
		/* If the card is playable... */
		if (hand.is_card_playable (card, beginner, cards))
		{
			/* Disconnect callbacks */
			foreach (Card c in hand.list)
			{
				assert (c is GraphicalCard);
				GraphicalCard the_card = (GraphicalCard) c;
				the_card.select.disconnect (play_card);
			}		
			
			/* Remove card from hand and send it */
			hand.list.remove (card);
			g_hand.refresh (hand);
			game.give_card (this, card);
		}
	}
}