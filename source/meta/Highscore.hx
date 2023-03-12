package meta;

import flixel.FlxG;

class Highscore
{
	public static var fullCombos:Map<String, Int> = new Map();

	public static function save()
	{
		FlxG.save.data.fullCombos = fullCombos;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int = -1):String
	{
		var str = StringTools.replace(song, " ", "");
		return diff < Difficulty.DIFFICULTY_MIN ? str : str + (Difficulty.data[diff].chartSuffix == null ? "" : Difficulty.data[diff].chartSuffix);
	}

	public static function load():Void
	{
		if (FlxG.save.data.fullCombos != null)
		{
			fullCombos = FlxG.save.data.fullCombos;
		}
	}
}
