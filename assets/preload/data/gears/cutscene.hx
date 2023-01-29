import PlayState;
import flixel.util.FlxTimer;

function onCreatePost()
{
	if (!PlayState.isStoryMode)
	{
		onUpdate = null;
		onOpponentNoteHit = null;
		return game.startCountdown();
	}

	iconP2.swapCharacter("robo-cesar");
	healthBar.createFilledBar(0xFF9236B4, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
	healthBar.updateBar();

	camGame.fade(FlxColor.BLACK, 0);
	camHUD.visible = false;
	var video = new MP4Handler();
	video.playVideo(Paths.video("gearsIntro"));
	video.finishCallback = function()
	{
		trace("VIDEO FINISH!");
		video.stop();
		FlxTimer.globalManager.clear();
		game.startCountdown();
	}
}

var fadeIn:Bool = false;

function onUpdate(elapsed:Float)
{
	if (!fadeIn && !game.startingSong)
	{
		if (!camHUD.visible)
		{
			camHUD.visible = true;
			camHUD.fade(FlxColor.BLACK, 0.7, true);
			game.camZooming = false;
		}
	}
}

var beats = [4, 16, 32, 64, 40, 50, 57, 59, 60, 61, 62, 63];

function onStepHit(curStep:Int)
{
	if (beats.contains(curStep))
	{
		camHUD.zoom += 0.02;
	}
}

function onOpponentNoteHit(note)
{
	if (!fadeIn)
	{
		fadeIn = true;
		camGame.fade(FlxColor.BLACK, 0.5, true);

		iconP2.swapCharacter("robofvr-final");
		healthBar.createFilledBar(FlxColor.fromString('#FF' + game.curOpponent.iconColor), FlxColor.fromString('#FF' + game.curPlayer.iconColor));
		healthBar.updateBar();

		FlxG.sound.music.onComplete = endingCutscene;
	}
}

function endingCutscene()
{
	game.inCutscene = true;
	game.canPause = false;
	vocals.stop();
	vocals.volume = 0;
	FlxG.sound.music.stop();

	camGame.fade(FlxColor.BLACK, 0.5, false, function()
	{
		camHUD.visible = false;
		var _video = new MP4Handler();
		_video.canSkip = true;
		_video.playVideo(Paths.video("gearsEnding"));
		_video.finishCallback = game.endSong;
	});
}
