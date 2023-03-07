package sprites;

import flixel.FlxG;
import flixel.FlxSprite;

class Cursor extends FlxSprite
{
	public function new()
	{
		super(FlxG.mouse.x, FlxG.mouse.y);

		frames = Paths.getSparrowAtlas('newMain/cursor');
		animation.addByPrefix('idle', 'cursor nonselect', 0);
		animation.addByPrefix('select', 'cursor select', 0);
		animation.addByPrefix('qidle', 'cursor qnonselect', 0);
		animation.addByPrefix('qselect', 'cursor qselect', 0);
		animation.play('idle');

		setGraphicSize(Std.int(width / 1.5));
		updateHitbox();

		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justMoved)
			setPosition(FlxG.mouse.x, FlxG.mouse.y - 10);

		offset.y = switch (animation.curAnim.name)
		{
			case 'qselect': 34;
			case 'select': 8;
			case 'qidle': 24;
			default: 0;
		}
	}
}
