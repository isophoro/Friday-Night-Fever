function onBeatHit(curBeat:Int)
{
	if (curBeat == 96 && getGlobalVar("changeBG") != null)
	{
		getGlobalVar("changeBG")();
		game.useDirectionalCamera = true;
	}
}
