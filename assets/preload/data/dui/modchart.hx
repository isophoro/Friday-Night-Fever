function onCreatePost()
{
	var arm = getGlobalVar("arm");
	arm.playAnim("idle");
	getGlobalVar("wheel").visible = true;

	game.curOpponent = arm;
	game.camZooming = true;

	swapIcon("peakek", 0xFF808080);
}

function onUpdate(elapsed:Float)
{
	for (i in 0...8)
	{
		setNoteX(defaultStrumPos[i].x + (1 - (elapsed * 3.125)) * (strumLineNotes[i].x - defaultStrumPos[i].x), i);
	}
}

function onPlayerNoteHit(note)
{
	if (note.type == 3)
		game.curPlayer = dad;
	else
		game.curPlayer = boyfriend;
}

function onOpponentNoteHit(note:Note)
{
	if (game.curStep >= 512 && game.curStep < 768 || game.curStep >= 1024 && game.curStep < 1280 || game.curStep >= 1794 && game.curStep < 2052)
	{
		game.health -= 0.023;
	}
}

var weeBeats = [66, 70, 74, 78, 82, 86, 90, 94, 98, 102, 106, 110, 114, 118, 122];

function onBeatHit(curBeat)
{
	if (curBeat % 4 == 0 || curBeat >= 128 && curBeat < 192 && curBeat % 2 == 0)
	{
		camHUD.zoom += 0.02;
	}

	if (weeBeats.contains(curBeat))
	{
		for (i in 0...8)
		{
			var nextX:Float = defaultStrumPos[i].x;
			nextX += (i < 2 || i < 6 && i > 3 ? (i == 0 || i == 4 ? -10 : -5) : (i == 3 || i == 7 ? 10 : 5));
			tween(strumLineNotes[i], {x: nextX}, 0.1);
		}
	}

	if (curBeat >= 256 && curBeat < 316 && curBeat % 2 == 0)
	{
		for (i in 0...8)
		{
			var nextX:Float = defaultStrumPos[i].x;
			nextX += curBeat % 4 == 0 ? -30 : 30;
			tween(strumLineNotes[i], {x: nextX}, 0.1);
		}
	}
}

var tween;

function onStepHit(curStep:Int)
{
	switch (curStep)
	{
		case 256:
			swapIcon("spooky", 0xFF565656);
			game.gfSpeed = 2;
		case 512:
			swapIcon("taki", 0xFFD34470);
			game.gfSpeed = 1;
		case 768:
			swapIcon("mako", 0xFF60FF61);
			game.gfSpeed = 2;
		case 1024:
			swapIcon("mom", 0xFFFF728A);
			game.gfSpeed = 1;
		case 1280:
			swapIcon("pepper", 0xFF7F64DA);
			game.gfSpeed = 2;
		case 1538:
			swapIcon("mega-real", 0xFFC90011);
			game.gfSpeed = 1;
		case 1794:
			swapIcon("flippy-real", 0xFFF2E416);
		case 2052:
			swapIcon("food", 0xFFFF9EBF);
		case 2316:
			swapIcon("blluu", 0xFF84CCC6);
	}
}

function swapIcon(char:String, color:Int)
{
	if (char != "peakek")
	{
		dad.playAnim("phone");
	}

	healthBar.createFilledBar(color, FlxColor.fromString('#FF' + game.boyfriend.iconColor));
	iconP2.swapCharacter(char);
	game.health = 1;
}
