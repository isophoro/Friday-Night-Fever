package;

typedef DifficutlyData =
{
	name:String,
	?chartSuffix:String
}

@:enum abstract Difficulty(Int) from Int to Int
{
	public static final DIFFICULTY_MIN = -1;
	public static final DIFFICULTY_MAX = 2;
	public static final data:Map<Difficulty, DifficutlyData> = [
		BABY => {name: "Baby", chartSuffix: "-easy"},
		EASY => {name: "Easy", chartSuffix: "-easy"},
		NORMAL => {name: "Normal"},
		HARD => {name: "Hard", chartSuffix: "-hard"}
	];
	// DIFFICULTIES
	var BABY = -1;
	var EASY = 0;
	var NORMAL = 1;
	var HARD = 2;

	public static function bound(diff:Int):Int
	{
		return diff < DIFFICULTY_MIN ? DIFFICULTY_MAX : diff > DIFFICULTY_MAX ? DIFFICULTY_MIN : diff;
	}
}
