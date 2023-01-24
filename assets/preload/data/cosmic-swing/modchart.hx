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
				game.healthTween(1, false);
			}
		}
	}

	if (curStep == 248)
		getGlobalVar("showBubble")("yukichi");

	if (game.curStep == 800)
	{
		iconP2.swapCharacter("rolldog");
		healthBar.createFilledBar(FlxColor.fromString('#FF' + game.curOpponent.iconColor), FlxColor.fromString('#FF' + game.curPlayer.iconColor));
		camGame.follow(null);
		FlxTween.tween(camGame.scroll, {x: camGame.scroll.x - 125}, 1);
	}
	else if (curStep == 834)
	{
		FlxTween.tween(camGame.scroll, {x: camGame.scroll.x + 125}, 0.4);
		game.defaultCamZoom = 0.9;
	}
	else if (curStep == 848)
	{
		iconP2.swapCharacter("yukichi");
		healthBar.createFilledBar(0xFFFF97F0, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
	}
}

function onOpponentNoteHit(note:Note)
{
	if (game.curStep >= 800 && game.curStep < 834)
	{
		dad.playAnim("sing" + game.dataSuffix[note.noteData] + "-craze", true);
		game.defaultCamZoom += 0.01;
	}
}

function onBeatHit(curBeat:Int)
{
	if (curBeat % 2 == 0)
	{
		game.camZooming = true;
		camHUD.zoom += curBeat % 4 == 0 ? 0.02 : 0.01;
	}
}
