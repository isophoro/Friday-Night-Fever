package;

import flixel.effects.postprocess.PostProcess;
import openfl.system.System;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

enum PreloadStrength
{
	NONE;
	LOW; // Preload songs
	HIGH; // Preload songs and characters
}

class Main extends Sprite
{
	public static var preloadType:PreloadStrength = NONE;
	public static var totalRam:Int = 0;

	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = Intro; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop target

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{

		// quick checks 

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
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = Intro;
		#end

		/*#if windows
		try {
			var process:sys.io.Process = new sys.io.Process("wmic ComputerSystem get TotalPhysicalMemory", null);
			totalRam = Math.round(Std.parseFloat(process.stdout.readAll().toString().split('\n')[1]) / Math.pow(1024, 3));
			trace('Total Ram : $totalRam GB');
		} 
		catch (e)
		{
			trace('Failed getting ram : $e');
		}
		#elseif mobile
		gameWidth = 1280;
		gameHeight = 720;
		zoom = 1;
		#end*/

		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		FlxG.console.registerClass(PlayState);
		FlxG.console.registerClass(MusicBeatState);

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		toggleFPS(FlxG.save.data.fps);
		#end
	}

	public static function clearCache()
	{
		Assets.cache.clear("songs");
		Assets.cache.clear("shared:images/characters");
		Assets.cache.clear("week");
	}

	public static function clearMemory()
	{
		@:privateAccess
		{
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj == null) continue;
	
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}
	}

	var game:FlxGame;

	var fpsCounter:FPS;

	public function toggleFPS(fpsEnabled:Bool):Void {
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

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		#if !mobile
		return fpsCounter.currentFPS;
		#else
		return openfl.Lib.current.stage.frameRate;
		#end
	}

	public static function playFreakyMenu()
	{
		PlayState.skipDialogue = false;
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		Conductor.changeBPM(90);
		
		FlxG.sound.music.fadeIn(4, 0, 0.7);
	}
}

class FPS_MEM extends FPS
{
	override public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super(x,y,color);
		autoSize = NONE;
	}

	override function __enterFrame(deltaTime:Float):Void
	{
		super.__enterFrame(deltaTime);
		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100)/100;

		text = "FPS: " + currentFPS + '\nMem: '+mem+'MB';
	}
}