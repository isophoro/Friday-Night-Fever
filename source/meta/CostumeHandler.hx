package meta;

import flixel.FlxG;

enum CostumeName
{
	FEVER;
	FEVER_CASUAL;
	FEVER_MINUS;
	FEVER_NUN;
	FEVER_COAT;
	TEASAR;
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
	public static var unlockedCostumes:Map<CostumeName, Int> = [FEVER => 0];
	public static var curCostume:CostumeName = FEVER;

	public static function load()
	{
		if (FlxG.save.data.unlockedCostumes != null)
		{
			unlockedCostumes = FlxG.save.data.unlockedCostumes;

			if (!unlockedCostumes.exists(FEVER))
				unlockedCostumes[FEVER] = 0;
		}
	}

	public static function save()
	{
		FlxG.save.data.unlockedCostumes = unlockedCostumes;
		FlxG.save.flush();
	}

	public static final data:Map<CostumeName, CostumeInfo> = [
		FEVER => {
			displayName: "Fever",
			description: "Mayor of Fever Town",
			character: "bf",
			creator: "Kip"
		},
		FEVER_NUN => {
			displayName: "Fever (Nun Outfit)",
			description: "Full combo Week 2.5 in Story Mode",
			character: "bf-nun",
			creator: "MegaFreedom1274",
			characterOffset: [0, -55]
		},
		FEVER_CASUAL => {
			displayName: "Fever (Casual Outfit)",
			description: "Full combo Week 3 in Story Mode",
			character: "bf-casual",
			creator: "Kip",
			characterOffset: [1, -9]
		},
		FEVER_MINUS => {
			displayName: "Fever (Minus Outfit)",
			description: "Full combo \"Minus Taki\" and \"Grando\"",
			character: "bf-minus",
			creator: "EMG",
			characterOffset: [-20, -70]
		},
		FEVER_COAT => {
			displayName: "Fever (Coat Outfit)",
			description: "Complete all achievements",
			character: "bf-coat",
			creator: "Circle",
			characterOffset: [-7, -59]
		},
		TEASAR => {
			displayName: "Teasar",
			description: "FC Tutorial",
			character: "bf-teasar",
			creator: "Circle",
			characterOffset: [-80, -40]
		}
	];
}
