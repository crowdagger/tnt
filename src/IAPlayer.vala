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
		Bid preferred_bid = Bid.PASSE;
		foreach (Card c in this.hand.list)
		{
			value += c.value;
			if (c.is_oudler ())
			{
				oudlers += 1;
			}
		}

		stdout.printf ("%s's value = %f\n", this.name, value);

		/* Second, according to the score, determine if the player
		 * takes or not. TODO: this should be based on parameters, so
		 * different IA players don't behave in the same way.
		 */
		value = 10 * oudlers + value;
		if (value > 55)
		{
			preferred_bid = Bid.GARDE_CONTRE;
		}
		else if (value > 45)
		{
			preferred_bid = Bid.GARDE_SANS;
		}
		else if (value > 35)
		{
			preferred_bid = Bid.GARDE;
		}
		else if (value > 25)
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
	 * Receive a dog, if the player is the taker.
	 **/
	public override void receive_dog (Hand dog)
	{
		/* Actually do nothing, just give the dog back to game */
		game.give_dog (this, dog);
	}

	/**
	 * Select a card to play
	 **/
	public override void select_card (int beginner, Card[] cards)
	{
		Card selected_card = null;

		/* Get a list of all playable cards */
		Gee.ArrayList<Card> possible_cards = hand.get_playable_cards (beginner, cards);

		if (game.players[game.taker] == this)
		{
			/* We took. Not really handled, actually, so let's just
			   give a card. */
			selected_card = possible_cards[0];
		}
		else
		{
			/* We are among the defendants. 
			   Very basic IA: determinate whether we are sure to take the
			   hand (and give the card with greatest value), or if the
			   opponents (might) have the upper hand (and give the card
			   with lowest value. */
			bool sure_to_win = false;
			if (cards[game.taker] != null)
			{
				/* Taker has already played, so determine if they win */
				int winner = beginner;
				for (int i = beginner; i < beginner + cards.length; i++)
				{
					int index = i % cards.length;
					if (cards[index].is_better_than (cards[winner]))
					{
						winner = index;
					}
				}
				if (winner != game.taker)
				{
					sure_to_win = true;
				}
			}

			if (sure_to_win)
			{
				/* Sure to win, put highest card */
				double max_value = 0.0;
				foreach (Card card in possible_cards)
				{
					if (card.value > max_value)
					{
						selected_card = card;
						max_value = card.value;
					}
				}
			}
			else
			{
				/* Not sure to win, check if we got better */
				if (cards[game.taker] != null)
				{
					double max_value = 0.0;
					foreach (Card card in possible_cards)
					{
						if (card.is_better_than (cards[game.taker]))
						{
							selected_card = card;
							max_value = card.value;
						}
					}
				}
				
				/* If we can't put better, put the lowest */
				if (selected_card == null)
				{
					double min_value = 10.0;
					foreach (Card card in possible_cards)
					{
						if (card.value < min_value)
						{
							selected_card = card;
							min_value = card.value;
						}
					}
				}
			}
		}
		/* Give the selected card */
		hand.list.remove (selected_card);
		game.give_card (this, selected_card);
	}

	/** 
	 * Constructor
	 **/
	public IAPlayer (Game game, string? name = null)
	{
		base (game, name);
	}
}