package meta;

import flixel.FlxG;

enum CostumeName
{
	FEVER;
	FEVER_CASUAL; // DONE
	FEVER_MINUS; // DONE
	FEVER_NUN; // DONE
	FEVER_COAT;
	FEVER_ISO;
	TEASAR; // DONE
	CEABUN; // DONE
	FLU; // DONE
	DOODLE; // DONE
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

	public static function unlockCostume(costume:CostumeName)
	{
		trace("Unlocked Costume: " + CostumeHandler.data[costume].displayName);
		if (!unlockedCostumes.exists(costume))
			unlockedCostumes[costume] = 0;
	}

	public static function save()
	{
		FlxG.save.data.unlockedCostumes = unlockedCostumes;
		FlxG.save.flush();
	}

	public static function checkRequisites()
	{
		if (fullCombo(["milk-tea"]))
			unlockCostume(TEASAR);

		if (fullCombo(["hardships"]))
			unlockCostume(CEABUN);

		if (fullCombo(["mako", "vim", "retribution"]))
			unlockCostume(FEVER_CASUAL);

		if (fullCombo(["prayer", "bad-nun"]))
			unlockCostume(FEVER_NUN);

		if (fullCombo(["dui", "cosmic-swing", "cell-from-hell", "w00f"]))
			unlockCostume(DOODLE);

		if (fullCombo(["grando", "feel-the-rage"]))
			unlockCostume(FEVER_MINUS);

		save();
	}

	private static function fullCombo(songs:Array<String>):Bool
	{
		for (i in songs)
		{
			if (!Highscore.fullCombos.exists(i))
				return false;
		}

		return true;
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
			description: "Full combo all Week 2.5 songs",
			character: "bf-nun",
			creator: "MegaFreedom1274",
			characterOffset: [-5, -15]
		},
		FEVER_CASUAL => {
			displayName: "Fever (Casual Outfit)",
			description: "Full combo all Week 3 songs",
			character: "bf-casual",
			creator: "Kip",
			characterOffset: [1, 26]
		},
		FEVER_ISO => {
			displayName: "Fever (isophoro Outfit)",
			description: "???",
			character: "bf-iso",
			creator: "isophoro",
			characterOffset: [1, 21]
		},
		FEVER_MINUS => {
			displayName: "Fever (Minus Outfit)",
			description: "Full combo \"Minus Taki\" and \"Grando\"",
			character: "bf-minus",
			creator: "EMG",
			characterOffset: [-20, -30],
			camOffset: [-330, 35]
		},
		FEVER_COAT => {
			displayName: "Fever (Coat Outfit)",
			description: "Complete all achievements",
			character: "bf-coat",
			creator: "Circle",
			characterOffset: [-7, -19]
		},
		TEASAR => {
			displayName: "Teasar",
			description: "Full combo Milk Tea",
			character: "bf-teasar",
			creator: "Circle",
			characterOffset: [-70, -10],
			camOffset: [0, 60]
		},
		CEABUN => {
			displayName: "Ceabun",
			description: "Full combo Hardships",
			character: "ceabun",
			creator: "Circle",
			characterOffset: [0, -60]
		},
		DOODLE => {
			displayName: "Fever (Doodle Form)",
			description: "Full combo all Week Bone songs",
			character: "doodle",
			creator: "Roll",
			characterOffset: [35, 100]
		},
		FLU => {
			displayName: "Flu",
			description: "Achieve an accuracy of 41% or less in any song.",
			character: "flu",
			creator: "Pancho"
		}
	];
}
