package states.internal;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import lime.app.Application;
import sys.FileSystem;

using StringTools;

#if windows
import meta.Discord.DiscordClient;
#end

class InitState extends MusicBeatState
{
	override public function create():Void
	{
		loadSave();
		ClientPrefs.load();
		Highscore.load();
		AchievementHandler.initGamejolt();
		CostumeHandler.load();
		PlayerSettings.init();

		FlxG.mouse.visible = false;
		FlxG.fixedTimestep = false;

		FlxG.sound.cache(Paths.music('freakyMenu'));

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

		#if SHADOW_BUILD
		loadShadow();
		#else
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.6, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.6, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		if (FlxG.random.bool(0.2))
		{
			FlxG.stage.window.title = "Friday Night Fever: The Winkel Build";
		}

		FlxG.switchState(new TitleState());
		#end
	}

	private function loadSave()
	{
		FlxG.save.bind('frenzy', 'fnfever');

		if (FlxG.save.data.transferred == null)
		{
			var path = Sys.getEnv('AppData') + '/ninjamuffin99/funkin.sol';
			trace('[Save Compatibility] Checking $path for an old save file...');

			if (FileSystem.exists(path))
			{
				trace("[Save Compatibility] Found old save file!");
				var oldSave = new FlxSave();
				oldSave.bind('funkin', 'ninjamuffin99');

				var fields:Array<String> = Reflect.fields(oldSave.data);
				if (fields.contains("curCostume") && fields.contains("boombox"))
					FlxG.save.mergeDataFrom(oldSave.name, oldSave.path, false, false);

				oldSave.destroy();
			}
			else
			{
				trace("[Save Compatibility] No old save file found.");
			}

			FlxG.save.data.transferred = true;
		}
	}

	private function loadShadow()
	{
		FlxG.stage.window.title = " ";

		var poop:String = Highscore.formatSong('shadow', Difficulty.NORMAL);
		PlayState.SONG = Song.loadFromJson(poop, 'shadow');
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 2;
		PlayState.storyWeek = 0;

		LoadingState.loadAndSwitchState(new PlayState());
	}
}
