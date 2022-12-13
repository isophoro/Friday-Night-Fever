package sprites;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class TimingText extends FlxText
{
	public function new()
	{
		super();

		if (ClientPrefs.showPrecision) // only bother if it's enabled
		{
			setFormat(Paths.font("DK Fat Kitty Kat.otf"), 23, FlxColor.CYAN, LEFT, OUTLINE, FlxColor.BLACK);
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

		FlxTween.tween(this, {alpha: 0}, 0.45, {startDelay: 0.27});
		FlxTween.tween(this, {"scale.x": 1, "scale.y": 1}, 0.25);

		return str;
	}
}
