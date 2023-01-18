import ("Character");

var bgF:FlxSprite;
var bgR:FlxSprite;
var bgRCar:FlxSprite;
var charF:Character;
var charR:Character;
var blackBars = [];

function onCreate()
{
	trace("we here");

	bgF = new FlxSprite(-750, -120).loadGraphic(Paths.image("roboStage/C354R/perspectiveF"));
	bgF.antialiasing = true;
	bgF.scale.set(1.25, 1.25);
	add(bgF);
	bgF.visible = false;

	charF = new Character(0, 0, "bf-perspective", true);
	add(charF);
	charF.visible = false;

	bgR = new FlxSprite(-750, -150).loadGraphic(Paths.image("roboStage/C354R/perspectiveR"));
	bgR.antialiasing = true;
	bgR.scale.set(1.62, 1.62);
	add(bgR);
	bgR.visible = false;

	charR = new Character(-300, -250, "robo-fever-perspective", false);
	add(charR);
	charR.visible = false;

	bgRCar = new FlxSprite(-750, -150).loadGraphic(Paths.image("roboStage/C354R/perspectiveRCar"));
	bgRCar.antialiasing = true;
	bgRCar.scale.set(1.62, 1.62);
	add(bgRCar);
	bgRCar.visible = false;

	for (i in 0...2)
	{
		var b = new FlxSprite(0, i == 1 ? FlxG.height - 150 : 0).makeGraphic(1280, 150, FlxColor.BLACK);
		b.visible = false;
		b.ID = i;
		blackBars.push(b);
		add(b, 0, camHUD);
	}

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

		for (i in blackBars)
			i.visible = true;

		game.camGame.zoom = 0.6;
		game.curOpponent = charR;
		bgRCar.visible = charR.visible = bgR.visible = true;
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
		bgRCar.visible = charR.visible = bgR.visible = false;
		bgF.visible = charF.visible = true;
	}
	else if (curBeat == 64)
	{
		for (i in blackBars)
			i.visible = false;

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
