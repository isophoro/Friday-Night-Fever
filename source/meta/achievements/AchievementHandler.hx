package meta.achievements;

import flixel.addons.api.FlxGameJolt;

@:enum abstract Trophy(Int) from Int to Int
{
	public static var order(get, never):Array<Trophy>;
	inline var PERFECT_PARRY:Trophy = 181530;
	inline var FC_TUTORIAL:Trophy = 181528;
	inline var FC_WEEK1:Trophy = 181517;
	inline var FC_WEEK2:Trophy = 181518;
	inline var FC_WEEK2_5:Trophy = 181560;
	inline var FC_WEEK3:Trophy = 181519;
	inline var FC_WEEK4:Trophy = 181569;
	inline var FC_WEEK5:Trophy = 181577;
	inline var FC_WEEK6:Trophy = 0;
	inline var FC_WEEK_HALLOW:Trophy = 181522;
	inline var FC_WEEK7:Trophy = 181520;
	inline var FC_WEEK8:Trophy = 181520;
	inline var FC_WEEK_ROLLDOG:Trophy = 181520;
	inline var FC_ALL_OG_WEEKS:Trophy = 181521;
	inline var FC_ALL_FRENZY_WEEKS:Trophy = 181529;

	private static function get_order():Array<Trophy>
	{
		return [
			FC_TUTORIAL, FC_WEEK1, FC_WEEK2, FC_WEEK3, FC_WEEK4, FC_WEEK5, FC_WEEK6, FC_WEEK_HALLOW, FC_WEEK7, FC_WEEK8, FC_WEEK_ROLLDOG, PERFECT_PARRY,
			FC_ALL_OG_WEEKS, FC_ALL_FRENZY_WEEKS
		];
	}
}

class AchievementHandler
{
	public static function initGamejolt()
	{
		var byteData = new APIKeys();
		var keys = byteData.readUTFBytes(byteData.length).split("\n");

		if (keys[1] == null)
		{
			return trace("Invalid Gamejolt Keys! Trophies will not be earnable during this session.");
		}

		trace("Found Gamejolt Keys! Game ID: " + keys[0]);

		FlxGameJolt.init(Std.parseInt(keys[0]), keys[1], false);

		if (ClientPrefs.username.length > 0)
		{
			loginToGamejolt();
		}
	}

	public static function loginToGamejolt(?callback:Dynamic)
	{
		if (FlxGameJolt.initialized)
			FlxGameJolt.resetUser(ClientPrefs.username, ClientPrefs.userToken, callback);
		else
			FlxGameJolt.authUser(ClientPrefs.username, ClientPrefs.userToken, callback);

		if (!FlxGameJolt.initialized)
			return;

		FlxGameJolt.fetchTrophy(FlxGameJolt.TROPHIES_MISSING, (map:Map<String, String>) ->
		{
			trace(map);
		});
	}

	public static function getFCTrophy(curWeek:Int)
	{
		return switch (curWeek)
		{
			default: FC_TUTORIAL;
			case 1: FC_WEEK1;
			case 2: FC_WEEK2;
			case 3: FC_WEEK2_5;
			case 4: FC_WEEK3;
			case 5: FC_WEEK4;
			case 6: FC_WEEK5;
			case 7: FC_WEEK6;
			case 8: FC_WEEK_HALLOW;
			case 9: FC_WEEK7;
			case 10: FC_WEEK8;
			case 11: FC_WEEK_ROLLDOG;
		}
	}

	public static function unlockTrophy(trophy:Trophy)
	{
		//
	}
}
