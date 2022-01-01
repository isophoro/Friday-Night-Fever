package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flash.system.System;
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
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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
