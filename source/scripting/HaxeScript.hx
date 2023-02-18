package scripting;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint.FlxBasePoint as FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flxanimate.FlxAnimate;
import hscript.Interp;
import hscript.Parser;
import shaders.ScreenMultiply;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 *  the scripting stuff for the mod's a little wack, i know how to implement hscript stuff a lot better now so ignore my old take on it :)
 */
class HaxeScript extends Interp implements IFlxDestroyable
{
	static final AUTOIMPORTS:Array<Class<Dynamic>> = [
		Math, Std, FlxG, FlxSprite, FlxTween, FlxEase, Conductor, Paths, ClientPrefs, Character, FlxAnimate
	];

	static final BLOCKED_IMPORTS:Array<String> = ["AchievementHandler", "APIKeys", "FlxGameJolt", "Highscore", "CostumeHandler"];

	static var functions(default, never):Map<String, Dynamic> = [
		"add" => (item:flixel.FlxBasic, pos:Int = -1, ?camera:flixel.FlxCamera) ->
		{
			if (camera != null)
				item.cameras = [camera];
			if (pos != -1)
			{
				PlayState.instance.insert(pos, item);
			}
			else
			{
				PlayState.instance.add(item);
			}
		},
		"remove" => (item:flixel.FlxBasic, ?destroy:Bool) ->
		{
			PlayState.instance.remove(item);
			if (destroy)
				item.destroy();
		},
		"createBackdrop" => (img:String, spacingX:Int = 0, spacingY:Int = 0, repeatY:Bool = false) ->
		{
			// doing new FlxBackdrop contains evil enums in the constructor so we cant do that in hscript
			return new FlxBackdrop(img, repeatY ? XY : X, spacingX, spacingY);
		},
		"tween" => FlxTween.tween,
		"setNoteX" => (x:Float, num:Int) ->
		{
			PlayState.strumLineNotes.members[num].x = x;
		},
		"setNoteY" => (y:Float, num:Int) ->
		{
			PlayState.strumLineNotes.members[num].y = y;
		},
		"setNoteAngle" => (angle:Float, num:Int) ->
		{
			PlayState.strumLineNotes.members[num].angle = angle;
		},
		"setNoteProperty" => (note:Note, property:String, val:Dynamic) ->
		{
			Reflect.setField(note.properties, property, val);
		},
		"getNoteProperty" => (note:Note, property:String) ->
		{
			return Reflect.field(note.properties, property);
		},
		"getIndexOfMember" => (item:flixel.FlxBasic) ->
		{
			return PlayState.instance.members.indexOf(item);
		},
		"snapCamera" => (?pos:FlxPoint) ->
		{
			if (pos != null)
			{
				PlayState.instance.camFollow.setPosition(pos.x, pos.y);
			}
			var camFollow = PlayState.instance.camFollow;
			PlayState.instance.camGame.focusOn(pos == null ? new FlxPoint(camFollow.x, camFollow.y) : pos);
		},
		"getSong" => (field:String) ->
		{
			return Reflect.field(PlayState.SONG, field);
		}
	];

	public var parser:Parser;
	public var label:String = "";
	public var updatableVars:Array<String> = [];
	public var ownedGlobals:Array<String> = [];
	public var parentGrp:HScriptGroup = null;

	public function new(?path:String, label:String = "")
	{
		super();

		if (path == null)
			path = "assets/data/" + PlayState.SONG.song.toLowerCase() + "/modchart.hx";

		if (!FileSystem.exists(path))
		{
			return;
		}

		if (label.length > 0)
		{
			this.label = label;
		}

		setupVariables();
		updateVars();

		parser = new Parser();
		parser.allowJSON = parser.allowTypes = true;

		var rawCode = handleImports(File.getContent(path));
		try
		{
			execute(parser.parseString(rawCode));
		}
		catch (e)
		{
			trace(e);
			FlxG.stage.application.window.alert('${e.stack}\n${e.details}', "HScript Compile Time Error");
		}
	}

	function handleImports(rawCode:String)
	{
		var code:String = "";
		var modules:Array<hscript.Expr.ModuleDecl> = [];
		var s = rawCode.split(";");

		// Checks if there's any lines that start with import and matches the following regex
		for (i in 0...s.length)
		{
			s[i] = s[i].trim();
			if (s[i].startsWith("import") && ~/[A - Za - z.]/.match(s[i]) && !s[i].contains("("))
			{
				code += s[i] + ';';
			}
			else
			{
				break;
			}
		}

		// If no import lines are found, return the original unedited code.
		if (code.length <= 0)
			return rawCode;

		// but if import lines are found, parse them through parseModule() and add them.
		try
		{
			modules = parser.parseModule(code);
		}
		catch (e)
		{
			FlxG.stage.window.alert("Failed parsing modules:\n" + code, "HScript Compile Time Error");
		}

		for (i in modules)
		{
			var pckge = (cast i.getParameters()[0] : Array<String>);
			var isEnum = Type.resolveEnum(pckge.join("."));
			if (BLOCKED_IMPORTS.contains(pckge[pckge.length - 1]))
			{
				FlxG.stage.window.alert("Blocked import: " + pckge[pckge.length - 1], "HScript Blocked Import Warning");
				continue;
			}
			variables.set(pckge[pckge.length - 1], isEnum == null ? Type.resolveClass(pckge.join(".")) : isEnum);
			s.shift();
		}

		return s.join(";");
	}

	function setupVariables()
	{
		variables.set("setGlobalVar", (name:String, obj:Dynamic) ->
		{
			trace("Setting global var: " + name);
			if (parentGrp != null)
			{
				parentGrp.globalVars.set(name.trim(), obj);
				ownedGlobals.push(name);
			}
		});

		variables.set("getGlobalVar", (name:String) ->
		{
			name = name.trim();
			if (parentGrp != null && parentGrp.globalVars.exists(name))
			{
				return parentGrp.globalVars.get(name);
			}
			else
			{
				trace("Cannot find global var: " + name);
				return null;
			}
		});

		// Import all non-static fields from PlayState
		for (i in Reflect.fields(PlayState.instance))
		{
			if (!variables.exists(i))
			{
				var reflected = Reflect.field(PlayState.instance, i);
				variables.set(i, reflected);

				// Push non-object variables into an array to update them automatically ( updateVars(); )
				if (reflected is Int || reflected is Bool || reflected is Float || reflected is String)
				{
					updatableVars.push(i);
				}
			}
		}

		// Import all static fields from PlayState
		for (i in Reflect.fields(PlayState))
		{
			if (!variables.exists(i))
			{
				var reflected = Reflect.field(PlayState, i);
				variables.set(i, reflected);
			}
		}

		// Import all classes from the AUTOIMPORTS const
		for (i in AUTOIMPORTS)
		{
			var split:Array<String> = Type.getClassName(i).split('.');
			variables.set(split[split.length - 1], i);
		}

		for (k => v in functions)
			variables.set(k, v);

		// set up work arounds for abstract classes
		variables.set("MP4Handler", #if (hxCodec >= "2.6.0") VideoHandler #else MP4Handler #end);
		variables.set("FlxPoint", #if (flixel < "5.0.0") FlxPoint #else flixel.math.FlxPoint.FlxBasePoint #end);
		variables.set("FlxColor", HScriptColorAccess);
		var tweenTypes:Dynamic = {
			PINGPONG: 4,
			BACKWARD: 16,
			LOOPING: 2,
			ONESHOT: 8,
			PERSIST: 1
		};

		variables.set("FlxTweenType", tweenTypes);

		variables.set("import", (classStr:String) ->
		{
			var split:Array<String> = classStr.split('.');
			trace("(Deprecated) Importing class: " + split[split.length - 1]);
			variables.set(split[split.length - 1], Type.resolveClass(classStr));
		});

		variables.set("game", FlxG.state);

		if (PlayState.strumLineNotes != null && PlayState.strumLineNotes.members != null)
		{
			variables.set("strumLineNotes", PlayState.strumLineNotes.members); // WHY ARE THESE STATIC!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			variables.set("playerStrums", PlayState.playerStrums.members); // WHO HURT YOU KADE ENGINE
			variables.set("cpuStrums", PlayState.cpuStrums.members);

			for (i in 0...PlayState.strumLineNotes.length)
			{
				if (PlayState.strumLineNotes.members[i] == null)
					continue;

				var babyArrow = PlayState.strumLineNotes.members[i];
				if (variables.exists("defaultStrumPos"))
					variables.get("defaultStrumPos")[i] = new FlxPoint(babyArrow.x, babyArrow.y);
				else
					variables.set("defaultStrumPos", [new FlxPoint(babyArrow.x, babyArrow.y)]);
			}
		}

		variables.set("assignShader", (item:flixel.FlxSprite, shader:String) ->
		{
			switch (shader)
			{
				case "BWShader":
					// Not sure how this works it mighhttt have something to do with DCE?
					// but when i remove this line this shader does NOT work at all when imported into the bloom modchart
					item.shader = new shaders.BWShader();
				case "SolidColorShader":
					item.shader = new shaders.BadNun.SolidColorShader();
				case "Scanline":
					item.shader = new shaders.Scanline();
				case "CRTBend":
					item.shader = new shaders.CRTBend();
				case "ScreenMultiply":
					item.shader = new shaders.ScreenMultiply();
				default:
					item.shader = null;
			}
		});
	}

	public function updateVars()
	{
		for (i in updatableVars)
		{
			var reflected = Reflect.field(PlayState.instance, i);
			if (variables[i] != reflected)
				variables.set(i, reflected);
		}
	}

	public function callFunction(func:String, ?args:Array<Dynamic>)
	{
		if (variables[func] != null)
		{
			try
			{
				if (args != null)
					Reflect.callMethod(null, cast variables[func], args);
				else
					variables[func]();
			}
			catch (e)
			{
				trace('Script Error ($label): Failed calling function $func. Error: $e');
			}
		}
	}

	public function destroy()
	{
		for (k in variables.keys())
			variables[k] = null;

		updatableVars = [];

		if (parentGrp != null)
		{
			parentGrp.grp.remove(this);
		}
	}
}

class HScriptColorAccess
{
	public static var TRANSPARENT:FlxColor = 0x00000000;
	public static var WHITE:FlxColor = 0xFFFFFFFF;
	public static var GRAY:FlxColor = 0xFF808080;
	public static var BLACK:FlxColor = 0xFF000000;
	public static var GREEN:FlxColor = 0xFF008000;
	public static var LIME:FlxColor = 0xFF00FF00;
	public static var YELLOW:FlxColor = 0xFFFFFF00;
	public static var ORANGE:FlxColor = 0xFFFFA500;
	public static var RED:FlxColor = 0xFFFF0000;
	public static var PURPLE:FlxColor = 0xFF800080;
	public static var BLUE:FlxColor = 0xFF0000FF;
	public static var BROWN:FlxColor = 0xFF8B4513;
	public static var PINK:FlxColor = 0xFFFFC0CB;
	public static var MAGENTA:FlxColor = 0xFFFF00FF;
	public static var CYAN:FlxColor = 0xFF00FFFF;

	public static var colorLookup(default, null):Map<String, Int> = FlxColor.colorLookup;
	static var COLOR_REGEX = ~/^(0x|#)(([A-F0-9]{2}){3,4})$/i;

	public static inline function fromInt(Value:Int):FlxColor
	{
		return new FlxColor(Value);
	}

	public static inline function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
	{
		return FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}

	public static inline function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):FlxColor
	{
		return FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}

	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):FlxColor
	{
		return FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}

	public static function fromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1):FlxColor
	{
		return FlxColor.fromHSB(Hue, Saturation, Brightness, Alpha);
	}

	public static inline function fromHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float = 1):FlxColor
	{
		return FlxColor.fromHSL(Hue, Saturation, Lightness, Alpha);
	}

	public static function fromString(str:String):Null<FlxColor>
	{
		return FlxColor.fromString(str);
	}

	public static inline function interpolate(Color1:FlxColor, Color2:FlxColor, Factor:Float = 0.5):FlxColor
	{
		return FlxColor.interpolate(Color1, Color2, Factor);
	}
}
