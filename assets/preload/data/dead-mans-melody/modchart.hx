import ("Character");
import("PlayState");
import("flixel.util.FlxTimer");

var pasta:Character;

function onCreate()
{
	pasta = new Character(dad.x - 320, dad.y - 290, "toothpaste-mad", false);
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
		
		defaultCamZoom = 0.76;
		boyfriend.visible = false;
		gf.visible = false;
		blackScreen.visible = true;

	}
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

			camGame.flash(FlxColor.WHITE, 0.85);
			dad.visible = false;
			pasta.visible = true;
			game.defaultCamZoom = game.defaultCamZoom - 0.25;

			boyfriend.visible = true;
			gf.visible = true;
			blackScreen.visible = false;

			boyfriend.playAnim("scared", true);
			gf.playAnim("scared", true);

		}
	}
}

function onBeatHit(curBeat:Int)
{
	iconP2.y = healthBar.y - (iconP2.height / 2) - 25;
	FlxTween.tween(iconP2, {y: iconP2.y + 25}, 0.3, {ease: FlxEase.elasticInOut});
}

function setHUDVisibility(theBool:Bool)
{
	for (i in strumLineNotes)
		i.visible = theBool;

	for (i in [iconP1, iconP2, healthBar, healthBarBG, scoreTxt])
		i.visible = theBool;
}
