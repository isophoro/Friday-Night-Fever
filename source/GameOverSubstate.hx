package;

import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flash.system.System;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	public var camHUD:FlxCamera;

	var stageSuffix:String = "";

	var box:FlxSprite;
	var yes:FlxSprite;
	var no:FlxSprite;

	var noHitbox:FlxSprite;
	var yesHitbox:FlxSprite;

	public function new(x:Float, y:Float)
	{
		super();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		var daBf:String = PlayState.SONG.player1;

		if (!daBf.contains('pixel'))
		{
			if (daBf.contains('demon') || daBf == 'bf-carnight')
			{
				// For demon fever
				switch(PlayState.SONG.song.toLowerCase())
				{
					case 'hallow' | 'portrait' | 'soul':
						daBf = 'bf-hallow-dead';
					default:
						daBf = 'demonDeath';
				}
			}
			else
			{
				daBf = 'humanDeath';
			}
		}
		else
		{
			stageSuffix = '-pixel';
			daBf = 'bf-pixel-dead';
		}

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y - 85, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		FlxG.camera.shake(0.0095, 0.3);

		PlayState.deaths += 1;

		FlxG.save.data.deaths += 1;

		if(PlayState.diedtoHallowNote == true)
		{
			FlxG.save.data.hallowNoteDeaths += 1;
			trace(FlxG.save.data.hallowNoteDeaths + " Hallow Note Deaths");

			PlayState.diedtoHallowNote = false;
		}

		



		trace(PlayState.deaths + " Deaths");

		if(PlayState.storyWeek == 8)
		{
			FlxG.save.data.hallowDeaths += 1;
		}

		trace(FlxG.save.data.deaths + " Save Deaths");



		trace(FlxG.save.data.hallowDeaths + " Hallow Deaths");

	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.save.data.hallowNoteDeaths == 10)
		{
			Achievements.getAchievement(5);
		}

		if(FlxG.save.data.hallowDeaths == 5)
		{
			Achievements.getAchievement(1);
		}

		if(FlxG.save.data.deaths >= 5)
		{
			Achievements.getAchievement(0);
		}
		
		if(PlayState.deaths == 5)
		{

			if(FlxG.keys.justPressed.Y)
				{
					yes.animation.play('selected');
					PlayState.easierMode = true;
					endBullshit();
				}
		
				if(FlxG.keys.justPressed.N)
				{
					no.animation.play('selected');
					endBullshit();
				}
		}

		if (controls.ACCEPT #if mobile || FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justPressed #end)
		{
			endBullshit();
		}

		if (controls.getBack())
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());

			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
			FlxTween.tween(FlxG.camera, {zoom: 1}, 2.1, {ease: FlxEase.quadInOut});
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			if(PlayState.deaths == 5)
			{
				box = new FlxSprite(638.35, 68.4);
				box.frames = Paths.getSparrowAtlas('youFUCKINGDIEDL/retrythingy');
				box.animation.addByPrefix('open', "box", 24, false);
				box.animation.play('open');
				box.scrollFactor.set(0.9, 0.9);
				box.antialiasing = true;
				box.cameras = [camHUD];
		
				yes = new FlxSprite(813.05, 267.75);
				yes.frames = Paths.getSparrowAtlas('youFUCKINGDIEDL/retrythingy');
				yes.animation.addByPrefix('yes', "yes0", 24, false);
				yes.animation.addByPrefix('button', "buttonYes", 1, false);
				yes.animation.addByPrefix('selected', "yes selected", 1, true);
				yes.animation.play('yes');
				yes.scrollFactor.set(0.9, 0.9);
				yes.antialiasing = true;
				yes.cameras = [camHUD];
		
				no = new FlxSprite(966, 278.8);
				no.frames = Paths.getSparrowAtlas('youFUCKINGDIEDL/retrythingy');
				no.animation.addByPrefix('no', "no0", 24, false);
				no.animation.addByPrefix('button', "buttonNo", 1, false);
				no.animation.addByPrefix('selected', "no selected", 1, true);
				no.animation.play('no');
				no.scrollFactor.set(0.9, 0.9);
				no.antialiasing = true;
				no.cameras = [camHUD];

				add(box);
				box.animation.play('open');

				box.animation.finishCallback = function(anim)
				{
					add(yes);
					yes.animation.play('yes');
					yes.animation.finishCallback = function(anim)
					{
						no.animation.play('no');
						add(no);
					};
				};
			}
	

			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'hallow' | 'portrait' | 'soul':
					FlxG.sound.playMusic(Paths.music('gameOverHallow'));
				default:
					FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			if(PlayState.deaths == 5)
				{
					FlxTween.tween(box, {x: 2000}, 1, {ease: FlxEase.bounceOut});
					FlxTween.tween(yes, {x: 2000}, 1, {ease: FlxEase.bounceOut});
					FlxTween.tween(no, {x: 2000}, 1, {ease: FlxEase.bounceOut});
				}

			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();

			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'hallow' | 'portrait' | 'soul':
					FlxG.sound.play(Paths.music('gameOver-EndHallow'));
				default:
					FlxG.sound.play(Paths.music('gameOverEnd'));
			}
		
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
