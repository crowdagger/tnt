/**
 * Abtract class player, which allows to implement both IA Players and
 * Graphical Players.
 **/
public abstract class Player:GLib.Object
{
	public string name {get; protected set;}
	public double score {get; set;}
	public Hand hand;
	public weak Game game;

	/* Informs of the cards */
	public abstract void receive_hand (Hand hand);

	/* Treat the information of a move */
	public virtual void treat_move_info (int player, Card card) 
	{
	}
	
	/* Treat the results at the end of turn */
	public virtual void treat_turn_info (int winner, Card[] cards)
	{
		game.approve_new_turn (this);
	}

	/* Must decide what bid the player wants to do, and inform back
	 * game.give_bid */
	public abstract void select_bid (Bid max_bid = Bid.PASSE);
	
	/* Must decide of a dog, and call back game.give_dog */
	public abstract void receive_dog (Hand dog);

	/* This method must call back game.give_card at some point */
	public abstract void select_card (int beginner, Card[] cards);
	
	public Player (Game game, string? name = null)
	{
		hand = new Hand ();
		score = 0.0;
		this.game = game;

		this.name = name;
	}
}