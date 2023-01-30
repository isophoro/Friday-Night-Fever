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
			FC_TUTORIAL, FC_WEEK1, FC_WEEK2, FC_WEEK2_5, FC_WEEK3, FC_WEEK4, FC_WEEK5, FC_WEEK6, FC_WEEK_HALLOW, FC_WEEK7, FC_WEEK8, FC_WEEK_ROLLDOG,
			PERFECT_PARRY, FC_ALL_OG_WEEKS, FC_ALL_FRENZY_WEEKS
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
		FC_TUTORIAL => "Full Combo Tutorial\n(\"Milk Tea\")",
		FC_WEEK1 => "Full Combo all Week 1 songs.",
		FC_WEEK2 => "Full Combo all Week 2 songs",
		FC_WEEK2_5 => "Full Combo all Week 2.5 songs",
		FC_WEEK3 => "Full Combo all Week 3 songs",
		FC_WEEK4 => "Full Combo all Week 4 songs",
		FC_WEEK5 => "Full Combo all Week 5 songs",
		FC_WEEK6 => "Full Combo all Week 6 songs",
		FC_ALL_OG_WEEKS => "Earn all previous Full Combo achievements",
		FC_WEEK_HALLOW => "Full Combo all Week ??? songs",
		FC_WEEK7 => "Full Combo all Week 7 songs",
		FC_WEEK8 => "Full Combo all Week 8",
		FC_WEEK_ROLLDOG => "Full Combo all Week 9 songs",
		ALL_ACHIEVEMENTS => "Complete all achievements",
		FC_ALL_FRENZY_WEEKS => "Earn all previous Full Combo achievements",
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

	public static function check()
	{
		if (fullCombo(StoryMenuState.weekData[0]))
			unlockTrophy(FC_TUTORIAL);

		if (fullCombo(StoryMenuState.weekData[1]))
			unlockTrophy(FC_WEEK1);

		if (fullCombo(StoryMenuState.weekData[2]))
			unlockTrophy(FC_WEEK2);

		if (fullCombo(StoryMenuState.weekData[3]))
			unlockTrophy(FC_WEEK2_5);

		if (fullCombo(StoryMenuState.weekData[4]))
			unlockTrophy(FC_WEEK3);

		if (fullCombo(StoryMenuState.weekData[5]))
			unlockTrophy(FC_WEEK4);

		if (fullCombo(StoryMenuState.weekData[6]))
			unlockTrophy(FC_WEEK5);

		if (fullCombo(StoryMenuState.weekData[7]))
			unlockTrophy(FC_WEEK6);

		if (fullCombo(StoryMenuState.weekData[8]))
			unlockTrophy(FC_WEEK_HALLOW);

		if (fullCombo(StoryMenuState.weekData[9]))
			unlockTrophy(FC_WEEK7);

		if (fullCombo(StoryMenuState.weekData[10]))
			unlockTrophy(FC_WEEK8);

		if (fullCombo(StoryMenuState.weekData[11]))
			unlockTrophy(FC_WEEK_ROLLDOG);

		if (hasTrophies([
			FC_TUTORIAL,
			FC_WEEK1,
			FC_WEEK2,
			FC_WEEK2_5,
			FC_WEEK3,
			FC_WEEK4,
			FC_WEEK5,
			FC_WEEK6
		]))
			unlockTrophy(FC_ALL_OG_WEEKS);

		if (hasTrophies([FC_WEEK_HALLOW, FC_WEEK7, FC_WEEK8, FC_WEEK_ROLLDOG]))
			unlockTrophy(FC_ALL_FRENZY_WEEKS);
	}

	private static function fullCombo(songs:Array<String>):Bool
	{
		for (i in songs)
		{
			if (!Highscore.fullCombos.exists(i))
				return false;
		}

		trace("FULL COMBO: " + songs);
		return true;
	}

	private static function hasTrophies(trophies:Array<Trophy>):Bool
	{
		for (i in trophies)
		{
			if (!ClientPrefs.curTrophies.exists(i))
				return false;
		}

		return true;
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
