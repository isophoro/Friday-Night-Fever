package meta;

import flixel.FlxG;
import meta.achievements.AchievementHandler;

enum CostumeName
{
	FEVER;
	FEVER_CASUAL; // DONE
	FEVER_MINUS; // DONE
	FEVER_NUN; // DONE
	FEVER_COAT; // DONE
	FEVER_ISO; // DONE
	TEASAR; // DONE
	CEABUN; // DONE
	FLU; // DONE
	DOODLE; // DONE
	CLASSIC; // DONE
	BIRTHDAY_BUILD;
	TANNER;
	CEDAR; // DONE
	MCDIETIS; // DONE
	SKELLY; // DONE
	SHELTON; // DONE
	MTALE; // DONE
	SOULSPLIT; // DONE
	MONGUS; // DONE
}

typedef CostumeInfo =
{
	displayName:String,
	character:String,
	description:String,
	creator:String,
	?camOffset:Array<Float>,
	?characterOffset:Array<Float>,
	?unlocked:Bool
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

		if (FlxG.save.data.curCostume != null)
			curCostume = FlxG.save.data.curCostume;

		for (k => v in data) // Unlock all costumes with "unlocked" field set to true
			if (v.unlocked && unlockedCostumes[k] == null)
				unlockedCostumes[k] = 0;
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
		FlxG.save.data.curCostume = curCostume;
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

		if (fullCombo(["tranquility", "princess", "crack", "bloom"]))
			unlockCostume(SOULSPLIT);

		if (fullCombo(["mild", "spice", "party-crasher"]))
			unlockCostume(MONGUS);

		if (fullCombo(["ur-girl", "chicken-sandwich", "funkin-god"]))
			unlockCostume(MTALE);

		if (fullCombo(["space-demons"]))
			unlockCostume(BIRTHDAY_BUILD);

		if (fullCombo(["dui"]))
			unlockCostume(MCDIETIS);

		if (fullCombo(["dui", "cosmic-swing", "cell-from-hell", "w00f"]))
			unlockCostume(DOODLE);

		if (fullCombo(["grando", "feel-the-rage"]))
			unlockCostume(FEVER_MINUS);

		if (AchievementHandler.hasTrophy(ALL_ACHIEVEMENTS))
			unlockCostume(FEVER_COAT);

		if (AchievementHandler.hasTrophy(FC_ALL_OG_WEEKS))
			unlockCostume(CLASSIC);

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
			description: "",
			character: "bf-iso",
			creator: "isophoro",
			characterOffset: [1, 21]
		},
		FEVER_MINUS => {
			displayName: "Fever (Minus Outfit)",
			description: "Full combo \"Feel the Rage\" and \"Grando\"",
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
			camOffset: [0, 45]
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
		},
		CLASSIC => {
			displayName: "Fever (Classic)",
			description: "Full combo Weeks 1 - 6",
			character: "bf-classic",
			creator: "Kip",
			characterOffset: [0, 30]
		},
		SKELLY => {
			displayName: "Skelly (FNFever)",
			description: "",
			character: "skelly",
			creator: "Skelly",
			unlocked: true,
			characterOffset: [-10, -10],
			camOffset: [-50, -10]
		},
		SHELTON => {
			displayName: "Fever (Shelton Outfit)",
			description: "",
			character: "shelton",
			creator: "No-Mi",
			unlocked: true,
			characterOffset: [5, 27],
			camOffset: [-50, -5]
		},
		MCDIETIS => {
			displayName: "Fever (McDietis Outfit)",
			description: "Full Combo \"DUI\"",
			character: "mcdietis",
			creator: "Pancho",
			unlocked: true,
			characterOffset: [-10, -5]
		},
		CEDAR => {
			displayName: "Cedar",
			description: "",
			character: "bf-cedar",
			creator: "No-Mi",
			characterOffset: [0, -100],
			unlocked: true
		},
		MONGUS => {
			displayName: "Fever (mongus)",
			description: "Full combo all Week 5 songs",
			character: "mongus",
			creator: "Kip",
			characterOffset: [-125, 250],
			camOffset: [0, -30]
		},
		SOULSPLIT => {
			displayName: "Fever (Rae's Outfit)",
			description: "Full combo all Week 8 songs",
			character: "soulsplit",
			creator: "Roll",
			characterOffset: [20, -15]
		},
		MTALE => {
			displayName: "Fever (M-Tale)",
			description: "Full combo all Week 6 songs",
			character: "mtale",
			creator: "TheCouchPotato170",
			characterOffset: [-20, 15]
		},
		TANNER => {
			displayName: "Tanner",
			description: "",
			character: "tanner",
			unlocked: true,
			creator: "Circle",
			characterOffset: [0, 40]
		},
		BIRTHDAY_BUILD => {
			displayName: "Fever (Birthday Build)",
			description: "Full combo \"Space Demons\"",
			character: "bday",
			creator: "Rosamay",
			characterOffset: [-10, -10]
		}
	];
}
