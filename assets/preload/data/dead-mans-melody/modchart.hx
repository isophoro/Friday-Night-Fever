import ("Character");
import("PlayState");
import("flixel.util.FlxTimer");

var isDad:Bool = false;
var camTween:FlxTween;
var rowProperties = [];

function onCreate()
{

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
	else
	{
		gf.visible = false;
		boyfriend.visible = false;

		camTween = FlxTween.tween(camGame, {zoom: 0.76}, 15, {
			onComplete: function(twn)
			{
				game.defaultCamZoom = 0.76;
			}
		});
	}
}

/*function onUpdate(elapsed:Float)
	{
	var currentBeat = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
	for (i in 4...8)
	{
		setNoteX(defaultStrumPos[i].x + (1 - (elapsed * 3.125)) * (strumLineNotes[i].x - defaultStrumPos[i].x), i);
		setNoteY(defaultStrumPos[i].y + ((5 * Math.cos(currentBeat * Math.PI)) * (i % 2 == 0 ? -1 : 1)), i);
	}

	// camHUD.angle = (0.35 * Math.cos(currentBeat * Math.PI));
	// camHUD.x = (6 * Math.cos(currentBeat * Math.PI));
	// camHUD.y = (6 * Math.cos(currentBeat * Math.PI));
}*/
//
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

			camGame.flash(FlxColor.WHITE, 0.85);
			dad.visible = false;
			pasta.visible = true;

			if (camTween != null)
				camTween.cancel();

			game.defaultCamZoom = game.defaultCamZoom - 0.25;

			boyfriend.visible = true;
			gf.visible = true;
			blackScreen.visible = false;

			boyfriend.playAnim("scared", true);
			gf.playAnim("scared", true);
		}
	}
}

var beat:Float = 6;

function onBeatHit(curBeat:Int)
{
	// iconP2.y = healthBar.y - (iconP2.height / 2) - 25;
	// FlxTween.tween(iconP2, {y: iconP2.y + 25}, 0.3, {ease: FlxEase.elasticInOut});

	/*if (curBeat % 2 == 0)
		for (i in 4...8)
		{
			var nextX:Float = defaultStrumPos[i].x;
			nextX += ((4 * beat) * (curBeat % 4 == 0 ? -1 : 1));
			if (curBeat % 12 == 0)
			{
				nextX += (i < 6 ? -15 : 45);
				strumLineNotes[i].angle = 45;
				tween(strumLineNotes[i], {angle: 0}, 0.1);
			}
			tween(strumLineNotes[i], {x: nextX}, 0.1);
	}*/
}

function setHUDVisibility(theBool:Bool)
{
	for (i in strumLineNotes)
		i.visible = theBool;

	for (i in [iconP1, iconP2, healthBar, healthBarBG, scoreTxt])
		i.visible = theBool;
}
