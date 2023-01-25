package;

import flixel.math.FlxPoint;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	public var positionOffset:FlxPoint = new FlxPoint(0, 0);
	public var cameraOffset:FlxPoint = new FlxPoint(0, 0);

	private var nonFlipped:Array<String> = ["rolldogDeathAnim"];

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		if (!PlayState.isStoryMode && CostumeHandler.curCostume != FEVER && Song.costumesEnabled)
		{
			var data = CostumeHandler.data[CostumeHandler.curCostume];
			char = data.character;
			if (data.characterOffset != null)
				positionOffset.set(data.characterOffset[0], data.characterOffset[1]);

			if (data.camOffset != null)
				cameraOffset.set(data.camOffset[0], data.camOffset[1]);
		}

		super(x, y, char, !nonFlipped.contains(char));
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
