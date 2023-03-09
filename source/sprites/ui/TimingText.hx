package sprites.ui;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class TimingText extends FlxText
{
	var debug:Bool = false;

	public function new(debug:Bool = false)
	{
		super();
		this.debug = debug;

		if (ClientPrefs.showPrecision || debug) // only bother if it's enabled
		{
			setFormat(Paths.font("DK Fat Kitty Kat.otf"), 23, 0xFFEC46B1, LEFT, OUTLINE, FlxColor.BLACK);
			borderSize = 2.1;
			antialiasing = true;
		}
	}

	override function set_text(str:String)
	{
		super.set_text(str);

		FlxTween.cancelTweensOf(this);
		alpha = 1;
		scale.set(1.1, 1.1);

		if (!debug)
		{
			FlxTween.tween(this, {alpha: 0}, 0.45, {startDelay: 0.27});
			FlxTween.tween(this, {"scale.x": 1, "scale.y": 1}, 0.25);
		}

		return str;
	}
}
