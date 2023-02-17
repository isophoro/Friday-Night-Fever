package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
import shaders.ColorShader;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var hueShader:ColorShader;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	override public function create():Void
	{
		super.create();

		if (FlxG.sound.music == null)
		{
			Main.playFreakyMenu();
		}

		hueShader = new ColorShader();

		logoBl = new FlxSprite(55, 40).loadGraphic(Paths.image('title/logo'));
		logoBl.antialiasing = true;
		logoBl.shader = hueShader;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		var bg:FlxSprite = new FlxSprite(-20, -1).loadGraphic(Paths.image('title/bg'));
		bg.antialiasing = true;
		add(bg);

		add(logoBl);

		var cool = FlxG.random.bool(50);
		tea = new FlxSprite(cool ? 698 : 963, cool ? 355 : 290);
		tea.frames = Paths.getSparrowAtlas('title/tea');
		tea.animation.addByPrefix('bump', 'tea', 24);
		tea.animation.play('bump');
		tea.origin.set(0, 0);
		tea.scale.scale(0.66);
		tea.antialiasing = true;
		add(tea);

		feva = new FlxSprite(cool ? 945 : 755, cool ? 247 : 282);
		feva.frames = Paths.getSparrowAtlas('title/fever');
		feva.animation.addByPrefix('bump', 'fever', 24);
		feva.animation.play('bump');
		feva.origin.set(0, 0);
		feva.scale.scale(0.66);
		feva.antialiasing = true;
		add(feva);

		var front = new FlxSprite(544, 616).loadGraphic(Paths.image('title/front'));
		front.antialiasing = true;
		add(front);

		new FlxTimer().start(0.1, (t) ->
		{
			startIntro();
		});
	}

	var logoBl:FlxSprite;
	var feva:FlxSprite;
	var tea:FlxSprite;

	function startIntro()
	{
		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		var blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('teamfever'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.9));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		hueShader.hue = 0;
		if (initialized)
			skipIntro();
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (!transitioning)
			camera.zoom = FlxMath.lerp(1, camera.zoom, 0.95);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (!transitioning && skippedIntro)
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

		hueShader.onUpdate();

		if (controls.ACCEPT)
		{
			if (!transitioning && skippedIntro)
			{
				initialized = true;
				transitioning = true;

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('select'), 0.7);

				new FlxTimer().start(0.4, function(tmr:FlxTimer)
				{
					FlxG.switchState(new MainMenuState());
				});
			}
			else if (!skippedIntro)
			{
				skipIntro();
			}
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
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

		if (!initialized && !skippedIntro)
		{
			FlxG.camera.zoom += 0.015;
			switch (curBeat)
			{
				case 1:
					createCoolText(['Friday Night', 'Fever Dev Team']);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['In collaboration', 'with']);
				case 6:
					ngSpr.visible = true;
				case 7:
					deleteCoolText();
					ngSpr.visible = false;
				case 8 | 12 | 15 | 18 | 21 | 24:
					createCoolText([curWacky[0]]);
				case 10 | 13 | 16 | 19 | 22 | 25:
					addMoreText(curWacky[1]);
				case 11 | 14 | 17 | 20 | 23 | 26:
					curWacky = FlxG.random.getObject(getIntroTextShit());
					deleteCoolText();
				case 28:
					deleteCoolText();
					createCoolText(['Friday']);
				case 29:
					addMoreText('Night');
				case 30:
					addMoreText('Fever');
				case 31:
					addMoreText("Frenzy");
				case 32:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			if (!initialized)
				FlxG.camera.flash(FlxColor.WHITE, 4);

			remove(credGroup);
			skippedIntro = true;
		}
	}
}
