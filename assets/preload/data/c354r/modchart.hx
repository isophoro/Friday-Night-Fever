import ("Character");

var bgF:FlxSprite;
var bgR:FlxSprite;
var charF:Character;
var charR:Character;

function onCreate()
{
	trace("we here");

	bgF = new FlxSprite(-750, -120).loadGraphic(Paths.image("roboStage/C354R/perspectiveF"));
	bgF.antialiasing = true;
	bgF.scale.scale(1.25);
	add(bgF);
	bgF.visible = false;

	charF = new Character(0, 0, "bf-perspective", true);
	add(charF);
	charF.visible = false;

	bgR = new FlxSprite(-750, -150).loadGraphic(Paths.image("roboStage/C354R/perspectiveR"));
	bgR.antialiasing = true;
	bgR.scale.scale(1.62);
	add(bgR);
	bgR.visible = false;

	charR = new Character(-300, -400, "robo-fever-perspective", false);
	add(charR);
	charR.visible = false;

	for (i in [charR, charF, bgR, bgF])
		i.color = 0xFFC681C6;
}

function onBeatHit(curBeat:Int)
{
	if (curBeat >= 32 && curBeat < 64 && curBeat % 2 == 0)
	{
		camGame.zoom += 0.02;
		FlxTween.tween(camGame, {zoom: 0.6}, 0.2);
	}

	if (curBeat == 32 || curBeat == 48)
	{
		forceComboPos = new FlxPoint(FlxG.width * (ClientPrefs.downscroll ? 0.78 : 0.05), 30);
		game.disableCamera = true;
		snapCamera(new FlxPoint(bgR.x + (bgR.width / 2), bgR.y + (bgR.height / 2) - 100));

		if (curBeat == 32)
		{
			camGame.flash(FlxColor.WHITE, 0.45);
			camGame.scroll.y += 80;
			FlxTween.tween(camGame.scroll, {y: camGame.scroll.y - 80}, 0.8, {ease: FlxEase.quartInOut});
		}

		game.camGame.zoom = 0.6;
		game.curOpponent = charR;
		charR.visible = bgR.visible = true;
	}
	else if (curBeat == 40 || curBeat == 56)
	{
		snapCamera(new FlxPoint(bgF.x + (bgF.width / 2), bgF.y + (bgF.height / 2) - 100));
		if (curBeat == 40)
		{
			camGame.scroll.x -= 80;
			FlxTween.tween(camGame.scroll, {x: camGame.scroll.x + 80}, 0.8, {ease: FlxEase.quartInOut});
		}
		game.curPlayer = charF;
		charR.visible = bgR.visible = false;
		bgF.visible = charF.visible = true;
	}
	else if (curBeat == 64)
	{
		forceComboPos = null;
		camGame.flash(FlxColor.WHITE, 0.45);
		bgF.visible = charF.visible = false;
		game.curPlayer = boyfriend;
		game.curOpponent = dad;
		game.disableCamera = false;
		game.moveCamera(true);
		snapCamera(camFollow);
		// camGame.zoom = game.defaultCamZoom;
	}
}
