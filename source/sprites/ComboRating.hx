package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class ComboRating extends FlxSprite
{
	public static var MAX_RENDERED:Int = 15;

	public function new()
	{
		super();
		loadFrames();
	}

	public function loadFrames()
	{
		var pixel = PlayState.instance.usePixelAssets;
		antialiasing = !pixel;

		frames = Paths.getSparrowAtlas("combo/ratings" + (pixel ? "-pixel" : ""), "shared");
		for (i in ["sick", "good", "bad", "shit"])
		{
			animation.addByPrefix(i, i, 0, false);
		}

		animation.play(animation.curAnim != null ? animation.curAnim.name : "sick");
		if (pixel)
		{
			setGraphicSize(Std.int(frameWidth * PlayState.daPixelZoom * 0.7));
		}
		else
		{
			setGraphicSize(Std.int(frameWidth * 0.7));
		}

		updateHitbox();
	}

	public function create(rating:String)
	{
		FlxTween.cancelTweensOf(this);
		alpha = 1;

		animation.play(rating);

		velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 175));
		acceleration.y = 550;
	}
}
