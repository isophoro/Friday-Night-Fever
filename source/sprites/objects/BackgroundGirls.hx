package sprites.objects;

import flixel.FlxSprite;

class BackgroundGirls extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('weeb/bgCrowd', 'week6');

		animation.addByPrefix('dance', 'FTRS - Ur Girl ', 24, false);
		dance();
	}

	public function getScared():Void
	{
		animation.addByPrefix('dance', 'FTRS - Chicken Sandwich', 24, false);
		dance();
	}

	public function dance():Void
	{
		animation.play('dance', true);
	}
}
