package;

import flixel.FlxSprite;
import openfl.Assets;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var isPlayer:Bool = false;
	public var curCharacter:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		this.isPlayer = isPlayer;
		swapCharacter(char);
	}

	public function swapCharacter(char:String)
	{
		curCharacter = char.toLowerCase();

		if (!Assets.exists(Paths.image('icons/icon-$char'))
			&& (PlayState.instance != null && PlayState.instance.boyfriend.curCharacter.toLowerCase() == char))
		{
			loadGraphic(Paths.image('icons/icon-bf'), true, 150, 150);
		}
		else // i hate this code and i hate how the characters are named since this makes it twenty times harder than it should
		{
			switch (curCharacter)
			{
				case 'bf-cedar':
					loadGraphic(Paths.image('icons/icon-cedarhd'), true, 150, 150);
				case 'sg':
					loadGraphic(Paths.image('icon-sg', 'shadow'), true, 150, 150); // embed
				case 'scarlet-freeplay':
					loadGraphic(Paths.image('icons/icon-scarlet'), true, 150, 150);
				case 'robo-cesar-minus':
					loadGraphic(Paths.image('icons/icon-robo-cesar'), true, 150, 150);
				case 'bf' | 'bf-casual' | 'bf-tutorial' | 'bf-car' | 'bf-roblox' | 'bf-mad' | 'bf-rolldog' | 'bf-freeplay' | 'bf-coat' | 'doodle':
					loadGraphic(Paths.image('icons/icon-bf'), true, 150, 150);
				case 'bf-minus':
					loadGraphic(Paths.image('icons/icon-bf-demon'), true, 150, 150);
				case "robofvr-final":
					loadGraphic(Paths.image('icons/icon-roboff'), true, 150, 150);
				case 'bf-teasar':
					loadGraphic(Paths.image('icons/icon-teasar'), true, 150, 150);
				case 'bf-carnight' | 'bf-demon' | 'bf-casualdemon':
					loadGraphic(Paths.image('icons/icon-bf-demon'), true, 150, 150);
				case 'gf' | 'gf-painting' | 'gf-christmas' | 'tea-pixel':
					loadGraphic(Paths.image('icons/icon-gf'), true, 150, 150);
				case 'mega' | 'mega-angry':
					loadGraphic(Paths.image('icons/icon-mega'), true, 150, 150);
				case 'mom-car' | 'hunni-car' | 'hunni' | 'mom-carnight':
					loadGraphic(Paths.image('icons/icon-hunni'), true, 150, 150);
				case 'taki' | 'monster' | 'taki-minus':
					loadGraphic(Paths.image('icons/icon-taki'), true, 150, 150);
				case 'pepper-freeplay':
					loadGraphic(Paths.image('icons/icon-pepper'), true, 150, 150);
				default:
					loadGraphic(Paths.image('icons/icon-$curCharacter'), true, 150, 150);
			}
		}

		var pixel:Array<String> = ['flippy', 'mega', 'bdbfever'];
		antialiasing = StringTools.contains(curCharacter, 'pixel') || pixel.contains(curCharacter) ? false : true;
		animation.add('healthy', [0], 0, false, isPlayer);

		if ((curCharacter == "peasus" || curCharacter == "peakek") && Song.isChildCostume)
		{
			animation.add('hurt', [0], 0, false, isPlayer);
			animation.add('winning', [0], 0, false, isPlayer);
		}
		else
		{
			animation.add('hurt', [1], 0, false, isPlayer);
			animation.add('winning', [2], 0, false, isPlayer);
		}

		animation.play('healthy');

		switch (curCharacter)
		{
			case 'bf-pixel' | 'mega' | 'mega-angry' | 'flippy' | 'tea-pixel':
				antialiasing = false;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
