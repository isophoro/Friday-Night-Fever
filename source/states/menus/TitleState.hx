package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.OneOfTwo;
import shaders.ColorShader;

using StringTools;

enum TitleEvent
{
	CreateText(beat:Int, text:OneOfTwo<String, Array<String>>);
	SetLogoVisibility(beat:Int, visible:Bool);
	BeginRandomSequence(beat:Int);
	EndRandomSequence(beat:Int);
	EraseText(beat:Int);
	Finish(beat:Int);
}

class TitleState extends MusicBeatState
{
	static var events:Array<TitleEvent> = [
		CreateText(0, ["Friday Night", "Fever Dev Team"]),
		CreateText(3, "present"),
		EraseText(4),
		CreateText(5, ["In collaboration", "with"]),
		SetLogoVisibility(6, true),
		SetLogoVisibility(7, false),
		EraseText(7),
		BeginRandomSequence(8),
		EndRandomSequence(28),
		CreateText(28, "Friday"),
		CreateText(29, "Night"),
		CreateText(30, "Fever"),
		CreateText(31, "Frenzy"),
		Finish(32)
	];

	var hueShader:ColorShader = new ColorShader();
	var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
	var ngSpr:FlxSprite;

	var logoBl:FlxSprite;
	var feva:FlxSprite;
	var tea:FlxSprite;

	var skippedIntro:Bool = false;
	var transitioning:Bool = false;
	var randomText:Array<Array<String>> = [];
	var inRandomSequence:Bool = false;

	override public function create():Void
	{
		super.create();

		if (FlxG.sound.music == null)
		{
			Main.playFreakyMenu();
		}

		var bg:FlxSprite = new FlxSprite(-20, -1).loadGraphic(Paths.image('title/bg'));
		bg.antialiasing = true;

		logoBl = new FlxSprite(55, 40).loadGraphic(Paths.image('title/logo'));
		logoBl.antialiasing = true;
		logoBl.shader = hueShader;

		var cool = FlxG.random.bool(50);
		tea = new FlxSprite(cool ? 698 : 963, cool ? 355 : 290);
		tea.frames = Paths.getSparrowAtlas('title/tea');
		tea.animation.addByPrefix('bump', 'tea', 24);
		tea.animation.play('bump');
		tea.origin.set(0, 0);
		tea.scale.scale(0.66);
		tea.antialiasing = true;

		feva = new FlxSprite(cool ? 945 : 755, cool ? 247 : 282);
		feva.frames = Paths.getSparrowAtlas('title/fever');
		feva.animation.addByPrefix('bump', 'fever', 24);
		feva.animation.play('bump');
		feva.origin.set(0, 0);
		feva.scale.scale(0.66);
		feva.antialiasing = true;

		var front = new FlxSprite(544, 616).loadGraphic(Paths.image('title/front'));
		front.antialiasing = true;

		add(bg);
		add(logoBl);
		add(tea);
		add(feva);
		add(front);

		if (events.length > 0)
		{
			var textArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('introText'));
			var maxValidIndex = textArray.length - 1;
			for (i in 0...maxValidIndex) // FlxRandom.shuffle() keeps giving .cpp compliation issues so im doing this for now
			{
				var j = FlxG.random.int(i, maxValidIndex);
				var tmp = textArray[i];
				textArray[i] = textArray[j];
				textArray[j] = tmp;
			}
			randomText = [for (i in textArray) i.split('--')];

			var blackScreen = new FlxSprite().makeGraphic(10, 10, FlxColor.BLACK);
			blackScreen.origin.set(0, 0);
			blackScreen.scale.set(FlxG.width / 10, FlxG.height / 10);

			ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('teamfever'));
			ngSpr.visible = false;
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.9));
			ngSpr.updateHitbox();
			ngSpr.screenCenter(X);
			ngSpr.antialiasing = true;

			add(credGroup);
			credGroup.add(blackScreen);
			add(ngSpr);
		}
		else
			skipIntro();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		camera.zoom = FlxMath.lerp(1, camera.zoom, 0.95);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (transitioning)
			return;

		if (!skippedIntro)
		{
			// catch up immediately instead of waiting for the next beat
			if (events[0].getParameters()[0] <= curBeat)
				beatHit();
		}
		else
		{
			if (FlxG.keys.pressed.LEFT)
			{
				hueShader.hue -= 0.35 * elapsed;
			}
			else if (FlxG.keys.pressed.RIGHT)
			{
				hueShader.hue += 0.35 * elapsed;
			}
		}

		if (controls.ACCEPT)
		{
			if (!skippedIntro)
			{
				skipIntro();
				return;
			}

			transitioning = true;

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('select'), 0.7);

			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
		}
	}

	function addText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.scale.set(1.075, 1.075);
		FlxTween.tween(logoBl.scale, {x: 1, y: 1}, (Conductor.crochet / 1000) / 1.5);

		if (!skippedIntro)
		{
			FlxG.camera.zoom = 1.015;

			while (events.length > 0 && cast(events[0].getParameters()[0], Int) <= curBeat)
			{
				switch (events[0])
				{
					case CreateText(beat, text):
						if (text is String)
						{
							addText(text);
						}
						else
						{
							for (i in (cast text : Array<String>))
								addText(i);
						}
					case SetLogoVisibility(beat, visible):
						ngSpr.visible = visible;
					case BeginRandomSequence(beat) | EndRandomSequence(beat):
						inRandomSequence = !inRandomSequence;
						deleteText();
					case EraseText(beat):
						deleteText();
					case Finish(beat):
						skipIntro();
				}

				events.shift();
			}

			if (inRandomSequence)
			{
				switch (textGroup.length)
				{
					case 0 | 1:
						addText(randomText[0][textGroup.length]);
					default:
						deleteText();
						randomText.shift();
				}
			}
		}
	}

	function skipIntro():Void
	{
		skippedIntro = true;
		events = [];

		if (ngSpr != null)
		{
			deleteText();
			remove(ngSpr);
			remove(credGroup);

			FlxG.camera.flash(FlxColor.WHITE, 4);
		}
	}
}
