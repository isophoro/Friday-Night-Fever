package sprites.objects;

import flixel.FlxSprite;
import meta.interfaces.IBeatReceiver;

class BackgroundGirls extends FlxSprite implements IBeatReceiver
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('weeb/bgCrowd', 'week6');

		if (PlayState.SONG.song.toLowerCase() == 'chicken-sandwich')
		{
			animation.addByPrefix('dance', 'FTRS - Chicken Sandwich', 24, false);
		}
		else
		{
			animation.addByPrefix('dance', 'FTRS - Ur Girl ', 24, false);
		}

		beatHit(0);
	}

	public function beatHit(curBeat:Int):Void
	{
		animation.play('dance', true);
	}
}
