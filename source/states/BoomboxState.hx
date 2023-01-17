package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

using StringTools;

class BoomboxState extends MusicBeatState
{
	var options:Array<Array<Dynamic>> = [
		// listen im running out of time here lol
		["Boombox", "boombox"],
		["Song Pitch", "songPitch"],
		["Random Notes", "randomNotes"]
	];

	var text:Array<FlxText> = [];
	var curSelected:Int = 0;

	override function create()
	{
		super.create();

		for (i in 0...options.length)
		{
			var txt = new FlxText(490, 295 + (i * 25), 0, "");
			txt.setFormat("VCR OSD Mono", 22, 0xFF267F00);
			txt.ID = i;
			add(txt);
			text.push(txt);
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("newMain/boomboxBG"));
		bg.antialiasing = true;
		add(bg);

		updateText();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.DOWN_P)
			updateText(1);
		else if (controls.UP_P)
			updateText(-1);
		else if (controls.LEFT_P || controls.RIGHT_P)
		{
			var shift:Float = (FlxG.keys.pressed.SHIFT ? 0.1 : 0.01) * (controls.LEFT_P ? -1 : 1);
			if (Reflect.field(ClientPrefs, options[curSelected][1]) is Bool)
			{
				Reflect.setField(ClientPrefs, options[curSelected][1], !Reflect.field(ClientPrefs, options[curSelected][1]));
			}
			else
			{
				var newVal = FlxMath.roundDecimal(Reflect.field(ClientPrefs, options[curSelected][1]) + shift, 2);
				newVal = switch (options[curSelected][1])
				{
					case "songPitch": FlxMath.bound(newVal, 0.7, 1.45);
					case "judgeScale": FlxMath.bound(newVal, 0.5, 2);
					default: newVal;
				}
				Reflect.setField(ClientPrefs, options[curSelected][1], newVal);
			}
			updateText();
		}
		else if (controls.BACK)
		{
			ClientPrefs.save();
			FlxG.sound.music.pitch = 1;
			FlxG.switchState(new MainMenuState());
		}
	}

	function updateText(change:Int = 0)
	{
		curSelected += change;

		if (curSelected >= options.length)
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = options.length - 1;

		for (i in text)
		{
			var option = options[i.ID];
			i.text = '${option[0]}: < ${Reflect.field(ClientPrefs, option[1])} >'.replace("true", "ON").replace("false", "OFF");
			i.alpha = i.ID == curSelected ? 1 : 0.7;
		}
	}
}
