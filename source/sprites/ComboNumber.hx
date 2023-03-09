package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class ComboNumber extends FlxSprite
{
	public static var MAX_RENDERED:Int = 30;

	public var tween:FlxTween;

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
			setGraphicSize(Std.int(frameWidth * 6));
		}
		else
		{
			setGraphicSize(Std.int(frameWidth * 0.5));
		}
	}

	public function create(num:String)
	{
		if (tween != null && !tween.finished)
		{
			onTweenComplete(tween);
			tween.cancel();
		}

		alpha = 1;

		animation.play('$num');

		acceleration.y = FlxG.random.int(200, 300);
		velocity.y = -FlxG.random.int(140, 160);
		velocity.x = FlxG.random.float(-5, 5);

		tween = FlxTween.tween(this, {alpha: 0}, 0.23, {
			onComplete: onTweenComplete,
			startDelay: 0.3
		});
	}

	private function onTweenComplete(tween:FlxTween)
	{
		kill();
		FlxG.state.remove(this, true);
	}
}
