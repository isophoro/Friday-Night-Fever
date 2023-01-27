function onStepHit(curStep:Int)
{
	switch (curStep)
	{
		case 2:
			dad.playAnim("phone");
			getGlobalVar("showBubble")("hallow");
		case 12:
			var arm = getGlobalVar("arm");
			arm.playAnim("phone");
			dad.playAnim("phone");
			arm.animation.finishCallback = function(a)
			{
				if (a == "phone")
				{
					getGlobalVar("wheel").visible = true;
				}
			}
		case 36:
			iconP2.swapCharacter("hallow");
			healthBar.createFilledBar(0xFFE4E7FC, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
			healthBar.updateBar();
		case 548:
			iconP2.swapCharacter("hallow");
			healthBar.createFilledBar(0xFFE4E7FC, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
			healthBar.updateBar();
		case 288:
			//game.health = 1;
			game.healthTween(1, false);
			FlxTween.color(getGlobalVar("sky"), 0.8, FlxColor.WHITE, FlxColor.RED);
			iconP2.swapCharacter("toothpaste");
			healthBar.createFilledBar(0xFF93F1EB, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
			healthBar.updateBar();
		case 350:
			game.curPlayer = dad;
		case 547:
			game.curOpponent = getGlobalVar("arm");
			game.curPlayer = boyfriend;
		case 801:
			iconP2.swapCharacter("rolldog");
			game.curOpponent = dad;

			FlxTween.color(getGlobalVar("sky"), 0.8, FlxColor.RED, FlxColor.WHITE);

			healthBar.createFilledBar(FlxColor.fromString('#FF' + game.curOpponent.iconColor), FlxColor.fromString('#FF' + game.curPlayer.iconColor));
			healthBar.updateBar();
			boyfriend.playAnim("phone", true, true);
			var arm = getGlobalVar("arm");
			arm.playAnim("phone", true, true);
			getGlobalVar("wheel").visible = false;
	}
}

function onGoodNoteHit(note:Note)
{
	if (game.curStep >= 352 && game.curStep < 547)
	{
		dad.playAnim("sing" + game.dataSuffix[note.noteData] + "-craze", true);
		game.defaultCamZoom += 0.01;
	}
}


function onUpdate(elapsed:Float)
{
	if (game.curStep >= 801)
	{
		var arm = getGlobalVar("arm");
		if (arm.animation.name == "phone" && arm.animation.curAnim.curFrame == 0)
		{
			getGlobalVar("wheel").visible = false;
			arm.playAnim("wheel", true);
		}
	}
}

function onOpponentNoteHit(note)
{
	if (game.health - 0.025 > 0.02)
		game.health -= 0.025;
}
