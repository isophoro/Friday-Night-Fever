package meta;

import flixel.FlxG;
import shaders.BadNun;

typedef JudgedRatings = // Used to keep track of the player's current amount of ratings recieved.
{
	shits:Int,
	bads:Int,
	goods:Int
}

enum RatingData
{
	TimeWindow(milliseconds:Int, rating:String);
	WifeCondition(percent:Float, display:String);
}

class Ratings
{
	public static final TIME_WINDOWS:Array<RatingData> = [
		TimeWindow(45, "sick"),
		TimeWindow(90, "good"),
		TimeWindow(135, "bad"),
		TimeWindow(166, "shit")
	];

	public static final WIFE_CONDITIONS:Array<RatingData> = [
		WifeCondition(99.9935, "AAAAA"),
		WifeCondition(99.980, "AAAA:"),
		WifeCondition(99.970, "AAAA."),
		WifeCondition(99.955, "AAAA"),
		WifeCondition(99.90, "AAA:"),
		WifeCondition(99.80, "AAA."),
		WifeCondition(99.70, "AAA"),
		WifeCondition(99, "AA:"),
		WifeCondition(96.50, "AA."),
		WifeCondition(93, "AA"),
		WifeCondition(90, "A:"),
		WifeCondition(85, "A."),
		WifeCondition(80, "A"),
		WifeCondition(70, "B"),
		WifeCondition(60, "C"),
		WifeCondition(80, "D")
	];

	public static final SICK_FC = "SFC";
	public static final GOOD_FC = "GFC";
	public static final FC = "FC";
	public static final SINGLE_DIGIT_COMBO_BREAK = "SDCB";

	public static function getComboRating():String
	{
		if (ClientPrefs.botplay)
			return SICK_FC;

		if (PlayState.instance.misses == 0)
		{
			var r = PlayState.instance.totalRatings;
			if (r.bads == 0 && r.shits == 0 && r.goods == 0) // Marvelous (SICK) Full Combo
				return SICK_FC;
			else if (r.bads == 0 && r.shits == 0) // Good Full Combo (Nothing but Goods & Sicks)
				return GOOD_FC;
			else
				return FC;
		}
		else
		{
			return PlayState.instance.misses + (PlayState.instance.misses > 1 ? " misses" : " miss");
		}
	}

	public static function getWife3Rating(accuracy:Float):String
	{
		for (i in WIFE_CONDITIONS)
		{
			if (accuracy >= i.getParameters()[0])
			{
				return i.getParameters()[1];
			}
		}

		return WIFE_CONDITIONS[0].getParameters()[1];
	}

	public static function CalculateRating(noteDiff:Float):String // Generate a judgement through some timing shit
	{
		if (ClientPrefs.botplay)
			return TIME_WINDOWS[0].getParameters()[0];

		for (i in TIME_WINDOWS)
		{
			var params = i.getParameters();
			if (Math.abs(noteDiff) < params[0] * FlxG.sound.music.pitch)
			{
				return params[1];
			}
		}

		return "shit";
	}

	public static function CalculateRanking(accuracy:Float):String
	{
		if (PlayState.SONG.song == 'Bad-Nun' && BadNun.translate)
		{
			return new UnicodeString("見逃した: "
				+ PlayState.instance.misses
				+ // Misses/Combo Breaks
				" | 正確さ: "
				+ (FlxG.save.data.botplay ? "N/A" : (Math.isNaN(accuracy) ? 100 : FlxMath.roundDecimal(accuracy, 2)) + "%")
				+ // Accuracy
				" • ");
		}
		else
		{
			BadNun.translate = false;

			var acc:String = ClientPrefs.botplay ? "N/A" : (Math.isNaN(accuracy) ? 100 : FlxMath.roundDecimal(accuracy, 2)) + "%";
			return 'Accuracy: $acc | ${getComboRating()} • ${getWife3Rating(accuracy)}';
		}
	}

	public static function getDiscordPreview():String
	{
		var acc:String = ClientPrefs.botplay ? "N/A" : (Math.isNaN(PlayState.instance.accuracy) ? 100 : FlxMath.roundDecimal(PlayState.instance.accuracy, 2))
			+ "%";

		return 'Accuracy: $acc | Missed: ${PlayState.instance.misses}';
	}

	public static function wife3(maxms:Float, ts:Float = 1)
	{
		var max_points = 1.0;
		var miss_weight = -5.5;
		var ridic = 5 * ts;
		var max_boo_weight = 180 * ts;
		var ts_pow = 0.75;
		var zero = 65 * (Math.pow(ts, ts_pow));
		var power = 2.5;
		var dev = 22.7 * (Math.pow(ts, ts_pow));

		if (maxms <= ridic) // anything below this (judge scaled) threshold is counted as full pts
			return max_points;
		else if (maxms <= zero) // ma/pa region, exponential
			return max_points * erf((zero - maxms) / dev);
		else if (maxms <= max_boo_weight) // cb region, linear
			return (maxms - zero) * miss_weight / (max_boo_weight - zero);
		else
			return miss_weight;
	}

	public static var a1 = 0.254829592;
	public static var a2 = -0.284496736;
	public static var a3 = 1.421413741;
	public static var a4 = -1.453152027;
	public static var a5 = 1.061405429;
	public static var p = 0.3275911;

	public static function erf(x:Float):Float
	{
		// Save the sign of x
		var sign = 1;
		if (x < 0)
			sign = -1;
		x = Math.abs(x);

		// A&S formula 7.1.26
		var t = 1.0 / (1.0 + p * x);
		var y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);

		return sign * y;
	}
}
