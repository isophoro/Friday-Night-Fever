import flixel.FlxSprite;
import flixel.math.FlxMath;

var eat:FlxSprite;
var hudAngle:Float = 0;

function onCreate()
{
	eat = new FlxSprite(645, -110);
	eat.frames = Paths.getSparrowAtlas("characters/fever/fever_eat");
	eat.animation.addByPrefix("eat", "Fever eat", 24, false);
	eat.antialiasing = true;
	add(eat, getIndexOfMember(boyfriend) - 2);
	eat.visible = false;
}

function onBeatHit(curBeat:Int)
{
	if (curBeat < 276)
	{
		if (curBeat >= 8 && curBeat < 136 && curBeat % 2 == 0)
			camHUD.zoom += curBeat % 4 == 0 ? 0.015 : 0.005;
	}
	else if (curBeat >= 276 && curBeat < 340)
	{
		if (curBeat % 2 == 0)
		{
			camHUD.zoom += curBeat % 4 == 0 ? 0.018 : 0.009;
			hudAngle = curBeat % 4 == 0 ? 0.65 : -0.65;
		}
	}
	else if (curBeat >= 340 && curBeat < 404)
	{
		hudAngle = 0;
		camHUD.zoom += 0.015;
	}
	else if (curBeat >= 404 && curBeat < 468)
	{
		if (curBeat % 3 == 0)
			camHUD.zoom += 0.02;
	}

	if (game.curPlayer != boyfriend && game.curOpponent != boyfriend)
		boyfriend.dance();

	if (game.curPlayer != dad && game.curOpponent != dad)
		dad.dance();
}

function onStepHit(curStep:Int)
{
	game.camZooming = true;
	if (curStep == 1)
	{
		getGlobalVar("showBubble")("robo-fever");
	}

	if (curStep == 1073)
	{
		getGlobalVar("showBubble")("scarlet");
	}

	if (curStep == 10)
	{
		var arm = getGlobalVar("arm");
		arm.playAnim("phone");
		dad.playAnim("phone");
		arm.animation.finishCallback = function(a)
		{
			if (a == "phone")
			{
				getGlobalVar("wheel").visible = true;
				// iconP2.swapCharacter("yukichi");
				// healthBar.createFilledBar(0xFFFF97F0, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
			}
		}
	}

	if (curStep == 34)
	{
		iconP2.swapCharacter("robo-cesar");
		healthBar.createFilledBar(0xFF9236B4, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
	}

	if (curStep == 546 || curStep == 548 || curStep == 605 || curStep == 607 || curStep == 610 || curStep == 612 || curStep == 669 || curStep == 671
		|| curStep == 674 || curStep == 676 || curStep == 733 || curStep == 735 || curStep == 738 || curStep == 740)
	{
		camGame.zoom += 0.02;
		camHUD.zoom += 0.016;

		for (i in 0...8)
		{
			var nextX:Float = defaultStrumPos[i].x;
			if (curStep == 546 || curStep == 548)
				nextX += (i < 2 || i < 6 && i > 3 ? (i == 0 || i == 4 ? -35 : -15) : (i == 3 || i == 7 ? 35 : 15));
			else
				nextX += (i < 2 || i < 6 && i > 3 ? (i == 0 || i == 4 ? -10 : -5) : (i == 3 || i == 7 ? 10 : 5));
			tween(strumLineNotes[i], {x: nextX}, 0.1);
		}
	}

	if (curStep == 1064)
	{
		game.health = 1;
		iconP2.swapCharacter("rolldog");
		healthBar.createFilledBar(FlxColor.fromString('#FF' + game.curOpponent.iconColor), FlxColor.fromString('#FF' + game.curPlayer.iconColor));
		boyfriend.playAnim("phone", true, true);
		var arm = getGlobalVar("arm");
		arm.playAnim("phone", true, true);
		getGlobalVar("wheel").visible = false;
	}

	if (curStep == 1080)
	{
		var arm = getGlobalVar("arm");
		arm.playAnim("phone", true);
		boyfriend.playAnim("phone", true);
	}

	if (curStep == 1106)
	{
		iconP2.swapCharacter("scarlet");
		healthBar.createFilledBar(0xFFE059B1, FlxColor.fromString('#FF' + game.curPlayer.iconColor));
	}

	if (curStep == 481 || curStep == 1425)
	{
		game.curPlayer = dad;
		boyfriend.dance();
		game.curOpponent = curStep == 1425 ? getGlobalVar("arm") : boyfriend;
	}

	if (curStep == 545 || curStep == 1616 || curStep == 1881)
	{
		game.curOpponent = dad;
		game.curPlayer = boyfriend;

		if (curStep == 1881)
		{
			game.health = 1;
			iconP2.swapCharacter("rolldog");
			healthBar.createFilledBar(FlxColor.fromString('#FF' + game.curOpponent.iconColor), FlxColor.fromString('#FF' + game.curPlayer.iconColor));

			boyfriend.playAnim("phone", true, true);
			var arm = getGlobalVar("arm");
			arm.playAnim("phone", true, true);
			getGlobalVar("wheel").visible = false;
		}
	}

	if (curStep == 1619 || curStep == 1807)
	{
		game.curOpponent = getGlobalVar("arm");
		if (curStep == 1807)
			game.curPlayer = boyfriend;
	}

	if (curStep == 1743)
	{
		boyfriend.dance();
		game.curPlayer = dad;
	}

	if (curStep == 2152)
	{
		eat.visible = true;
		boyfriend.visible = false;
		eat.animation.play("eat", true);
	}
}

function onUpdate(elapsed:Float)
{
	if (curStep >= 1064 && curStep < 1079 || curStep >= 1881)
	{
		var arm = getGlobalVar("arm");
		if (arm.animation.name == "phone" && arm.animation.curAnim.curFrame == 0)
		{
			getGlobalVar("wheel").visible = false;
			arm.playAnim("wheel", true);
		}
	}

	for (i in 0...8)
	{
		setNoteX(defaultStrumPos[i].x + (1 - (elapsed * 3.125)) * (strumLineNotes[i].x - defaultStrumPos[i].x), i);
	}

	camHUD.angle = FlxMath.lerp(hudAngle, camHUD.angle, FlxMath.bound(1 - (elapsed * 25.125), 0, 1));
}

function onPlayerNoteHit(note:Note)
{
	if (curStep >= 416 && curStep <= 420)
	{
		camGame.zoom += 0.02;
	}
}
