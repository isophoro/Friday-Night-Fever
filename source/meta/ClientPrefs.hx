package meta;

import flixel.FlxG;

/**
 *  Taking this idea from Psych Engine since this feels a lot safer than accessing FlxG.save.data and guessing variables name in a dynamic object
 * 	(this is not a copy and paste of clientprefs from psych engine.)
 */
class ClientPrefs
{
	public static var keybinds(get, never):Array<String>;
	public static var leftBind = "A";
	public static var downBind = "S";
	public static var upBind = "W";
	public static var rightBind = "D";
	public static var killBind = "R";
	public static var dodgeBind = "SPACE";
	public static var resetButton:Bool = false;

	public static var playedShadow:Bool = false;

	public static var downscroll:Bool = false;
	public static var ghost:Bool = true;
	public static var offset:Int = 0;
	public static var modcharts:Bool = true;
	public static var scrollSpeed:Float = 1;
	public static var botplay:Bool = false;

	public static var laneTransparency:Int = 0;
	public static var showPrecision:Bool = true;
	public static var ratingX:Float = -1;
	public static var ratingY:Float = -1;
	public static var numX:Float = -1;
	public static var numY:Float = -1;
	public static var msX:Float = -1;
	public static var msY:Float = -1;

	public static var fpsCap:Int = 120;
	public static var antialiasing:Bool = true;
	public static var shaders:Bool = true;

	public static var songPosition:Bool = false;
	public static var subtitles:Bool = true;
	public static var notesplash = true;
	public static var brighterNotes:Bool = false;
	public static var fps:Bool = true;

	public static var curTrophies:Map<Int, Bool> = []; // using array breaks with flxsave
	public static var username:String = "";
	public static var userToken:String = "";
	public static var boombox:Bool = false;
	public static var songPitch:Float = 1;
	public static var randomNotes:Bool = false;
	public static var swapSides:Bool = false;
	public static var judgeScale:Float = 1;

	public static function get_keybinds():Array<String>
	{
		return [leftBind, downBind, upBind, rightBind];
	}

	public static function load()
	{
		trace("Loading ClientPrefs...");

		for (i in Type.getClassFields(ClientPrefs))
		{
			if (validField(i))
			{
				var reflected:Dynamic = Reflect.field(FlxG.save.data, i);
				if (reflected == null)
					continue;

				// this looks incredibly stupid and i know it is.
				// Doing Reflect.setField(ClientPrefs, i, reflected) will always return a FALSE value despite if reflected being true
				var boolStr = '$reflected';
				Reflect.setField(ClientPrefs, i, boolStr == "true" ? true : boolStr == "false" ? false : reflected);
			}
		}

		PlayerSettings.player1.controls.loadKeyBinds();

		(cast(openfl.Lib.current.getChildAt(0), Main)).setFPSCap(ClientPrefs.fpsCap);
	}

	public static function save()
	{
		for (i in Type.getClassFields(ClientPrefs))
		{
			if (validField(i))
			{
				var rf = Reflect.field(ClientPrefs, i);
				if (rf != null)
				{
					// trace('Saving $i ($rf)');
					Reflect.setField(FlxG.save.data, i, rf);
				}
			}
		}

		FlxG.save.flush();
	}

	inline static function validField(field:String)
	{
		return !Reflect.isFunction(Reflect.field(ClientPrefs, field)) && field != "keybinds";
	}
}
