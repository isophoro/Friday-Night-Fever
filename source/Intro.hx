package;

import flixel.FlxG;
import lime.app.Application;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

class Intro extends MusicBeatState
{
	override public function create():Void
	{
		FlxG.fixedTimestep = false;
		FlxG.sound.cache(Paths.music('freakyMenu'));

		FlxG.save.bind('funkin', 'ninjamuffin99');
		PlayerSettings.init();
		AchievementHandler.initGamejolt();
		ClientPrefs.load();
		Highscore.load();
		CostumeHandler.load();

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

		super.create();

		//SHADOW EXE STUFF

		/*var txt = 'shadow';
		var poop:String = Highscore.formatSong(txt, Difficulty.NORMAL);
		FlxG.mouse.visible = false;
		PlayState.SONG = Song.loadFromJson(poop, txt);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 2;
		PlayState.storyWeek = 0;
		LoadingState.loadAndSwitchState(new PlayState());*/

		FlxG.switchState(new TitleState());
	}
}
