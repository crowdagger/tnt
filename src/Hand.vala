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
 * Callback for sorting cards by value 
 **/
static int card_sorter_value (Card a, Card b)
{
	if (a.value < b.value)
	{
		return -1;
	}
	else if (a.value > b.value)
	{
		return 1;
	}
	else
	{
		return card_sorter (a, b);
	}
}

/**
 * Callback for sorting the game
 **/
static int card_sorter (Card a, Card b)
{
  if (a.rank == 0)
    return 1;
  if (b.rank == 0)
    return -1;
  if (a.colour < b.colour)
    return -1;
  else if (a.colour == b.colour)
    {
      if (a.rank < b.rank)
        return -1;
      else if (a.rank == b.rank)
        return 0;
      else
        return 1;
    }
  else
    return 1;
}

/**
 * Manages a hand of cards 
 *
 * (Or just a list of cards, like the stack or the deck)
 */
public class Hand:Object
{
	public Gee.ArrayList <Card> list {get; private set;}

	public Hand ()
	{
		list = new Gee.ArrayList <Card> ();
	}

	/**
	 * Add a card to the internal list; equivalent to hand.add () 
	 **/
	public void add (Card card)
	{
		list.add (card);
	}

	/** 
	 * Remove a card from the internal list; equivalent to hand.remove ()
	 */
	public void remove (Card card)
	{
		list.remove (card);
	}

	/**
	 * Sort the cards (for a display in hand)
	 **/
	public void sort ()
	{
		list.sort ((CompareFunc<Card>) card_sorter);
	}

	/**
	 * Sort the cards by value 
	 **/
	public void sort_by_value ()
	{
		list.sort ((CompareFunc<Card>) card_sorter_value);
	}

	/**
	 * Get total value of the hand
	 **/
	public double get_value ()
	{
		double value = 0.0;
		foreach (Card card in list)
		{
			value += card.value;
		}
		return value;
	}

	/**
	 * Get number of oudlers
	 **/
	public int get_nb_oudlers ()
	{
		int oudlers = 0;
		foreach (Card card in list)
		{
			if (card.is_oudler ())
			{
				oudlers += 1;
			}
		}
		return oudlers;
	}

	/**
	 * Get the required score to win according to the number of oudlers 
	 **/
	public int required_score ()
	{
		int oudlers = get_nb_oudlers ();
		int threshold;
		
		switch (oudlers)
		{
		case 0:
			threshold = 56;
			break;
		case 1:
			threshold = 51;
			break;
		case 2:
			threshold = 41;
			break;
		case 3:
			threshold = 36;
			break;
		default:
			assert_not_reached ();
		}
		
		return threshold;
	}

	/**
	 * Get score, depending of value of the game and numbers of oudlers
	 **/
	public double get_score ()
	{
		double value = get_value ();
		double threshold = required_score ();
		return value - threshold;
	}

	/**
	 * Shuffle the game
	 *
	 * TODO: tarots game must NOT be shuffled!
	 **/
	public void shuffle (int nb_iter = 42)
	{
		for (int i = 0; i < nb_iter; i++)
		{
			int init_pos = Random.int_range (0, list.size);
			int end_pos = Random.int_range (0, list.size);

			Card card = list[init_pos];
			list[init_pos] = list[end_pos];
			list[end_pos] = card;
		}
	}

	/**
	 * Take all cards to the hand in parameters and give it to this hand
	 **/
	public void take_all (Hand hand)
	{
		this.list.insert_all (0, hand.list);
		hand.list = new Gee.ArrayList <Card> ();
	}

	/**
	 * Check whether the card played is a valid move in the context of
	 * the cards in hand and of the already played cards
	 *
	 * \param card: the card to play
	 * \param cards: the cards already played
	 * \param beginner: the player who played the first card
	 *
	 * \returns true if card is legit to play, false else.
	 **/
	public bool is_card_playable (Card card, int beginner, Card[] cards)
	{
		Card first_card = cards[beginner];

		/* If played card is excuse, it's ok */
		if (card.colour == Colour.TRUMP && card.rank == 0)
		{
			return true;
		}
		/* If first card is excuse, discard it */
		if (first_card.colour == Colour.TRUMP && first_card.rank == 0)
		{
			first_card = cards[(beginner+1)%cards.length];
		}
		/* If no card is played, we can play anything */
		if (first_card == null)
		{
			return true;
		}
		/* If we play in the same colour (and it's not trump), it's
		   almays ok */
		if (first_card.colour == card.colour && first_card.colour != Colour.TRUMP)
		{
			return true;
		}
		/* If we don't play in the same colour, while we do have the
		   colour, it's always wrong */
		if (first_card.colour != card.colour)
		{
			bool colour_available = false;
			foreach (Card c in list)
			{
				assert (card != null);
				if (c.colour == first_card.colour && c.is_excuse () == false)
				{
					colour_available = true;
					break;
				}
			}
			if (colour_available)
			{
				return false;
			}
		}
		/* In other cases, we must know the best card played as well */
		Card best_card = first_card;
		for (int i = beginner; i < beginner + cards.length; i++)
		{
			int index = i%cards.length;
			if (cards[index] == null)
			{
				break;
			}
			else 
			{
				if (cards[index].is_better_than (best_card))
				{
					best_card = cards[index];
				}
			}
		}
		/* If card is better than best card, it's okay to play it */
		if (card.is_better_than (best_card))
		{
			return true;
		}
		else
		{ 
			/* If there is no cards in hand better than best card,
			   it's okay to play it, else... */
			bool better_card_available = false;
			foreach (Card c in list)
			{
				assert (c != null);
				if (c.is_better_than (best_card))
				{
					better_card_available = true;
					break;
				}
			}
			if (better_card_available)
			{
				return false;
			}
			/* ... else, well, we must still play trump if we have some */
			else
			{
				if (card.colour == Colour.TRUMP)
				{
					return true;
				}
				else
				{
					bool trump_available = false;
					foreach (Card c in list)
					{
						assert (c != null);
						if (c.colour == Colour.TRUMP && c.rank != 0)
						{
							trump_available = true;
							break;
						}
					}
					if (trump_available)
					{
						return false;
					}
					else
					{
						return true;
					}
				}
			}
		}
	}

	/**
	 * Return the list of cards that can legitimely be played 
	 **/
	public Gee.ArrayList<Card> get_playable_cards (int beginner, Card[] cards)
	{
		Gee.ArrayList<Card> playable_list = new Gee.ArrayList<Card> ();

		foreach (Card card in list)
		{
			if (is_card_playable (card, beginner, cards))
			{
				playable_list.add (card);
			}
		}

		return playable_list;
	}
}