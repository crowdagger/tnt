/**
 * Enum handling card colour. Trumps is considered a fifth colour –
 * and the excuse is number 0
 **/
public enum Colour 
  {
    SPADE, HEART, DIAMOND, CLUB, TRUMP;
    
    public string to_string ()
    {
      switch (this) 
        {
        case SPADE:
          return "pique";

        case HEART:
          return "coeur";

        case DIAMOND:
          return "carreau";
          
        case CLUB:
          return "trèfle";

        case TRUMP:
          return "atout";

        default:
          assert_not_reached ();
        }
      
	}
}
