import flixel.FlxG;
import shaders.BadNun;

class Ratings
{
	public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
	{
		var ranking:String = "N/A";

		if (FlxG.save.data.botplay)
			return "BotPlay";

		if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(SFC)";
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (PlayState.misses == 0) // Regular FC
			ranking = "(FC)";
		else if (PlayState.misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "";

		// WIFE TIME :)))) (based on Wife3)
		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		var cutSpace:Bool = ranking.length == 0;

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (cutSpace)
			ranking = ranking.substring(1, ranking.length);

		return ranking;
	}

	public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
	{
		var customTimeScale = Conductor.timeScale;

		if (customSafeZone != null)
			customTimeScale = customSafeZone / 166;

		/*if (FlxG.save.data.botplay)
			return "good"; // i hate who did this */

		if (noteDiff > 166 * customTimeScale) // so god damn early its a miss
			return "miss";
		if (noteDiff > 135 * customTimeScale) // way early
			return "shit";
		else if (noteDiff > 90 * customTimeScale) // early
			return "bad";
		else if (noteDiff > 45 * customTimeScale) // your kinda there
			return "good";
		else if (noteDiff < -45 * customTimeScale) // little late
			return "good";
		else if (noteDiff < -90 * customTimeScale) // late
			return "bad";
		else if (noteDiff < -135 * customTimeScale) // late as fuck
			return "shit";
		else if (noteDiff < -166 * customTimeScale) // so god damn late its a miss
			return "miss";
		return "sick";
	}

	public static function CalculateRanking(score:Int, scoreDef:Int, accuracy:Float):String
	{
		if (PlayState.SONG.song == 'Bad-Nun' && BadNun.translate)
		{
			return new UnicodeString((!FlxG.save.data.botplay ? "スコア: "
				+ (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score)
				+ // Score
				" | 見逃した: "
				+ PlayState.misses
				+ // Misses/Combo Breaks
				" | 正確さ: "
				+ (FlxG.save.data.botplay ? "N/A" : (Math.isNaN(accuracy) ? 100 : FlxMath.roundDecimal(accuracy, 2)) + "%")
				+ // Accuracy
				" • "
				+ GenerateLetterRank(accuracy) : ""));
		}
		else
		{
			BadNun.translate = false;

			return (!FlxG.save.data.botplay ? "Score: "
				+ (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score)
				+ // Score
				" | Misses: "
				+ PlayState.misses
				+ // Misses/Combo Breaks
				" | Accuracy: "
				+ (FlxG.save.data.botplay ? "N/A" : (Math.isNaN(accuracy) ? 100 : FlxMath.roundDecimal(accuracy, 2)) + "%")
				+ // Accuracy
				" • "
				+ GenerateLetterRank(accuracy) : ""); // Letter Rank
		}
	}

	public static function wife3(maxms:Float, ts:Float)
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
