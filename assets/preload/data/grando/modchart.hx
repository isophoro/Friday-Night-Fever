function onCreate()
{
	trace("funny modchart load");
}

function onPostUpdate(elapsed:Float)
{
	var currentBeat = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
	if (curBeat > 0)
	{
		for (i in 0...8)
		{
			setNoteX(defaultStrumPos[i].x + (1 - (elapsed * 3.125)) * (strumLineNotes[i].x - defaultStrumPos[i].x), i);

			if (curBeat >= 64 && curBeat < 128 || curBeat > 159 && curBeat < 192 || curBeat > 287 && curBeat < 356)
			{
				setNoteY(defaultStrumPos[i].y + (4 * Math.sin(currentBeat * Math.PI)), i);
			}
			else
				setNoteY(defaultStrumPos[i].y + 2 * Math.sin(currentBeat * Math.PI), i);
		}
	}
}

var bfZoomSteps = [238, 242, 244, 245, 247, 250, 252];
var zoomSteps = [65, 71, 77, 81, 87, 93];
var zoomOutSteps = [96, 102, 108, 113, 118, 124];
var beat:Float = 2.5;

function onBeatHit(curBeat:Int)
{
	if (game.camZooming && curBeat % 2 == 0 && (curBeat < 256 || curBeat > 287))
	{
		if (curBeat >= 288 && curBeat < 351)
			camHUD.zoom += 0.043;
		else if (curBeat > 63 && curBeat < 128 || curBeat > 159 && curBeat < 192 || curBeat > 351 && curBeat < 356)
			camHUD.zoom += 0.036;
		else
			camHUD.zoom += 0.025;
	}

	if (curBeat == 64)
	{
		camGame.flash(FlxColor.WHITE, 0.45);
		game.defaultCamZoom = 0.5;
		camGame.zoom = game.defaultCamZoom;
	}

	if (curBeat == 256)
	{
		game.defaultCamZoom = 0.5;
		// game.useDirectionalCamera = false;
	}

	if (curBeat == 356)
	{
		FlxTween.tween(game, {"defaultCamZoom": 0.5}, 1.4);
		for (i in 0...8)
			FlxTween.tween(strumLineNotes[i], {alpha: 0}, 1.4);
	}

	if (curBeat >= 64 && curBeat < 128 || curBeat > 159 && curBeat < 192 || curBeat > 287 && curBeat < 356)
		for (i in 0...8)
		{
			var nextX:Float = defaultStrumPos[i].x;
			nextX += ((4 * beat) * (curBeat % 2 == 0 ? -1 : 1));
			if (curBeat == 288)
			{
				nextX += (i < 2 || i < 6 && i > 3 ? (i == 0 || i == 4 ? -45 : -25) : (i == 3 || i == 7 ? 45 : 25));
			}
			tween(strumLineNotes[i], {x: nextX, "scale.y": 0.7}, 0.1);
		}
}

function onStepHit(curStep:Int)
{
	if (zoomSteps.contains(curStep))
	{
		camGame.zoom += 0.015;
	}
	else if (zoomOutSteps.contains(curStep))
	{
		camGame.zoom -= 0.015;

		if (zoomOutSteps.indexOf(curStep) == zoomOutSteps.length - 1)
		{
			game.defaultCamZoom += 0.15;
			game.useDirectionalCamera = true;
		}
	}
	else if (bfZoomSteps.contains(curStep))
	{
		game.defaultCamZoom += 0.012;
	}

	if (curStep >= 1144 && curStep < 1152 && curStep % 2 == 0)
	{
		game.defaultCamZoom += 0.04;
		if (curStep < 1150)
			camGame.zoom = game.defaultCamZoom;
	}

	if (curStep >= 1552)
	{
		game.useDirectionalCamera = true;
	}

	if (curStep == 515)
		game.defaultCamZoom += 0.14;
	else if (curStep == 641)
		game.defaultCamZoom += 0.05;
	else if (curStep == 770)
		game.defaultCamZoom -= 0.05;
	else if (curStep == 834 || curStep == 896 || curStep == 961)
		game.defaultCamZoom = 0.64;
}

function onOpponentNoteHit(note:Note)
{
	if (game.curBeat >= 200 && game.curBeat < 207 || curBeat >= 228 && curBeat <= 239)
		game.defaultCamZoom += 0.005;
}

function onPlayerNoteHit(note:Note)
{
	if (game.curBeat >= 212 && game.curBeat < 223 || curBeat >= 244 && curBeat <= 255)
		game.defaultCamZoom += 0.005;
}
