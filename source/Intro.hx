package;

import flixel.FlxG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

#if cpp
import sys.thread.Thread;
#end

using StringTools;

class Intro extends MusicBeatState
{
	#if (cpp && !mobile)
	var video:MP4Handler = new MP4Handler();
	#end

	var preloading:Bool = false;
	var curLoaded:Int = 0;
	var maxToLoad:Int = 0;

	override public function create():Void
	{
		FlxG.fixedTimestep = false;
		FlxG.sound.cache(Paths.music('freakyMenu'));

		FlxG.save.bind('funkin', 'ninjamuffin99');
		PlayerSettings.init();
		KadeEngineData.initSave();
		Options.checkSaveCompatibility();
		Highscore.load();

		@:privateAccess
		FlxG.sound.loadSavedPrefs();

		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end

		#if mobile
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end
		
		#if (sys && !mobile)
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end

		super.create();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		if (#if sys Sys.args().contains("-disableIntro") ||#end !FlxG.save.data.animeIntro)
		{
			FlxG.switchState(new TitleState());
		}
		else
		{
			#if FREEPLAY
			FlxG.switchState(new FreeplayState());
			#elseif CHARTING
			FlxG.switchState(new ChartingState());
			#elseif (cpp && !mobile)
			video.playMP4(Paths.video('animeintrofinal'));
			video.finishCallback = finishCallback;
			#else
			FlxG.switchState(new TitleState());
			#end
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		#if (cpp && !mobile)
		video.preloading = preloading;
		#end
	}

	function finishCallback()
	{
		if (!preloading)
			FlxG.switchState(new TitleState());
		else
		{
			#if (cpp && !mobile)
			video.playMP4(Paths.video('animeintrofinal'));
            video.finishCallback = finishCallback;
			#end
		}
	}
}