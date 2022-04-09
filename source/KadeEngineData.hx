import Character.CostumeName;
import openfl.Lib;
import flixel.FlxG;

class KadeEngineData
{
    public static function initSave()
    {
		if (FlxG.save.data.unlockedCostumes == null)
		{
			trace("Setting up costume save data stuff");
            FlxG.save.data.unlockedCostumes = new Array<CostumeName>();
			FlxG.save.data.unlockedCostumes.push(Fever);
			FlxG.save.data.currentCostume = Fever;
		}

		if (FlxG.save.data.unlockedGFCostumes == null)
		{
			FlxG.save.data.unlockedGFCostumes = new Array<CostumeName>();
			FlxG.save.data.unlockedGFCostumes.push(Tea);
			FlxG.save.data.currentGFCostume = Tea;
		}

		if (FlxG.save.data.fcs == null)
            FlxG.save.data.fcs = new Array<String>();

		if (FlxG.save.data.popups == null)
            FlxG.save.data.popups = new Array<String>();
		
		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;
		
		if (FlxG.save.data.opponent == null)
			FlxG.save.data.opponent = false;

		if (FlxG.save.data.animeIntro == null)
			FlxG.save.data.animeIntro = true;

		if (FlxG.save.data.shaders == null)
			FlxG.save.data.shaders = true;
	
		if (FlxG.save.data.subtitles == null)
			FlxG.save.data.subtitles = true;

		if (FlxG.save.data.notesplash == null)
			FlxG.save.data.notesplash = true;

        if (FlxG.save.data.newInput == null)
			FlxG.save.data.newInput = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.brighterNotes == null)
			FlxG.save.data.brighterNotes = false;

		if (FlxG.save.data.disableModCamera == null)
			FlxG.save.data.disableModCamera = false; 

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine

		if (FlxG.save.data.disableModCharts == null)
			FlxG.save.data.disableModCharts = false;

		if (FlxG.save.data.laneTransparency == null)
			FlxG.save.data.laneTransparency = 0;
		
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null || FlxG.save.data.frames < 10)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = false;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;
		
		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = 0;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}