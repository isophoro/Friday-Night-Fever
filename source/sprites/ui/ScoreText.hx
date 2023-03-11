package sprites.ui;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ScoreText extends FlxText
{
	public var defaultSize:Int = 18;
	public var defaultScale:FlxPoint = new FlxPoint(1, 1);
	public var bopTween:FlxTween;
	public var disableBop:Bool = false;

	public function new(y:Float = 0)
	{
		super(0, y, 0, "", 18);
		setFormat(Paths.font("vcr.ttf"), defaultSize, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		updateAdaptiveScaling();
		antialiasing = true;
	}

	public function bop()
	{
		if (disableBop)
			return;

		cancelBop();

		scale.set(defaultScale.x * 1.05, defaultScale.y * 1.05);
		bopTween = FlxTween.tween(scale, {x: defaultScale.x, y: defaultScale.y}, 0.24, {
			onComplete: (twn) ->
			{
				bopTween = null;
			}
		});
	}

	public function updateAdaptiveScaling()
	{
		size = getAdaptedSize();

		if (ClientPrefs.adaptiveText)
			scale.x = scale.y = Math.min(1, 1 * (1280 / FlxG.stage.window.width));

		defaultScale.copyFrom(scale);
		borderSize = 1.25 * (1 / scale.x);
		screenCenter(X);
	}

	public function cancelBop()
	{
		if (bopTween != null)
			bopTween.cancel();
	}

	private function getAdaptedSize():Int
	{
		var newVal:Int = defaultSize;
		if (ClientPrefs.adaptiveText && FlxG.stage.window.width > 1280)
			newVal = Math.round(newVal * (FlxG.stage.window.width / 1280));

		if (newVal != size)
		{
			cancelBop();
		}

		return newVal;
	}

	override function set_text(text:String):String
	{
		super.set_text(text);
		screenCenter(X);
		return text;
	}
}
