package;

import openfl.net.URLLoader;
import GameJolt.GameJoltLogin;
#if cpp
import cpp.vm.Gc;
#end 


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
import shaders.ColorShader;

import GameJolt.GameJoltAPI;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

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

		logoBl = new FlxSprite(364, 7);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
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
	var gfDance:FlxSprite;
	var titleText:FlxSprite;
	var feverTown:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.6, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.6, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
		}
		
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menuBackground'));
		bg.antialiasing = true;
		add(bg);

		add(logoBl);

		feverTown = new FlxSprite(355, 380);
		feverTown.frames = Paths.getSparrowAtlas('vs FeverTown');
		feverTown.antialiasing = true;
		feverTown.animation.addByPrefix('bump', 'Vs FeverTown', 24, false);
		feverTown.animation.play('bump');
		feverTown.updateHitbox();
		add(feverTown);

		feverTown.shader = hueShader;

		gfDance = new FlxSprite(5, -34);
		gfDance.frames = Paths.getSparrowAtlas('FeverAndTea');
		gfDance.animation.addByPrefix('bump', 'FeverAndTea', 24);
		gfDance.animation.play('bump');
		gfDance.antialiasing = true;
		add(gfDance);

		titleText = new FlxSprite(130, FlxG.height * 0.86);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		titleText.shader = hueShader;

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

		if(controls.BACK)
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
				
				if (FlxG.save.data.flashing)
					titleText.animation.play('press');
	
				FlxTween.tween(titleText, {y: 1200, alpha: 0}, 1.23, { ease: FlxEase.elasticInOut });
	
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

		logoBl.animation.play('bump');
		feverTown.animation.play('bump');

		if(!initialized && !skippedIntro)
		{
			FlxG.camera.zoom += 0.015;
			switch (curBeat)
			{
				case 1:
					createCoolText(['CesarFever', 'HelloItsMako', 'and more']);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['In Partnership', 'with']);
				case 6:
					addMoreText('Newgrounds');
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

			if(!initialized)
				FlxG.camera.flash(FlxColor.WHITE, 4);

			remove(credGroup);
			skippedIntro = true;
		}
	}

	function gotoIntro(?fuckoffflxtimer)
	{
		#if (cpp && !mobile)
		if (!transitioning #if sys && !Sys.args().contains("-disableIntro") #end && FlxG.save.data.animeIntro)
		{
			initialized = false;
			FlxG.sound.music.stop();
			FlxG.sound.music = null;
			FlxG.switchState(new Intro());
		}
		#end
	}
}
