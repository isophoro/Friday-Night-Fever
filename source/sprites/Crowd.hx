package sprites;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class Crowd extends FlxSprite
{
	public function new()
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'mild':
				loadGraphic(Paths.image('boppers/firstcrowd', 'week5'));
				updateHitbox();
				setPosition(-795, 520);
				scales = [0.9, 0.935, 0.9];
			case 'spice':
				loadGraphic(Paths.image('boppers/secondcrowd', 'week5'));
				updateHitbox();
				setPosition(-635, 850);
			case 'party-crasher' | 'loaded':
				loadGraphic(Paths.image('boppers/finalcrowd', 'week5'));
				updateHitbox();
				setPosition(-635, 830);
		}

		origin.y += height / 2;
		scrollFactor.set(0.9, 0.9);
		antialiasing = true;

		beatHit();
	}

	public var scales:Array<Float> = [1, 1.08, 1];

	public function beatHit()
	{
		scale.set(scales[0], scales[1]);
		FlxTween.tween(this, {"scale.y": scales[0], "scale.x": scales[2]}, (Conductor.crochet / 1000) / 1.3);
	}
}
