function onStepHit(curStep:Int)
{
	if (curStep == 246)
	{
		var arm = getGlobalVar("arm");
		arm.playAnim("phone");
		dad.playAnim("phone");
		arm.animation.finishCallback = function(a)
		{
			if (a == "phone")
			{
				getGlobalVar("wheel").visible = true;
				iconP2.swapCharacter("yukichi");
				healthBar.createFilledBar(0xFFFF97F0, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
			}
		}
	}
}

function onOpponentNoteHit(note:Note)
{
	if (game.curStep >= 800 && game.curStep < 834)
		dad.playAnim("sing" + game.dataSuffix[note.noteData] + "-craze", true);
}

function onBeatHit(curBeat:Int)
{
	if (curBeat % 2 == 0)
	{
		game.camZooming = true;
		camHUD.zoom += curBeat % 4 == 0 ? 0.02 : 0.01;
	}
}
