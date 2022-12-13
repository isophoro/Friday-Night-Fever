function onStepHit(curStep:Int)
{
	game.directionalCameraDist = 10;
	if (curStep == 128 || curStep == 384 || curStep == 527 || curStep == 560 || curStep == 592 || curStep == 623)
	{
		game.useDirectionalCamera = true;
	}
	else if (curStep == 255 || curStep == 511 || curStep == 543 || curStep == 575 || curStep == 607)
	{
		game.useDirectionalCamera = false;
	}
}

function onBeatHit(curBeat:Int)
{
	if (curBeat == 160)
	{
		game.gfSpeed = 1;
	}
	else if (curBeat == 128)
	{
		game.gfSpeed = 2;
	}
}
