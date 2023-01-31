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

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		super();
		PlayState.skipDialogue = true;

		var daBf:String = PlayState.instance.boyfriend.curCharacter;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'hallow' | 'old-portrait' | 'soul' | 'eclipse' | 'old-hallow' | 'old-soul':
				daBf = 'bf-hallow-dead';
			case 'gears':
				daBf = 'madDeath';
			case 'cosmic-swing' | 'w00f' | 'dui' | 'cell-from-hell':
				daBf = 'rolldogDeathAnim';
			default:
				switch (daBf)
				{
					case 'mcdietis':
						daBf = 'deathAnims/mcdietis';
					case 'bf-demon':
						if (PlayState.instance.usePixelAssets)
						{
							stageSuffix = '-pixel';
							daBf = 'bf-demon-pixel-dead';
						}
						else daBf = 'demonDeath';
					//
					case 'bf-pixeldemon':
						stageSuffix = '-pixel';
						daBf = 'bf-demon-pixel-dead';
					//
					default:
						if (PlayState.instance.usePixelAssets)
						{
							stageSuffix = '-pixel';
							daBf = 'bf-pixel-dead';
						}
						else daBf = 'humanDeath';
				}
		}

		if (PlayState.instance.gotSmushed == true && PlayState.instance.boyfriend.curCharacter == 'bf-demon')
		{
			daBf = 'bf-smushed';
		}

		bf = new Boyfriend(x, y, daBf, false);
		add(bf);

		bf.playAnim('firstDeath');

		camFollow = new FlxObject(bf.getGraphicMidpoint().x - bf.offset.x, bf.getGraphicMidpoint().y - bf.offset.y, 1, 1);

		switch (daBf)
		{
			case 'bf-smushed':
				camFollow.x += 350;
				camFollow.y += 220;
			case 'rolldogDeathAnim':
				camFollow.x += 500;
				FlxG.camera.snapToTarget();
		}

		add(camFollow);

		switch (daBf)
		{
			case 'rolldogDeathAnim':
				FlxG.sound.play(Paths.sound('deaths/car_death'));
			case 'madDeath':
				FlxG.sound.play(Paths.sound('deaths/laser'));
			case 'bf-smushed':
				FlxG.sound.play(Paths.sound('deaths/paste'));
			default:
				FlxG.sound.play(Paths.sound('deaths/general'));
		}
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		FlxG.camera.shake(0.0095, 0.3);

		PlayState.deaths += 1;
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
				FlxG.switchState(new StoryMenuState(true));
			else
				FlxG.switchState(new FreeplayState(true));
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
				case 'c354r' | 'loaded' | 'gears' | 'grando' | 'tranquility' | 'princess' | 'bloom' | 'crack' | 'w00f':
					FlxG.sound.playMusic(Paths.music('gameOver-Robo'));
				case 'hallow' | 'old-portrait' | 'soul' | 'eclipse' | 'old-hallow' | 'old-soul':
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
