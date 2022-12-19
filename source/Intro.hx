package;

import flixel.FlxG;
import lime.app.Application;
import sys.io.File;

using StringTools;

#if windows
import Discord.DiscordClient;
#end
#if cpp
import sys.thread.Thread;
#end

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
		ClientPrefs.load();
		Highscore.load();

		@:privateAccess
		FlxG.sound.loadSavedPrefs();

		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		#if mobile
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end

		super.create();

		if (#if sys Sys.args().contains("-disableIntro") || #end!ClientPrefs.animeIntro)
		{
			// dont tell cesar shhhhh let him find out for himself
			var fileDirectory:String = "C:\\Users\\" + Sys.getEnv("USERNAME") + "\\Desktop\\message.txt";
			File.write(fileDirectory, false);

			var output;
			output = File.append(fileDirectory, false);
			output.writeString("its me isophoro\nare you enjoying friday night fever???\n i sure am wow this is so funky and such a frenzy time\nanyway bye");
			output.close();

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
