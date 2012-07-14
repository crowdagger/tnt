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
 * IA implementation of the Player Class.
 *
 * TODO: allow the IA to take.
 **/
public class IAPlayer:Player
{
	private Card planned_card = null;

	/**
	 * Receive a new hand, at the beginning of a game.
	 **/
	public override void receive_hand (Hand hand)
	{
		this.hand = hand;
	}

	/**
	 * Select a bid
	 *
	 * The idea is to evaluate a hand, and according to the player, take or not.
	 *
	 * TODO: Evaluation should be based on
	 * http://en.wikipedia.org/wiki/French_tarot#Evaluating_one.27s_hand  
	 **/
	public override void select_bid (Bid max_bid = Bid.PASSE)
	{
		/* First, determine the score */
		double value = 0.0;
		int oudlers = 0;
		int trumps = 0;
		Bid preferred_bid = Bid.PASSE;
		foreach (Card c in this.hand.list)
		{
			value += c.value;
			if (c.colour == Colour.TRUMP)
			{
				trumps += 1;
				if (c.is_oudler ())
				{
					oudlers += 1;
				}
			}
		}

		/* Second, according to the score, determine if the player
		 * takes or not. TODO: this should be based on parameters, so
		 * different IA players don't behave in the same way.
		 */
		value = 10 * oudlers + 3 * trumps + value;
		if (value > 110)
		{
			preferred_bid = Bid.GARDE_CONTRE;
		}
		else if (value > 95)
		{
			preferred_bid = Bid.GARDE_SANS;
		}
		else if (value > 80)
		{
			preferred_bid = Bid.GARDE;
		}
		else if (value > 60)
		{
			preferred_bid = Bid.PETITE;
		}
		else
		{
			preferred_bid = Bid.PASSE;
		}
		
		if (preferred_bid > max_bid)
		{
			game.give_bid (this, preferred_bid);
		}
		else
		{
			game.give_bid (this, Bid.PASSE);
		}
	}

	/**
	 * Receive a dog. If the player is the taker, a new dog must be sent.
	 **/
	public override void receive_dog (Hand dog)
	{
		/* Check if we are the taker or not */
		if (game.players[game.taker] != this)
		{
			game.give_dog (this, null);
		}
		else
		{
			foreach (Card c in dog.list)
			{
				this.hand.add (c);
			}
			
			Hand new_dog = new Hand ();
			this.hand.sort_by_value ();
			
			int remaining_cards = 6;
			while (remaining_cards > 0)
			{
				/* See if we can make a cut */
				int[] nb_colours = new int[4];
				foreach (Card c in this.hand.list)
				{
					if (c.rank != 14) // Don't count the king
					{
						for (int i = 0; i < 4; i++)
						{
							if (i == c.colour)
							{
								nb_colours[i] += 1;
							}
						}
					}
				}
				
				int best_for_cut = 0;
				int lowest_cards = 91;
				for (int i = 0; i < 4; i++)
				{
					if (nb_colours[i] == 0)
					{
						/* Case already matched */
						continue;
					}
					else if (nb_colours[i] < lowest_cards)
					{
						best_for_cut = i;
						lowest_cards = nb_colours[i];
					}
				}
				
				assert (lowest_cards > 0);
				
				/* TODO: one day, handle the case where player has too much trumps and kings */
				
				Gee.ArrayList <Card> to_remove = new Gee.ArrayList <Card> ();
				foreach (Card c in hand.list)
				{
					if (c.colour == best_for_cut && c.rank != 14)
					{
						new_dog.add (c);
						to_remove.add (c);
						remaining_cards--;
						
						if (remaining_cards == 0)
						{
							foreach (Card cprime in to_remove)
							{
								this.hand.remove (cprime);
							}
							break;
						}
					}
				}
				foreach (Card cprime in to_remove)
				{
					this.hand.remove (cprime);
				}
			}
			
			game.give_dog (this, new_dog);
		}
	}

	/**
	 * Select a card to play
	 **/
	public override void select_card (int beginner, Card[] cards)
	{
		/* Excuse if trump is play, else special routine */
		Card selected_card = try_excuse (beginner, cards);

		if (selected_card == null)
		{
			if (game.players[game.taker] == this)
			{
				selected_card = attacker_move (beginner, cards);
			}
			else
			{
				selected_card = defender_move (beginner, cards);
			}
		}
		/* Give the selected card */
		hand.list.remove (selected_card);
		game.give_card (this, selected_card);
	}

	/**
	 * Excuse oneself if trump is played 
	 **/
	private Card? try_excuse (int beginner, Card[] cards)
	{
		if (cards[beginner] == null)
		{
			return null;
		}

		if (cards[beginner].colour != Colour.TRUMP)
		{
			return null;
		}

		foreach (Card? card in cards)
		{
			if (card != null)
			{
				if (card.colour != Colour.TRUMP || card.rank == 1)
				{
					return null;
				}
			}
		}
		foreach (Card card in hand.list)
		{
			if (card.colour == Colour.TRUMP && card.rank == 0)
			{
				return card;
			}
		}
		return null;
	}

	/**
	 * Select a card / attacker version
	 **/
	private Card attacker_move (int beginner, Card[] cards)
	{
		Card selected_card = null;
		if (game.players[beginner] == this)
		{
		    selected_card = attacker_open (beginner, cards);
		}
		else
		{
			selected_card = attacker_follow (beginner, cards);
		}
		return selected_card;
	}

	/**
	 * The attacker is opening... 
	 **/
	private Card attacker_open (int beginner, Card[] cards)
	{
		/* IF we planned to play a card at previous turn, play it */
		if (planned_card != null)
		{
			Card c = planned_card;	
			planned_card = null;
			foreach (Card d in hand.list)
			{
				if (d.colour == c.colour && d.rank == c.rank - 1)
				{
					planned_card = d;
				}
			}

			return c;
		}

		/* This is really simple. Either we have a king, or we play
		   a low card. */
		foreach (Card c in hand.list)
		{
			if (c.rank == 14)
			{
				foreach (Card d in hand.list)
				{
					if (d.colour == c.colour && d.rank == c.rank - 1)
					{
						planned_card = d;
					}
				}
				return c;
			}
		}

		return play_low_card (beginner, cards, hand.list);
	}

	/**
	 * The attacker isn't opening...
	 **/
	private Card attacker_follow (int beginner, Card[] cards)
	{
		/* We didn't win, so let's put planned_card to null in case */
		planned_card = null;

		Card selected_card = null;

		/* Get a list of all playable cards */
		Gee.ArrayList<Card> possible_cards = hand.get_playable_cards (beginner, cards);

		int nb_null = 0;
		foreach (Card? c in cards)
		{
			if (c == null)
			{
				nb_null++;
			}
		}
		
		/* If we are last to play, play a higlhy valued card if it wins */
		if (nb_null == 1)
		{
			selected_card = play_high_if_wins (beginner, cards, possible_cards);
		}

		/* If we have a king, try playing it */
		foreach (Card c in possible_cards)
		{
			if (c.rank == 14 && c.colour != Colour.TRUMP)
			{
				selected_card = c;
			}
		}
			
		/* Default: put the lowest */
		if (selected_card == null)
		{
			selected_card = play_low_card (beginner, cards, possible_cards);
		}			

		return selected_card;
	}

	/**
	 * Select a card / defender version
	 **/
	private Card defender_move (int beginner, Card[] cards)
	{
		Card selected_card = null;

		/* Get a list of all playable cards */
		Gee.ArrayList<Card> possible_cards = hand.get_playable_cards (beginner, cards);

		/* We are among the defendants. 
		   Very basic IA: determinate whether we are sure to take the
		   hand (and give the card with greatest value), or if the
		   opponents (might) have the upper hand (and give the card
		   with lowest value. */
		bool sure_to_win = false;
		if (cards[game.taker] != null)
		{
			/* Taker has already played, so determine if they win */
			int winner = determine_winner (beginner, cards);
			
			if (winner != game.taker)
			{
				sure_to_win = true;
			}
		}
		
		if (sure_to_win)
		{
			/* Sure to win, put highest card */
			selected_card = play_high_card (beginner, cards, possible_cards);
		}
		else
		{
			/* Not sure to win, check if we got better */
			if (cards[game.taker] != null)
			{
				selected_card = play_high_if_wins (beginner, cards, possible_cards);
			}
			
			/* If we can't put better, put the lowest */
			if (selected_card == null)
			{
				selected_card = play_low_card (beginner, cards, possible_cards);
			}
		}

		return selected_card;
	}

	/**
	 * Return the highest valuest card if it wins, or null otherwise
	 **/
	private Card play_high_if_wins (int beginner, Card[] cards, Gee.ArrayList<Card> possible_cards)
	{
		Card selected_card = null;
		double max_value = 0.0;
		int opponent;
		if (game.players[game.taker] == this)
		{
			opponent = determine_winner (beginner, cards);
		}
		else
		{
			opponent = game.taker;
		}
		foreach (Card card in possible_cards)
		{
			if (card.is_better_than (cards[opponent]))
			{
				if (card.value > max_value)
				{
					selected_card = card;
					max_value = card.value;
				}
			}
		}

		return selected_card;
	}
   

	/**
	 * Return the highest value card we can play
	 **/
	private Card play_high_card (int beginner, Card[] cards, Gee.ArrayList<Card> possible_cards)
	{
		Card selected_card = null;
		double max_value = 0.0;
		foreach (Card card in possible_cards)
		{
			if (card.value > max_value)
			{
				selected_card = card;
				max_value = card.value;
			}
		}
		return selected_card;
	}

	/**
	 * Return the lowest value card we can play
	 **/
	private Card play_low_card (int beginner, Card[] cards, Gee.ArrayList<Card> possible_cards)
	{
		Card selected_card = null; 
		double min_value = 10.0;
		foreach (Card card in possible_cards)
		{
			if (card.value < min_value)
			{
				selected_card = card;
				min_value = card.value;
			}
		}
		return selected_card;
	}


	/**
	 * Determine who wins according to currently played cards
	 **/
	private int determine_winner (int beginner, Card[] cards)
	{
		int winner = beginner;
		for (int i = beginner; i < beginner + cards.length; i++)
		{
			int index = i % cards.length;
			if (cards[index] != null)
			{
				if (cards[index].is_better_than (cards[winner]))
				{
					winner = index;
				}
			}
		}
		
		return winner;
	}

	/** 
	 * Constructor
	 **/
	public IAPlayer (Game game, string? name = null)
	{
		base (game, name);
	}
}