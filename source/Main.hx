package;

import cpp.vm.Gc;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.System;
import openfl.utils.AssetCache;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = InitState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop target

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var game = new FlxGame(1280, 720, initialState, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		fpsCounter = new FPS_MEM(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		toggleFPS(ClientPrefs.fps);

		#if desktop
		Application.current.window.onClose.add(function()
		{
			Discord.DiscordClient.shutdown();
		});
		#end
	}

	public static function clearCache()
	{
		Assets.cache.clear("songs");
		Assets.cache.clear("shared:images/characters");
		Assets.cache.clear("week");
	}

	public static function clearMemory(destroyMusic:Bool = true)
	{
		var destroyedCount:Int = 0;
		var c:AssetCache = cast openfl.utils.Assets.cache;

		if (destroyMusic)
		{
			if (FlxG.sound.music != null && destroyMusic)
				FlxG.sound.music.destroy();

			for (i in c.sound)
			{
				if (i != null)
				{
					i.close();
					destroyedCount++;
				}
			}

			c.sound.clear();
		}

		for (i in FlxG.sound.list)
		{
			if (i != null)
			{
				i.destroy();
				destroyedCount++;
			}
		}

		FlxG.sound.list.clear();

		@:privateAccess
		{
			for (i in c.bitmapData)
			{
				if (i != null)
				{
					i.dispose();
					destroyedCount++;
				}
			}

			c.bitmapData.clear();

			for (i in FlxG.bitmap._cache)
			{
				if (i != null)
				{
					i.destroy();
					destroyedCount++;
				}
			}

			FlxG.bitmap._cache.clear();
		}

		trace('Cache: Destroyed $destroyedCount assets.');
		System.gc();
	}

	var fpsCounter:FPS;

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		#if !mobile
		fpsCounter.visible = fpsEnabled;
		#end
	}

	public function changeFPSColor(color:FlxColor)
	{
		#if !mobile
		fpsCounter.textColor = color;
		#end
	}

	public function setFPSCap(cap:Int)
	{
		openfl.Lib.current.stage.frameRate = cap;
		FlxG.updateFramerate = cap;
		FlxG.drawFramerate = cap;
	}

	public function getFPSCap():Int
	{
		return ClientPrefs.fpsCap;
	}

	public function getFPS():Float
	{
		#if !mobile
		return fpsCounter.currentFPS;
		#else
		return openfl.Lib.current.stage.frameRate;
		#end
	}

	public static function playFreakyMenu(fade:Bool = true)
	{
		PlayState.skipDialogue = false;
		FlxG.sound.playMusic(Paths.music('freakyMenu'), fade ? 0 : 0.5);
		Conductor.changeBPM(120);

		if (fade)
			FlxG.sound.music.fadeIn(4, 0, 0.5);
	}
}

class FPS_MEM extends FPS
{
	override public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super(x, y, color);
		autoSize = NONE;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 13, color);
	}

	override function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		// if psych engine can get away with this so can i :)
		if (currentFPS > ClientPrefs.fpsCap)
			currentFPS = ClientPrefs.fpsCap;

		if (currentCount != cacheCount)
		{
			var mem:Float = Math.round(Gc.memInfo64(Gc.MEM_INFO_CURRENT) / 1000000);
			text = "FPS: " + currentFPS + '\nMem: ' + mem + 'MB';
		}

		cacheCount = currentCount;
	}
}
