import Character;
import PlayState;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

var pasta:Character;
var isDad:Bool = false;
var camTween:FlxTween;
var rowProperties = [];

function onCreate()
{
	pasta = new Character(dad.x - 550, dad.y - 580, "toothpaste-mad", false);
	add(pasta);
	pasta.visible = false;

	setHUDVisibility(false);
	// if the player has died before, skip the countdown and intro part of the song
	if (PlayState.deaths > 0)
	{
		FlxTimer.globalManager.clear();
		game.startSong();
		game.disableCamera = true;
		snapCamera(DAD_CAM_POS);
		FlxG.sound.music.time = 42950;
		Conductor.songPosition = 42950;
		gf.visible = false;
		boyfriend.x -= 50;

		defaultCamZoom = 0.76;
		blackScreen.visible = true;
	}
	else
	{
		for (i in [getGlobalVar("bg"), getGlobalVar("fire"), boyfriend, gf])
		{
			i.color = 0xFF000000;
			FlxTween.color(i, 10, 0xFF000000, 0xFFFFFFFF);
		}

		camGame.zoom = 1;
		camTween = FlxTween.tween(camGame, {zoom: 0.76}, 15, {
			onComplete: function(twn)
			{
				game.defaultCamZoom = 0.76;
			}
		});
	}
}

function onUpdate(elapsed:Float)
{
	var cB = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
	pasta.y = (dad.y - 580) + (11 * Math.cos((cB / 2) * Math.PI));
}

function onMoveCamera(dad:Bool)
{
	isDad = dad;
}

function onStepHit(curStep:Int)
{
	if (curStep == 556)
	{
		game.disableCamera = false;
		game.camZooming = true;
		game.curOpponent = pasta;
		dad.playAnim("transition", true);
		camGame.shake(0.045, 1.3);
		dad.animation.finishCallback = function(a)
		{
			setHUDVisibility(true);
			getGlobalVar("changeBG")();

			camGame.flash(FlxColor.WHITE, 0.85);
			gf.visible = false;
			dad.visible = false;
			pasta.visible = true;
			boyfriend.setPosition(770, 225);
			DAD_CAM_OFFSET.y -= 175;

			if (camTween != null)
				camTween.cancel();

			game.defaultCamZoom = game.defaultCamZoom - 0.37;
		}
	}
}

function setHUDVisibility(theBool:Bool)
{
	for (i in strumLineNotes)
		i.visible = theBool;

	for (i in [iconP1, iconP2, healthBar, healthBarBG, scoreTxt])
		i.visible = theBool;
}
