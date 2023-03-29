package sprites.objects;

import flixel.FlxG;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	public static var MAX_RENDERED:Int = 10;

	public function new()
	{
		super();

		antialiasing = true;
		alpha = 0.69;

		frames = Paths.getSparrowAtlas('notesplash', 'shared');
		animation.addByPrefix('splash', 'notesplash', 36, false);

		animation.finishCallback = function(t)
		{
			kill();
			flixel.FlxG.state.remove(this);
		}
	}

	public function splash(x:Float, y:Float, direction:Int)
	{
		setPosition(x, y);

		scale.y = scale.x = FlxG.random.float(1.03, 1.088);

		if (direction == 0 || direction == 3)
			offset.set(0.291 * width, 0.315 * height);
		else
			offset.set(0.33 * width, 0.315 * height);

		animation.play('splash', true);
	}
}
