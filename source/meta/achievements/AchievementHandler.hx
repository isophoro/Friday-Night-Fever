package meta.achievements;

import flixel.addons.api.FlxGameJolt;

@:enum abstract Trophy(Int) from Int to Int
{
	public static var order(get, never):Array<Trophy>;
	inline var TEST_TROPHY:Trophy = 183674;
	inline var PERFECT_PARRY:Trophy = 181530;
	inline var FC_TUTORIAL:Trophy = 181528;
	inline var FC_WEEK1:Trophy = 181517;
	inline var FC_WEEK2:Trophy = 181518;
	inline var FC_WEEK2_5:Trophy = 181560;
	inline var FC_WEEK3:Trophy = 181519;
	inline var FC_WEEK4:Trophy = 181569;
	inline var FC_WEEK5:Trophy = 181577;
	inline var FC_WEEK6:Trophy = 181578;
	inline var FC_WEEK_HALLOW:Trophy = 181522;
	inline var FC_WEEK7:Trophy = 181520;
	inline var FC_WEEK8:Trophy = 181579;
	inline var FC_WEEK_ROLLDOG:Trophy = 181580;
	inline var FC_ALL_OG_WEEKS:Trophy = 181521;
	inline var FC_ALL_FRENZY_WEEKS:Trophy = 181529;
	inline var ALL_ACHIEVEMENTS:Trophy = 183722;

	private static function get_order():Array<Trophy>
	{
		return [
			FC_TUTORIAL, FC_WEEK1, FC_WEEK2, FC_WEEK3, FC_WEEK4, FC_WEEK5, FC_WEEK6, FC_WEEK_HALLOW, FC_WEEK7, FC_WEEK8, FC_WEEK_ROLLDOG, PERFECT_PARRY,
			FC_ALL_OG_WEEKS, FC_ALL_FRENZY_WEEKS
		];
	}

	public static var names:Map<Int, String> = [
		FC_TUTORIAL => "Miracle",
		FC_WEEK1 => "Sticky Situation!",
		FC_WEEK2 => "Sweet and Sour!",
		FC_WEEK2_5 => "Taki's Revenge!",
		FC_WEEK3 => "Meloncholy!",
		FC_WEEK4 => "Bunni Murder!",
		FC_WEEK5 => "Dinner Time!",
		FC_WEEK6 => "God Damn!",
		FC_ALL_OG_WEEKS => "Classic: 100%",
		FC_WEEK_HALLOW => "No More Ghosts!",
		FC_WEEK7 => "Robots Invade!",
		FC_WEEK8 => "Time Travel Trouble!",
		FC_WEEK_ROLLDOG => "Safe Driving!",
		FC_ALL_FRENZY_WEEKS => "Frenzy: 100%",
		ALL_ACHIEVEMENTS => "Mayor of the Town",
		PERFECT_PARRY => "Robot Reflexes"
	];
	public static var descriptions:Map<Int, String> = [
		FC_TUTORIAL => "Full Combo Tutorial\n(Story Mode Only)\nUnlocks \"Teasar\" costume.",
		FC_WEEK1 => "Full Combo Week 1\n(Story Mode Only)\nUnlocks \"Ceabun\" costume.",
		FC_WEEK2 => "Full Combo Week 2\n(Story Mode Only)",
		FC_WEEK2_5 => "Full Combo Week 2.5\n(Story Mode Only)\nUnlocks \"Nun\" costume.",
		FC_WEEK3 => "Full Combo Week 3\n(Story Mode Only)\nUnlocks \"Casual\" costume.",
		FC_WEEK4 => "Full Combo Week 4\n(Story Mode Only)",
		FC_WEEK5 => "Full Combo Week 5\n(Story Mode Only)",
		FC_WEEK6 => "Full Combo Week 6\n(Story Mode Only)\nUnlocks \"Old Fever\" costume.",
		FC_ALL_OG_WEEKS => "Earn all Full Combo achievements\n(Week 1 - 6)\nUnlocks \"Birthday Build\" costume.",
		FC_WEEK7 => "Full Combo Week 7\n(Story Mode Only)",
		FC_WEEK8 => "Full Combo Week 8\n(Story Mode Only)",
		FC_WEEK_ROLLDOG => "Full Combo Week 9\n(Story Mode Only)\nUnlocks \"Doodle\" costume.",
		ALL_ACHIEVEMENTS => "Complete all achievements\nUnlocks \"Coat\" costume.",
		FC_ALL_FRENZY_WEEKS => "Earn all Full Combo achievements\n(Week ??? - 9)",
		PERFECT_PARRY => "Hit a perfect parry once\nin Dead Man's Melody"
	];
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
		{
			FlxGameJolt.resetUser(ClientPrefs.username, ClientPrefs.userToken, _logIn.bind(callback));
		}
		else
			FlxGameJolt.authUser(ClientPrefs.username, ClientPrefs.userToken, _logIn.bind(callback));
	}

	public static function getUsername():String
	{
		return FlxGameJolt.username.toLowerCase() == "no user" || FlxGameJolt.username == null ? null : FlxGameJolt.username;
	}

	private static function _logIn(?callback:Dynamic)
	{
		if (callback != null)
			callback();
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

	public static function hasTrophy(trophy:Trophy)
	{
		return ClientPrefs.curTrophies.exists(trophy);
	}

	public static function unlockTrophy(trophy:Trophy)
	{
		if (ClientPrefs.curTrophies[trophy] != null)
			return;

		trace('Unlocked trophy! (ID: ${trophy})');
		ClientPrefs.curTrophies[trophy] = true;
		if (FlxGameJolt.initialized)
		{
			FlxGameJolt.addTrophy(trophy);
		}

		ClientPrefs.save();
	}
}
