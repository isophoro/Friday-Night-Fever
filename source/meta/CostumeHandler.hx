package meta;

import flixel.FlxG;

enum CostumeName
{
	FEVER;
	FEVER_CASUAL;
}

typedef CostumeInfo =
{
	displayName:String,
	character:String,
	description:String,
	creator:String,
	?camOffset:Array<Float>,
	?characterOffset:Array<Float>
}

class CostumeHandler
{
	// Using maps because im scared of the save file killing itself from an array
	public static var unlockedCostumes:Map<String, Int> = new Map();

	public static function load()
	{
		if (FlxG.save.data.unlockedCostumes != null)
		{
			unlockedCostumes = FlxG.save.data.unlockedCostumes;
		}
	}

	public static function save()
	{
		FlxG.save.data.unlockedCostumes = unlockedCostumes;
		FlxG.save.flush();
	}

	public static final costumes:Map<CostumeName, CostumeInfo> = [
		FEVER => {
			displayName: "Fever",
			description: "Mayor of Fever Town",
			character: "bf",
			creator: "Kip"
		},
		FEVER_CASUAL => {
			displayName: "Fever (Casual)",
			description: "On Hard difficulty, full combo Week 3. (Story Mode)",
			character: "bf-casual",
			creator: "Kip"
		}
	];

	public static final FEVER_LIST:Array<CostumeName> = [FEVER, FEVER_CASUAL]; // Organized list for costume menu

	public static function getFormattedCharacter()
	{
		var variant:String = "";

		variant += switch (PlayState.SONG.song.toLowerCase())
		{
			case 'down-bad' | 'bazinga' | 'crucify' | 'retribution' | 'farmed' | 'throw-it-back' | 'party-crasher': "demon";
			case 'ur-girl' | 'chicken-sandwich' | 'space-demons' | 'funkin-god': "pixel";
			default: "";
		}
	}
}
