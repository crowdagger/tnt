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
 * This class is the one handling the evolving of a game.
 **/
public class Game:GLib.Object
{
	public Player[] players {get; private set;}
	public Hand deck {get; private set;}
	public int nb_players {get; private set;}
	public Hand taker_stack {get; private set;}
	public Hand defenders_stack {get; private set;}
	public int taker {get; private set;}
	public Scores scores {get; private set;}
	public string file_to_save {get; set;}


	private int current_turn;
	private int nb_turns;
	private int current_player;
	private int beginner; 
	private int starter;
	private Card[] played_cards;
	private Bid[] players_bids; 
	private Hand dog;
	private int nb_approvals;
	private Hand card_due_for_excuse;

	/**
	 * Initialize all cards. If graphical is not set to true, the game
	 * won't possibly run graphically.
	 **/
	private void init_cards (bool graphical = true)
	{
		/* Initialize all cards */
		/* Non-trumps */
		Colour[] real_colours = {Colour.SPADE, Colour.HEART, Colour.DIAMOND, Colour.CLUB};
		foreach (Colour colour in real_colours)
		{
			for (int i = 1; i <= 14; i++)
			{
				Card card;
				if (graphical)
				{
					card = new GraphicalCard (colour, i);
				}
				else
				{
					card = new Card (colour, i);
				}
				deck.add (card);
			}
		}

		/* Trumps */
		for (int i = 0; i < 22; i++)
		{
			Card card;
			if (graphical)
			{
				card = new GraphicalCard (Colour.TRUMP, i);
			}
			else
			{
				card = new Card (Colour.TRUMP, i);
			}
			deck.add (card);
		}
	}

	/**
	 * Init the cards from an opened file 
	 **/
	public void init_cards_from_stream (GLib.FileStream stream, bool graphical = true)
	{
		for (int i = 0; i < 78; i++)
		{
			stdout.printf ("loading card %d\n", i);
			Card c;
			string line = stream.read_line ();
			if (graphical)
			{
				c = new GraphicalCard.from_string (line);
			}
			else
			{
				c = new Card.from_string (line);
			}
			deck.add (c);
		}
	}

	/**
	 * (Re)init value to have a fresh game
	 **/
	private void init_values ()
	{
		nb_approvals = 0;
		for (int i = 0; i < played_cards.length; i++)
		{
			played_cards[i] = null;
		}
	}

	public Game (bool graphical = true)
	{
		nb_players = 4;
		nb_turns = 18;
		starter = 0;
		card_due_for_excuse = null;

		file_to_save = null;
		players_bids = new Bid[nb_players];
		taker_stack = new Hand ();
		defenders_stack = new Hand ();
		players = new Player[nb_players];
		played_cards = new Card[nb_players];
		deck = new Hand ();
		
		init_values ();
		/* Initialize scores */
		scores = new Scores (this);


	}

	/**
	 * Initialize players
	 **/
	public void init_players (string[]? _names, bool[]? _humans)
	{
		/* First, initialize cards */
		init_cards (true);
		deck.shuffle ();
		string[] names;
		bool[] humans;
		if (_names == null)
		{
			names = {"Player 1", "Player 2", "Player 3", "Player 4"};
		}
		else
		{
			assert (_names.length == nb_players);
			names = _names;
		}

		if (_humans == null)
		{
			humans = {true, false, false, false};
		}
		else
		{
			assert (_humans.length == nb_players);
			humans = _humans;
		}

		for (int i = 0; i < 4; i++)
		{
			if (humans[i])
			{
				players[i] = new GraphicalPlayer (this, names[i]);
			}
			else
			{
				players[i] = new IAPlayer (this, names[i]);
			}
		}
		scores.refresh ();
	}

	/*
	 * Distribute the game and give them to the players
	 **/
	public void distribute ()
	{
		assert (deck.list.size == 78);

		init_values ();

		dog = new Hand ();
		Hand[] hands = new Hand[nb_players];
		for (int j = 0; j < nb_players; j++)
		{
			hands[j] = new Hand ();
		}

		if (nb_players ==4)
		{
			
			for (int i = 0; i < nb_turns / 3; i++)
			{
				for (int j = 0; j < nb_players; j++)
				{
					for (int k = 0; k < 3; k++)
					{
						hands[j].add (deck.list[0]);
						deck.list.remove_at (0);
					}
				}
				dog.add (deck.list[0]);
				deck.list.remove_at (0);
			}
		}

		for (int i = 0; i < nb_players; i++)
		{
			players[i].receive_hand (hands[i]);
		}

		current_turn = 0;
		current_player = starter;
		beginner = starter;

        /* Send demands for bids */
		for (int i = 0; i < nb_players; i++)
		{
			players_bids[i] = Bid.NULL;
		}
		players[current_player].select_bid (Bid.PASSE);
	}

	/** 
	 * Get a bid a player wants to make. Return true if legit, false
	 * else. 
	 **/
	public bool give_bid (Player player, Bid bid)
	{
		assert (player == players[current_player]);

		Bid max_bid = Bid.PASSE;
		for (int i = 0; i < nb_players; i++)
		{
			if (players_bids[i] != Bid.NULL)
			{
				if (players_bids[i] > max_bid)
				{
					max_bid = players_bids[i];
				}
			}
		}

		/* Check that the bid is greater than the other ones, or Bid.PASSE */
		players_bids[current_player] = bid;
		if (bid != Bid.PASSE)
		{
			if (bid <= max_bid)
			{
				stdout.printf ("ERROR: a bid must be superior to the other ones (or Passe)\n");
				return false;
			}
			max_bid = bid;
			taker = current_player;
		}

		current_player++;
		if (current_player >= nb_players)
		{
			current_player = 0;
		}
		if (players_bids[current_player] == Bid.NULL)
		{
			players[current_player].select_bid (max_bid);
		}
		else
		{
			if (max_bid != Bid.PASSE)
			{
				current_player = starter; 
				current_turn = 0;

				string message = "%s takes %s\n".printf (players[taker].name, max_bid.to_string ());
				var dialog = new Gtk.MessageDialog (null,Gtk.DialogFlags.MODAL,Gtk.MessageType.INFO, Gtk.ButtonsType.OK, message); 
				dialog.set_title("Game info");
				dialog.run();
				dialog.destroy ();

				if (max_bid < Bid.GARDE_SANS)
				{
					/* We need to show the players the dog, and wait until the taker has it done */
					nb_approvals = 0;
					foreach (Player p in players)
					{
						p.receive_dog (dog);
					}
					dog = null;
				}
				else
				{
					/* Start the game already */
					if (max_bid == Bid.GARDE_SANS)
					{
						taker_stack.take_all (dog);
					}
					else
					{
						defenders_stack.take_all (dog);
					}
					nb_approvals = 0;
					current_player = starter;
					players[current_player].select_card (current_player, played_cards);
				}

			}
			else
			{
				end_game ();
			}
		}
		return true;
	}

	/**
	 * End_game : put all cards in the deck before redistributing 
	 **/
	void end_game ()
	{
		starter += 1;
		if (starter >= nb_players)
		{
			starter = 0;
		}
		if (dog != null)
		{
			deck.take_all (dog);
			dog = null;
		}
		if (taker_stack != null)
		{
			deck.take_all (taker_stack);
		}
		if (defenders_stack != null)
		{
			deck.take_all (defenders_stack);
		}
		for (int i = 0; i < nb_players; i++)
		{
			deck.take_all (players[i].hand);
		}
		this.save ();
		init_values ();
		distribute ();
	}

	/**
	 * Get a card that a player wants to play. Return true if it's
	 * legit, false else.
	 **/
	public bool give_card (Player player, Card card)
	{
		assert (players[current_player] == player);
		played_cards[current_player] = card;

		/**
		 * Send the informationt about the played card to every player
		 **/
		foreach (Player p in players)
		{
			p.treat_move_info (current_player, card);
		}
		current_player+=1;
		if (current_player >= nb_players)
		{
			current_player = 0;
		}
        /* End of turn */
		/* TODO: make this new method */
		if (played_cards[current_player] != null)
		{
			/* Evaluate winner */
			int winner = beginner;
			for (int i = beginner; i < beginner + played_cards.length; i++)
			{
				int index = i % played_cards.length;
				if (played_cards[index].is_better_than(played_cards[winner]))
				{
					winner = index;
				}
			}

			foreach (Player p in players)
			{
				p.treat_turn_info (winner, played_cards);
			}	
			current_player = winner;
			beginner = winner;
			for (int i = 0; i < played_cards.length; i++)
			{
				/* Excuse is always particular */
				assert (played_cards[i] != null);
				if (played_cards[i].colour == Colour.TRUMP && played_cards[i].rank == 0 && current_turn != nb_turns - 1)
				{
					if (i == taker)
					{
						taker_stack.add (played_cards[i]);
						if (i != winner)
						{
							card_due_for_excuse = taker_stack;
						}
					}
					else
					{
						defenders_stack.add (played_cards[i]);
						if (winner == taker)
						{
							card_due_for_excuse = defenders_stack;
						}
					}
				}
				else
				{
					if (taker == winner)
					{
						taker_stack.add (played_cards[i]);
					}
					else
					{
						defenders_stack.add (played_cards[i]);
					}
				}
				played_cards[i] = null;
			}
			
			current_turn++;
		}
		else
		{
			players[current_player].select_card(beginner, played_cards);
		}
		return true;
	}

	/**
	 * Wait for all players to give their approval for new turn
	 **/
	public void approve_new_turn (Player player)
	{
		nb_approvals++;
		if (nb_approvals == nb_players)
		{
			nb_approvals = 0;
				
			if (current_turn < nb_turns)
			{
				players[current_player].select_card (beginner, played_cards);
			}
			else
			{
				/* End of the game. Compute the scores and display them */

				/* First, check if we need to give another card to
				   balance the excuse we keppt */
				if (card_due_for_excuse != null)
				{
					Hand receiver_stack;
					if (card_due_for_excuse == taker_stack)
					{
						receiver_stack = defenders_stack;
					}
					else
					{
						receiver_stack = taker_stack;
					}

					foreach (Card c in card_due_for_excuse.list)
					{
						/* Give the first card with no special value */
						if (c.value == 0.5)
						{
							receiver_stack.add (c);
							card_due_for_excuse.remove (c);
							break;
						}
					}

					card_due_for_excuse = null;
				}

				double score = taker_stack.get_score ();
				string message = "%d points with %d oudlers\n".printf ((int) taker_stack.get_value (), taker_stack.get_nb_oudlers ());
				message += "Required score: %d\n".printf (taker_stack.required_score ());
				message += "Difference: %d\n".printf ((int) (taker_stack.get_value () - taker_stack.required_score ()));
					
				/* Compute new scores and display them */
				if (score >= 0)
				{
					score += 25;
					message += "Winning bonus: 25\n";
				}
				else
				{
					score -= 25;
					message += "Losing malus: -25\n";
				}
				assert(players_bids[taker] != Bid.NULL);
					
				message += "Bid: %s; multiplier: %d\n".printf (players_bids[taker].to_string (), (int) players_bids[taker].get_multiplier ());
				score *= players_bids[taker].get_multiplier ();
				message += "Total: %d\n".printf((int) score);
				
				/* Add scores to the scores object */
				int[] turn_scores = new int[nb_players];

				for (int i = 0; i < nb_players; i++)
				{
					if (i == taker)
					{
						turn_scores[i] = (int) (score * (nb_players -1));
						players[i].score += (int) (score * (nb_players -1));
					}
					else
					{
						turn_scores[i] = (int) (0-score);
						players[i].score -= (int) score;
					}
					message += "%s \t %d\n".printf (players[i].name, (int)players[i].score);
				}
				scores.add_scores (turn_scores);

				var dialog = new Gtk.MessageDialog (null,Gtk.DialogFlags.MODAL,Gtk.MessageType.INFO, Gtk.ButtonsType.OK, message); 
				dialog.set_title("Scores");
				dialog.run();
				dialog.destroy ();
				end_game ();
			}
		}
	}


	/** 
	 * Get a dog a player want to make. Return true if legit, false
	 * else.
	 *
	 * (Actually, always return true, and breaks on an assert else.)
	 *
	 * If called from other player than taker, dog should be set to
	 * null (at least, it's not used.)
	 **/
	public bool give_dog (Player player, Hand? dog)
	{
		if (players[taker] != player)
		{
			assert (dog == null);
		}
		else
		{
			assert (dog != null);
			assert (dog.list.size == 6);
			taker_stack.take_all (dog);
		}

		nb_approvals++;
		if (nb_approvals == nb_players)
		{
			nb_approvals = 0;
			current_player = starter;
			players[current_player].select_card (current_player, played_cards);
		}
			
		return true;
	}

	/**
	 * Save the current state of the game to a file 
	 **/
	public void save ()
	{
		/* Try to open a FileStream */
		if (file_to_save == null)
		{
			return;
		}
		else
		{
			GLib.FileStream stream = GLib.FileStream.open (file_to_save, "w");
		
			assert (deck.list.size == 78);
			foreach (Card c in deck.list)
			{
				stream.printf ("%s\n", c.to_string ());
			}
			stream.printf ("%d\n", starter);
			foreach (Player p in players)
			{
				p.save (stream);
			}
		}
		//scores.save (stream);
	}

	/**
	 * Load a game status 
	 **/
	public void load (GLib.FileStream stream)
	{
		stdout.printf ("trying to load...\n");

		init_cards_from_stream (stream);

		starter = int.parse (stream.read_line ());

		for (int i = 0; i < nb_players; i++)
		{
			stdout.printf ("%d\n", i);
			players[i] = Player.load (this, stream);
		}
		scores.refresh ();
	}
}