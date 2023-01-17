package;

typedef DifficutlyData =
{
	name:String,
	?chartSuffix:String
}

@:enum abstract Difficulty(Int) from Int to Int
{
	public static final DIFFICULTY_MIN = 1;
	public static final DIFFICULTY_MAX = 2;
	public static final data:Map<Difficulty, DifficutlyData> = [
		EASY => {name: "Easy"},
		NORMAL => {name: "Normal", chartSuffix: "-hard"},
		MINUS => {name: "Minus", chartSuffix: "-hard"}
	];
	// DIFFICULTIES
	var EASY = 1;
	var NORMAL = 2;
	var MINUS = 3;

	public static function bound(diff:Int):Int
	{
		return diff < DIFFICULTY_MIN ? DIFFICULTY_MAX : diff > DIFFICULTY_MAX ? DIFFICULTY_MIN : diff;
	}
}
