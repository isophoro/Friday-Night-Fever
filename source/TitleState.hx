package;

import GameJolt.GameJoltAPI;
import GameJolt.GameJoltLogin;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import openfl.net.URLLoader;
import shaders.ColorShader;

using StringTools;

#if cpp
import cpp.vm.Gc;
#end
#if windows
import Discord.DiscordClient;
#end

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var hueShader:ColorShader;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	public static var lastState:Bool;

	override public function create():Void
	{
		PlayerSettings.init();

		GameJoltAPI.connect();
		if (FlxG.save.data.gjUser != null && FlxG.save.data.gjToken != null)
			GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);
		/*if(GameJoltAPI.getStatus() == false) // disabling this for rn so i can test without it popping up everytime i build
			{
				FlxG.switchState(new GameJoltLogin());
		}*/
		lastState = true;

		super.create();

		hueShader = new ColorShader();

		logoBl = new FlxSprite(55, 40).loadGraphic(Paths.image('title/logo'));
		logoBl.antialiasing = true;
		logoBl.shader = hueShader;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		if (FlxG.sound.music == null)
		{
			Main.playFreakyMenu();
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		startIntro();

		new FlxTimer().start(105, gotoIntro);
		#end
	}

	var logoBl:FlxSprite;
	var feva:FlxSprite;
	var tea:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.6, new FlxPoint(0, -1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.6, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
		}

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite(-20, -1).loadGraphic(Paths.image('title/bg'));
		bg.antialiasing = true;
		add(bg);

		add(logoBl);

		tea = new FlxSprite(963, 290);
		tea.frames = Paths.getSparrowAtlas('title/tea');
		tea.animation.addByPrefix('bump', 'tea', 24);
		tea.animation.play('bump');
		tea.origin.set(0, 0);
		tea.scale.scale(0.66);
		tea.antialiasing = true;
		add(tea);

		feva = new FlxSprite(755, 282);
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

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxG.mouse.visible = false;

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

		if (controls.BACK)
		{
			gotoIntro();
		}

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
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

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
					createCoolText(['we should', 'probably']);
				case 6:
					addMoreText('replace this');
					ngSpr.visible = true;
				case 7:
					deleteCoolText();
					ngSpr.visible = false;
				case 8:
					createCoolText([curWacky[0]]);
				case 10:
					addMoreText(curWacky[1]);
				case 11:
					deleteCoolText();
				case 12:
					addMoreText('Friday');
				case 13:
					addMoreText('Night');
				case 14:
					addMoreText('Fever');
				case 15:
					addMoreText("Frenzy");
				case 16:
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

	function gotoIntro(?fuckoffflxtimer)
	{
		#if (cpp && !mobile)
		if (!transitioning #if sys && !Sys.args().contains("-disableIntro") #end && ClientPrefs.animeIntro)
		{
			initialized = false;
			FlxG.sound.music.stop();
			FlxG.sound.music = null;
			FlxG.switchState(new Intro());
		}
		#end
	}
}
