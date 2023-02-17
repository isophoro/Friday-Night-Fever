package states.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sprites.ComboNumber;
import sprites.ComboRating;
import sprites.TimingText;

enum CurrentObject
{
	NUMBERS;
	RATING;
	MS;
}

class ComboAdjustmentState extends MusicBeatState
{
	var gf:Character;
	var boyfriend:Character;
	var strumLine:FlxSprite;
	var cpuStrums:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var playerStrums:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var hand:FlxSprite;

	var rating:ComboRating;
	var numbers:FlxSpriteGroup = new FlxSpriteGroup();
	var ms:TimingText = new TimingText(true);
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var current:CurrentObject = RATING;
	var text:FlxText;

	override function create()
	{
		super.create();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		var stageFront:FlxSprite = new FlxSprite(-206, -132).loadGraphic(Paths.image("roboStage/matt_bg", "shared"));
		stageFront.antialiasing = true;
		add(stageFront);

		var stageFront2:FlxSprite = new FlxSprite(-344, -165).loadGraphic(Paths.image("roboStage/matt_foreground", "shared"));
		stageFront2.antialiasing = true;
		add(stageFront2);

		gf = new Character(585 - 95, 149 - 70, 'gf');
		gf.scrollFactor.set(0.95, 0.95);
		boyfriend = new Character(1280.2 - 95, 482.3 - 200, 'bf', true);
		add(gf);
		add(boyfriend);

		var stageFront3:FlxSprite = new FlxSprite(-264, -111).loadGraphic(Paths.image("roboStage/matt_spotlight", "shared"));
		stageFront3.antialiasing = true;
		add(stageFront3);

		FlxG.camera.focusOn(new FlxPoint(boyfriend.getMidpoint().x - 550, boyfriend.getMidpoint().y - 230));

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);

		if (ClientPrefs.downscroll)
			strumLine.y = FlxG.height - 150;

		ms.cameras = numbers.cameras = playerStrums.cameras = cpuStrums.cameras = [camHUD];
		add(cpuStrums);
		add(playerStrums);
		add(numbers);

		rating = new ComboRating();
		rating.create("sick");
		rating.velocity.set(0, 0);
		rating.acceleration.y = 0;
		rating.cameras = [camHUD];
		add(rating);

		ms.text = "45.25ms";
		add(ms);

		for (i in 0...3)
		{
			var n = new ComboNumber();
			n.create('$i');
			n.velocity.set(0, 0);
			n.acceleration.y = 0;
			n.ID = i;
			numbers.add(n);
		}

		generateStaticArrows(cpuStrums, FlxG.width * 0.25, false);
		generateStaticArrows(playerStrums, FlxG.width * 0.75, true);

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
		hand.cameras = [camHUD];

		var box = new FlxSprite(20, 20).makeGraphic(270, 170, FlxColor.BLACK);
		box.alpha = 0.7;
		add(box);
		box.cameras = [camHUD];

		text = new FlxText(box.x + 10, box.y + 10, box.width, "");
		text.setFormat(Paths.font("OpenSans-ExtraBold.ttf"), 20, FlxColor.WHITE);
		add(text);
		text.cameras = [camHUD];

		resetPos();

		if (ClientPrefs.ratingX != -1 && ClientPrefs.ratingY != -1)
		{
			rating.setPosition(ClientPrefs.ratingX, ClientPrefs.ratingY);
			for (i in numbers)
			{
				i.x = ClientPrefs.numX + (33 * i.ID) - 8;
				i.y = ClientPrefs.numY;
			}
			ms.setPosition(ClientPrefs.msX, ClientPrefs.msY);
		}
	}

	private function generateStaticArrows(grp:FlxTypedGroup<FlxSprite>, centerPoint:Float, isPlayer:Bool = true):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			babyArrow.frames = Paths.getSparrowAtlas('notes/defaultNotes', "shared");

			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			switch (i)
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.x = centerPoint - ((babyArrow.width + 4) * (4 / 2)) + ((babyArrow.width + 4) * i);
			babyArrow.animation.play('static');

			if (grp == cpuStrums)
				babyArrow.alpha = 0.65;

			grp.add(babyArrow);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3.125), 0, 1));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, FlxMath.bound(1 - (elapsed * 3.125), 0, 1));

		if (FlxG.mouse.justMoved)
			hand.setPosition(FlxG.stage.mouseX, FlxG.stage.mouseY);

		if (FlxG.mouse.pressed)
		{
			hand.animation.play('select');
			hand.offset.y = 8;

			switch (current)
			{
				case RATING:
					rating.setPosition(hand.x, hand.y);
				case NUMBERS:
					for (i in numbers)
					{
						i.x = hand.x + (33 * i.ID) - 8;
						i.y = hand.y;
					}
				case MS:
					ms.setPosition(hand.x, hand.y);
			}
		}
		else
		{
			hand.animation.play('idle');
			hand.offset.y = 0;
		}

		if (FlxG.keys.justPressed.SHIFT)
		{
			current = switch (current)
			{
				case NUMBERS: MS;
				case RATING: NUMBERS;
				case MS: RATING;
			}
		}

		if (FlxG.keys.justPressed.R)
		{
			resetPos();
		}

		text.text = 'Currently Moving:\n< ${current == RATING ? "Rating" : current == NUMBERS ? "Numbers" : "Precision"} >\n[SHIFT] - Change your current object.\n[R] - Reset all positions';

		if (controls.BACK)
		{
			ClientPrefs.ratingX = rating.x;
			ClientPrefs.ratingY = rating.y;
			ClientPrefs.numX = numbers.members[0].x;
			ClientPrefs.numY = numbers.members[0].y;
			ClientPrefs.msX = ms.x;
			ClientPrefs.msY = ms.y;
			ClientPrefs.save();
			FlxG.switchState(new OptionsState(true));
		}
	}

	override function beatHit()
	{
		boyfriend.dance();
		gf.dance();

		if (curBeat % 4 == 0)
			camHUD.zoom += 0.015;
	}

	function resetPos()
	{
		rating.setPosition((FlxG.width / 2) - (rating.width / 2), (FlxG.height * 0.5) - (rating.height / 2) + 100);
		for (i in numbers)
		{
			i.x = rating.x + (33 * i.ID) - 8;
			i.y = rating.y + 100;
		}
		ms.setPosition(rating.x + 140, rating.y + 100);
	}
}
