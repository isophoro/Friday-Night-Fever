package;

abstract Trophy(Int) from Int to Int
{
	public static inline var TEST_TROPHY:Trophy = 180339;
}

/**
 * Uses Gamejolt API V1.2
 */
class GJAPI
{
	public static final ID:Int = 279709;
	public static final KEY:String = "41db1c9bbe9c0baaec5329ed502a6c0b";

	static final URL:String = "https://api.gamejolt.com/api/game/v1_2/";

	public static function unlockTrophy(trophy:Trophy)
	{
		//
	}
}
