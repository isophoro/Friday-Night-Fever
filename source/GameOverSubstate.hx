package;

import flash.system.System;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	public var camHUD:FlxCamera;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		super();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		var daBf:String = PlayState.SONG.player1;

		if (!daBf.contains('pixel'))
		{
			if (daBf.contains('demon') || daBf == 'bf-carnight' || daBf == 'bf-mad')
			{
				// For demon fever
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'hallow' | 'portrait' | 'soul':
						daBf = 'bf-hallow-dead';
					case 'gears':
						daBf = 'madDeath';
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

		bf.playAnim('firstDeath');

		camFollow = new FlxObject(bf.getGraphicMidpoint().x - bf.offset.x, bf.getGraphicMidpoint().y - bf.offset.y, 1, 1);
		add(camFollow);

		if (daBf != 'madDeath')
			FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		FlxG.camera.shake(0.0095, 0.3);

		PlayState.deaths += 1;

		trace(PlayState.deaths + " Deaths");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
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
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
			FlxTween.tween(FlxG.camera, {zoom: 1}, 2.1, {ease: FlxEase.quadInOut});
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
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
