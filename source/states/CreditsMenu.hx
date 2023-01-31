package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEvent;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.Assets;

using StringTools;

typedef CreditData =
{
	name:String,
	credit:String,
	funny:String
}

/*
	this state is pretty messy because im little panicking to finish this before the premiere ends
 */
class CreditsMenu extends MusicBeatState
{
	var credits:Array<CreditData> = [];
	var rows:Array<Array<FlxSprite>> = [];
	var icons:Array<FlxSprite> = [];

	var bigIcon:FlxSprite = new FlxSprite();
	var passwords(get, never):Array<KeyCombo>;
	var userInput:String = '';
	var selector:FlxSprite;
	var hand:FlxSprite;
	var name:FlxText;
	var desc:FlxText;
	var funny:FlxText;
	var image:FlxSprite;
	var border:FlxSprite;

	inline function get_passwords():Array<KeyCombo>
	{
		return [
			new KeyCombo('isophoro', () ->
			{
				CostumeHandler.unlockCostume(FEVER_ISO);
			})
		];
	}

	var prevTime:Float = 0;
	var backdrop:FlxBackdrop;

	override function create()
	{
		super.create();
		prevTime = FlxG.sound.music.time;
		FlxG.sound.playMusic(Paths.music("credits"));
		FlxG.sound.music.fadeIn(2, 0, 0.5);

		var raw:Array<String> = CoolUtil.coolTextFile(Paths.txt("credits"));
		for (i in raw)
		{
			var soulsplit = i.split("|");
			credits.push({name: soulsplit[0], credit: soulsplit[1], funny: soulsplit[2] != null ? soulsplit[2] : ""});
		}

		backdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 80 * 2, 80 * 2, true, 0xFF0F8CDE, 0xFF0D7FC1), XY);
		backdrop.velocity.set(25, 25);
		add(backdrop);

		var bg:FlxSprite = new FlxSprite().makeGraphic(660, 610, 0xFF0FCADE);
		bg.antialiasing = true;
		add(bg);

		var bg2:FlxSprite = new FlxSprite(0, 610).makeGraphic(1280, 130, 0xFF000054);
		bg2.antialiasing = true;
		add(bg2);

		border = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		border.visible = false;
		border.origin.set(0, 0);
		add(border);

		bigIcon = new FlxSprite(968, FlxG.height * 0.2);
		bigIcon.antialiasing = true;
		bigIcon.visible = false;
		add(bigIcon);

		var curIcon = 0;
		var curRow = 0;
		var row = [];
		for (i in credits)
		{
			var img:String = "credits-icons/" + i.name.toLowerCase();
			var icon = new FlxSprite().loadGraphic(Paths.image(Assets.exists(Paths.image(img)) ? img : "credits-icons/placeholder"));
			icon.antialiasing = true;
			icon.origin.set(0, 0);
			icon.scale.set(0.29, 0.29);
			icon.updateHitbox();
			icon.ID = credits.indexOf(i);
			add(icon);
			row.push(icon);
			icons.push(icon);

			icon.x = ((bg.width / 2)) - ((icon.width + 4) * (7 / 2)) + ((icon.width + 4) * curIcon);
			icon.y = 10 + ((icon.height + 10) * curRow);
			curIcon++;

			if (curIcon >= 7)
			{
				curIcon = 0;
				curRow++;
				rows.push(row);
				row = [];
			}

			var shelton = null;
			if (i.name == "Shelton883")
			{
				shelton = (obj) ->
				{
					FlxG.sound.play(Paths.sound("ohmygod"));
				}
			}

			FlxMouseEvent.add(icon, shelton, null, onMouseOver, onMouseOut);
		}

		selector = new FlxSprite(icons[0].x, icons[0].y).makeGraphic(cast icons[0].width, cast icons[0].height, 0x0);
		selector.antialiasing = true;
		FlxSpriteUtil.drawRect(selector, 0, 0, selector.width, selector.height, 0x0, {color: 0xFFFFFFFF, thickness: 12});
		add(selector);
		selector.visible = false;

		name = new FlxText(0, 0, 0, "", 28);
		name.setFormat(Paths.font("OpenSans-ExtraBold.ttf"), 34, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		name.borderSize = 2;
		add(name);

		desc = new FlxText(0, 0, 560, "", 18);
		desc.setFormat(name.font, 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		desc.borderSize = 1.3;
		add(desc);

		funny = new FlxText(0, 0, 560, "", 24);
		funny.setFormat(name.font, 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		funny.borderSize = 1.5;
		add(funny);

		image = new FlxSprite(funny.x, funny.y).loadGraphic(Paths.image("credits-icons/makogrippers"));
		image.antialiasing = true;
		image.scale.set(0.8, 0.8);
		image.updateHitbox();
		add(image);
		image.visible = false;

		hand = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
		hand.frames = Paths.getSparrowAtlas('newMain/cursor');
		hand.animation.addByPrefix('idle', 'cursor nonselect', 0);
		hand.animation.addByPrefix('select', 'cursor select', 0);
		hand.animation.addByPrefix('qidle', 'cursor qnonselect', 0);
		hand.animation.addByPrefix('qselect', 'cursor qselect', 0);
		hand.animation.play('idle');
		hand.setGraphicSize(Std.int(hand.width / 1.5));
		hand.antialiasing = true;
		hand.updateHitbox();
		add(hand);
	}

	function onMouseOver(obj:FlxSprite)
	{
		selector.setPosition(obj.x, obj.y);

		var i = credits[obj.ID];

		var img:String = "credits-icons/" + i.name.toLowerCase();
		bigIcon.loadGraphic(Paths.image(Assets.exists(Paths.image(img)) ? img : "credits-icons/placeholder"));
		bigIcon.setPosition(968 - (bigIcon.width / 2), FlxG.height * 0.1);
		bigIcon.updateHitbox();
		bigIcon.visible = true;

		border.visible = true;
		border.setPosition(bigIcon.x - 4, bigIcon.y - 4);
		border.scale.set(bigIcon.width + 8, bigIcon.height + 8);

		selector.setPosition(obj.x, obj.y);
		selector.visible = true;
		name.visible = true;
		name.text = i.name;
		name.setPosition(bigIcon.x + (bigIcon.width / 2) - (name.width / 2), bigIcon.y + bigIcon.height + 10);

		desc.visible = true;
		desc.text = i.credit;
		desc.setPosition(bigIcon.x + (bigIcon.width / 2) - (desc.width / 2), name.y + name.height + 10);

		funny.visible = true;
		funny.text = i.funny.length > 0 ? '"${i.funny}"' : "";
		funny.setPosition(bigIcon.x + (bigIcon.width / 2) - (funny.width / 2), desc.y + desc.height + 10);

		if (funny.text.contains(".png"))
		{
			image.loadGraphic(Paths.image('credits-icons/' + funny.text.replace('.png', '').replace('"', '')));
			image.visible = true;
			image.setPosition(bigIcon.x + (bigIcon.width / 2) - (image.width / 2), funny.y + funny.height + 5);
			image.updateHitbox();
			funny.visible = false;
		}
	}

	function onMouseOut(obj:FlxSprite)
	{
		bigIcon.visible = false;
		selector.visible = false;
		name.visible = false;
		desc.visible = false;
		funny.visible = false;
		image.visible = false;
		border.visible = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justMoved)
			hand.setPosition(FlxG.mouse.x, FlxG.mouse.y);

		if (FlxG.mouse.pressed || FlxG.keys.anyPressed([ENTER, SPACE]))
		{
			hand.animation.play('select');
			hand.offset.y = 8;
		}
		else
		{
			hand.animation.play('idle');
			hand.offset.y = 0;
		}

		if (FlxG.keys.justPressed.ANY)
		{
			var keyPressed = FlxKey.toStringMap.get(FlxG.keys.firstJustPressed()).toLowerCase();

			userInput += keyPressed;
			trace(userInput);

			var matching:Bool = false;
			for (i in 0...passwords.length)
			{
				if (passwords[i].combo.startsWith(userInput))
				{
					matching = true;

					if (passwords[i].combo == userInput)
					{
						passwords[i].callback();
						userInput = '';
						matching = false;
					}
				}
			}

			if (!matching)
				userInput = '';
		}

		if (controls.BACK)
		{
			if (FlxG.sound.music.fadeTween != null && !FlxG.sound.music.fadeTween.finished)
				FlxG.sound.music.fadeTween.cancel();

			Main.playFreakyMenu(false);
			FlxG.sound.music.time = prevTime;
			FlxG.switchState(new MainMenuState(true));
		}
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
