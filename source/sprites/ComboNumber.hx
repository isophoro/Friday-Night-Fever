package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class ComboNumber extends FlxSprite
{
	public static var MAX_RENDERED:Int = 30;

	public function new()
	{
		super();
		loadFrames();
	}

	public function loadFrames()
	{
		var pixel = PlayState.instance != null && PlayState.instance.usePixelAssets;
		antialiasing = !pixel;

		var animName:String = animation.curAnim != null ? animation.curAnim.name : "0";
		frames = Paths.getSparrowAtlas("combo/numbers" + (pixel ? "-pixel" : ""), "shared");
		for (i in 0...10)
		{
			animation.addByPrefix('$i', 'num$i', 0, false);
		}

		animation.play(animName);
		if (pixel)
		{
			setGraphicSize(Std.int(frameWidth * PlayState.daPixelZoom));
		}
		else
		{
			setGraphicSize(Std.int(frameWidth * 0.5));
		}
	}

	public function create(num:String)
	{
		FlxTween.cancelTweensOf(this);
		alpha = 1;

		animation.play('$num');

		acceleration.y = FlxG.random.int(200, 300);
		velocity.y = -FlxG.random.int(140, 160);
		velocity.x = FlxG.random.float(-5, 5);
	}
}
