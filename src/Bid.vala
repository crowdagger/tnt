/**
 * Enumeration to handle bidding
 **/
public enum Bid
{
	PASSE, PETITE, GARDE, GARDE_SANS, GARDE_CONTRE, NULL;

	public string to_string ()
	{
		switch (this)
		{
		case PASSE:
		return "passe";

		case PETITE:
		return "petite";

		case GARDE:
		return "garde";

		case GARDE_SANS:
		return "garde sans";

		case GARDE_CONTRE:
		return "garde contre";

		default:
		assert_not_reached ();
		}
	}
	
	public static Bid[] all ()
	{
		return {PASSE, PETITE, GARDE, GARDE_SANS, GARDE_CONTRE};
	}
	
	public double get_multiplier ()
	{
		switch (this)
		{
		case PETITE:
			return 1.0;

		case GARDE:
			return 2.0;

		case GARDE_SANS:
			return 4.0;
			
		case GARDE_CONTRE:
			return 6.0;

		default:
			assert_not_reached ();
		}
	}
}