function onCreate()
{
	trace("funny modchart load");
}

function onUpdate(elapsed:Float)
{
	var currentBeat = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
	if (curBeat > 0)
	{
		for (i in 0...8)
			setNoteY(defaultStrumPos[i].y + 2 * Math.sin(currentBeat * Math.PI), i);
	}
}

var bfZoomSteps = [238, 242, 244, 245, 247, 250, 252];
var zoomSteps = [65, 71, 77, 81, 87, 93];
var zoomOutSteps = [96, 102, 108, 113, 118, 124];

function onBeatHit(curBeat:Int)
{
	if (game.camZooming && curBeat % 2 == 0 && (curBeat < 256 || curBeat > 287))
	{
		if (curBeat > 63 && curBeat < 128 || curBeat > 159 && curBeat < 192 || curBeat > 287 && curBeat < 356)
			camHUD.zoom += 0.036;
		else
			camHUD.zoom += 0.025;
	}

	if (curBeat == 64)
	{
		camGame.flash(FlxColor.WHITE, 0.45);
		game.defaultCamZoom = 0.4;
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
}
