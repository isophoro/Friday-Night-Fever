package;

import Controls.KeyboardScheme;
import GameJolt;
import flash.display.DisplayObject;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options', 'jukebox', 'gallery'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.1" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public static var finishedFunnyMove:Bool = false;

	public static var shutup:Bool;

	public static var alert:FlxText;

	
	var train:FlxSprite;
	var freeplay:FlxSprite;
	var options:FlxSprite;
	var boombox:FlxSprite;
	var credits:FlxSprite;
	var costumes:FlxSprite;
	var extras:FlxSprite;

	var cursorr:FlxSprite;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		TitleState.lastState = false;

		PlayState.easierMode = false;
		PlayState.deaths = 0;

		shutup = true;

		#if debug
		Achievements.getAchievement(17);
		Achievements.getAchievement(8);
		#end

		ClientPrefs.deaths = 0;

		if (GameJoltAPI.getStatus())
		{
			Achievements.checkAchievementsLogged();
		}
		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 145 + (i * 115));
			menuItem.frames = Paths.getSparrowAtlas('menu shit');
			menuItem.animation.addByPrefix('idle', optionShit[i], 0);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " select", 0);
			menuItem.animation.play('idle');
			menuItem.updateHitbox();
			menuItem.x = FlxG.width - menuItem.width + 5;
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.antialiasing = true;

			selectedSomethin = true;
			menuItem.x += 550;
			FlxTween.tween(menuItem, {x: FlxG.width - menuItem.width + 5}, 0.65 + (0.12 * i), {
				ease: FlxEase.smoothStepInOut,
				onComplete: function(twn:FlxTween)
				{
					if (menuItem.ID == optionShit.length - 1)
					{
						selectedSomethin = false;
						changeItem();
					}
				}
			});
		}

		if (GameJoltAPI.getStatus() == true)
		{
			trace('logged in');
			if (Sys.getEnv('USERNAME') == 'Shelton883')
			{
				Achievements.getAchievement(8);
			}
		}
		else
		{
			trace('not logged in');
		}

		var versionShit:FlxText = new FlxText(5, 0, 0,
			'Friday Night Fever ${Application.current.meta.get("version")}\nGamejolt: ' +
			(GameJoltAPI.userLogin ? "Not logged in" : 'Logged in as ${FlxG.save.data.gjUser}'),
			12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.antialiasing = true;
		versionShit.y = FlxG.height - versionShit.height;
		add(versionShit);

		changeItem();

		var trainBG:FlxSprite = new FlxSprite(77.95, -70.35);
		trainBG.loadGraphic(Paths.image("newMain/subway_bg_2"));
		trainBG.setGraphicSize(Std.int(trainBG.width / 1.35));
		trainBG.antialiasing = true;
		trainBG.updateHitbox();
		add(trainBG);

		train = new FlxSprite(110, -20);
		train.frames = Paths.getSparrowAtlas('newMain/trainmenu');
		train.animation.addByPrefix('come', 'Train come', 24, false);
		train.animation.addByPrefix('idle', 'Train notselected', 24, true);
		train.animation.addByPrefix('select', 'Train selected', 24);
		train.animation.play('come');
		train.setGraphicSize(Std.int(train.width / 1.35));
		train.antialiasing = true;
		train.updateHitbox();
		add(train);
		train.animation.finishCallback = function(anim){
			train.animation.play('idle');
		}

		var overlapBG:FlxSprite = new FlxSprite(-70.35, -69.95);
		overlapBG.loadGraphic(Paths.image("newMain/subway_bg"));
		overlapBG.setGraphicSize(Std.int(overlapBG.width / 1.35));
		overlapBG.antialiasing = true;
		overlapBG.updateHitbox();
		add(overlapBG);


		options = new FlxSprite(905.5, 555.55);
		options.frames = Paths.getSparrowAtlas('newMain/options');
		options.animation.addByPrefix('idle', 'options notselected', 24, true);
		options.animation.addByPrefix('select', 'options selected', 24);
		options.animation.play('idle');
		options.setGraphicSize(Std.int(options.width / 1.35));
		options.antialiasing = true;
		options.updateHitbox();
		add(options);


		credits = new FlxSprite(-32.45, 38.9);
		credits.frames = Paths.getSparrowAtlas('newMain/credits');
		credits.animation.addByPrefix('idle', 'credits notselected', 24, true);
		credits.animation.addByPrefix('select', 'credits selected', 24);
		credits.animation.play('idle');
		credits.setGraphicSize(Std.int(credits.width / 1.35));
		credits.antialiasing = true;
		credits.updateHitbox();
		add(credits);

		FlxG.mouse.visible = false;

		cursorr = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
		cursorr.frames = Paths.getSparrowAtlas('newMain/cursor');
		cursorr.animation.addByPrefix('idle', 'cursor nonselect', 0);
		cursorr.animation.addByPrefix('select', 'cursor select', 0);
		cursorr.animation.play('idle');
		cursorr.setGraphicSize(Std.int(cursorr.width / 1.5));
		cursorr.antialiasing = true;
		cursorr.updateHitbox();
		add(cursorr);
		


		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		#if !mobile
		if (FlxG.keys.justPressed.C)
		{
			FlxG.switchState(new CreditsState());
		}
		else if (FlxG.keys.justPressed.V)
		{
			// LoadingState.loadAndSwitchState(new ClosetState());
		}
		#end

		cursorr.x = FlxG.mouse.x;
		cursorr.y = FlxG.mouse.y;

		if(FlxG.mouse.pressed)
		{
			cursorr.animation.play('select');
		}
		
		if(FlxG.mouse.justReleased)
		{
			cursorr.animation.play('idle');
		}

		// if (FlxG.sound.music.volume != null)
		// {
		//	FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		// }

		if (!selectedSomethin)
		{
			var accepted:Bool = controls.ACCEPT;

			#if mobile
			if (FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justPressed)
			{
				for (sprite in menuItems)
				{
					if (FlxG.touches.getFirst().overlaps(sprite))
					{
						if (curSelected != sprite.ID)
						{
							FlxG.sound.play(Paths.sound('scrollMenu'));
							curSelected = sprite.ID;
							changeItem(0, true);
						}
						else
						{
							accepted = true;
						}

						break;
					}
				}
			}
			#end

			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.getBack())
			{
				FlxG.switchState(new TitleState());
			}

			if (accepted)
			{
				shutup = false;
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (ClientPrefs.flashing)
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {x: FlxG.width + spr.width}, 0.44, {
							ease: FlxEase.smoothStepInOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						if (ClientPrefs.flashing)
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								goToState();
							});
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								goToState();
							});
						}
					}
				});
			}
		}

		super.update(elapsed);
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
			case 'freeplay':
				FlxG.switchState(new SelectingSongState());
			case 'jukebox':
				FlxG.switchState(new JukeboxState());
			case 'gallery':
				FlxG.switchState(new GalleryState());
			case 'options':
				FlxG.switchState(new options.OptionsState());
		}
	}

	function changeItem(huh:Int = 0, ?mobileTap:Bool)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
			}

			spr.updateHitbox();
			if (!selectedSomethin)
				spr.x = FlxG.width - spr.width + 5;
		});
	}
}
