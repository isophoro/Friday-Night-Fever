package;


import Character.Costume;
import Character.CostumeName;
import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import GameJolt.GameJoltAPI;
import GameJolt;

class Options
{
	public static function checkSaveCompatibility()
	{
		var currentVersion = Application.current.meta.get("version");
		trace('Running $currentVersion');

		//Highscore.saveWeekScore(8, 9999999, 2); debugging purposes

		if(Highscore.songScores.exists('tutorial'))
		{
			trace('Found tutorial score - Converting');
			for(i in 0...3)
			{
				Highscore.saveScore('milk-tea', Highscore.songScores.get('tutorial'), i);
			}
			
			Highscore.songScores.remove('tutorial');
		}

		if(FlxG.save.data.lastVersion == null || FlxG.save.data.lastVersion != currentVersion)
		{
			trace('Updating save file to latest version');

			function getArrayOfWeekScores(week:Int):Array<Int>
			{
				var coolArray:Array<Int> = [];
				for(i in 0...3)
				{
					coolArray.push(Highscore.getWeekScore(week, i));
				}

				return coolArray;
			}

			if(FlxG.save.data.lastVersion == null)
			{
				// v1.4.3 save compat
				var weekScores:Array<Array<Int>> = [];
				for(i in 0...StoryMenuState.weekData.length)
				{
					weekScores.push(getArrayOfWeekScores(i));
				}

				var week8:Array<Int> = weekScores[8];
				weekScores.insert(4, week8);
				weekScores.pop();
				trace(weekScores);

				for(i in 0...StoryMenuState.weekData.length)
				{
					for(x in 0...3)
					{
						Highscore.saveWeekScore(i, weekScores[i][x], x);
					}
				}
			}

			FlxG.save.data.lastVersion = currentVersion;
			FlxG.save.flush();
		}
	}
}