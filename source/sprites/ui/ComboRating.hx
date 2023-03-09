package sprites.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class ComboRating extends FlxSprite
{
	public static var MAX_RENDERED:Int = 15;

	private var tween:FlxTween;

	public function new()
	{
		super();
		loadFrames();
	}

	public function loadFrames()
	{
		var pixel = PlayState.instance != null && PlayState.instance.usePixelAssets;
		antialiasing = !pixel;

		var animName:String = animation.curAnim != null ? animation.curAnim.name : "sick";
		frames = Paths.getSparrowAtlas("combo/ratings" + (pixel ? "-pixel" : ""), "shared");
		for (i in ["sick", "good", "bad", "shit"])
		{
			animation.addByPrefix(i, i, 0, false);
		}

		animation.play(animName);
		if (pixel)
		{
			setGraphicSize(Std.int(frameWidth * 6 * 0.7));
		}
		else
		{
			setGraphicSize(Std.int(frameWidth * 0.49));
		}

		updateHitbox();
	}

	public function create(rating:String)
	{
		if (tween != null && !tween.finished)
		{
			onTweenComplete(tween);
			tween.cancel();
		}

		alpha = 1;

		animation.play(rating);

		velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 175));
		acceleration.y = 550;

		tween = FlxTween.tween(this, {alpha: 0}, 0.45, {
			onComplete: onTweenComplete,
			startDelay: 0.27
		});
	}

	private function onTweenComplete(tween:FlxTween)
	{
		kill();
		FlxG.state.remove(this, true);
	}
}
