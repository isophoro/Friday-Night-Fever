package meta;

import flixel.FlxG;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map();
	public static var fullCombos:Map<String, Int> = new Map();

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		if (ClientPrefs.botplay)
		{
			trace('Botplay is enabled. Score saving is disabled.');
			return;
		}

		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		if (ClientPrefs.botplay)
		{
			trace('Botplay is enabled. Score saving is disabled.');
			return;
		}

		var daWeek:String = formatSong('week' + week, diff);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.data.fullCombos = fullCombos;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int = -1):String
	{
		var str = StringTools.replace(song, " ", "");
		return diff < Difficulty.DIFFICULTY_MIN ? str : str + (Difficulty.data[diff].chartSuffix == null ? "" : Difficulty.data[diff].chartSuffix);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}

		if (FlxG.save.data.fullCombos != null)
		{
			fullCombos = FlxG.save.data.fullCombos;
		}
	}
}
