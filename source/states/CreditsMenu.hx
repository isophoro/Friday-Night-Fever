package states;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.FlxSprite;

using StringTools;

typedef CreditData =
{
	name:String,
	credit:String,
	funny:String
}

/*

	if you wanna rewrite ur keycombo shit go ahead
*/

class CreditsMenu extends MusicBeatState
{
	var credits:Array<CreditData> = [];
	var rows:Array<Array<FlxSprite>> = [];

	var passwords(get, never):Array<KeyCombo>;
	var userInput:String = '';

	inline function get_passwords():Array<KeyCombo>
	{
		return [
			new KeyCombo('isophoro', () -> {
				CostumeHandler.unlockCostume(FEVER_ISO);
			})
		];
	}

	override function create()
	{
		super.create();

		var raw:Array<String> = CoolUtil.coolTextFile(Paths.txt("credits"));
		for (i in raw)
		{
			var soulsplit = i.split("|");
			credits.push({name: soulsplit[0], credit: soulsplit[1], funny: soulsplit[2]});
		}

		var bg1:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFF0F8CDE);
		bg1.antialiasing = true;
		add(bg1);
		// camera.bgColor = 0xFF0F8CDE; never do this again

		var bg:FlxSprite = new FlxSprite().makeGraphic(660, 610, 0xFF0FCADE);
		bg.antialiasing = true;
		add(bg);

		var bg2:FlxSprite = new FlxSprite(0, 610).makeGraphic(1280, 130, 0xFF000054);
		bg2.antialiasing = true;
		add(bg2);

		var curIcon = 0;
		var curRow = 0;
		var row = [];
		for (i in credits)
		{
			var icon = new FlxSprite().loadGraphic(Paths.image("credits-icons/" + i.name.toLowerCase()));
			icon.antialiasing = true;
			icon.origin.set(0, 0);
			icon.scale.set(0.35, 0.35);
			icon.updateHitbox();
			add(icon);
			row.push(icon);

			icon.x = ((bg.width / 2)) - ((icon.width + 4) * (6 / 2)) + ((icon.width + 4) * curIcon);
			icon.y = 10 + ((icon.height + 15) * curRow);
			curIcon++;

			if (curIcon >= 6)
			{
				curIcon = 0;
				curRow++;
				rows.push(row);
				row = [];
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ANY) 
		{
			var keyPressed = FlxKey.toStringMap.get(FlxG.keys.firstJustPressed()).toLowerCase();

			userInput += keyPressed;
			trace(userInput);

			var matching:Bool = false;
			for(i in 0...passwords.length)
			{
				if(passwords[i].combo.startsWith(userInput))
				{
					matching = true;

					if(passwords[i].combo == userInput)
					{
						passwords[i].callback();
						userInput = '';
						matching = false;
					}
				}
			}

			if(!matching)
				userInput = '';
		}

		if (controls.BACK)
			FlxG.switchState(new MainMenuState(true));
	}
}

class KeyCombo
{
	public var combo:String = '';
	public var callback:Void->Void;

	public function new(password:String, callback:Void->Void)
	{
		combo = password.toLowerCase();
		this.callback = callback;
	}
}
