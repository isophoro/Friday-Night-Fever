import ("Character");

var bgF:FlxSprite;
var bgR:FlxSprite;
var bgRCar:FlxSprite;
var charF:Character;
var charR:Character;
var blackBars = [];
var splitBG1:FlxSprite;
var splitBG2:FlxSprite;
var rfront:FlxSprite;
var rback:FlxSprite;

function onCreate()
{
	forceComboPos = new FlxPoint(FlxG.width * (ClientPrefs.downscroll ? 0.78 : 0.05), 30);

	rback = new FlxSprite(-625, 130);
	rback.frames = Paths.getSparrowAtlas('roboStage/C354R/back');
	rback.animation.addByPrefix('bop', 'bg', 24, false);
	rback.animation.play('bop');
	rback.origin.set(0, 0);
	rback.scale.set(2.45, 2.45);
	rback.antialiasing = true;
	add(rback, getIndexOfMember(getGlobalVar("mainBG")) + 3);
	rback.alpha = 0.00009;

	rfront = new FlxSprite(-1125, 680);
	rfront.frames = Paths.getSparrowAtlas('roboStage/C354R/front');
	rfront.animation.addByPrefix('bop', 'bg', 24, false);
	rfront.animation.play('bop');
	rfront.origin.set(0, 0);
	rfront.scale.set(2.1, 2.1);
	rfront.antialiasing = true;
	add(rfront);
	rfront.alpha = 0.00009;

	splitBG1 = new FlxSprite(-750, -120).loadGraphic(Paths.image("roboStage/C354R/split1"));
	splitBG1.antialiasing = true;
	splitBG1.scale.set(1.62, 1.62);
	add(splitBG1);
	splitBG1.visible = false;

	splitBG2 = new FlxSprite(-750, -120).loadGraphic(Paths.image("roboStage/C354R/split2"));
	splitBG2.antialiasing = true;
	splitBG2.scale.set(1.62, 1.62);
	add(splitBG2);
	splitBG2.visible = false;

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
	rfront.animation.play('bop');
	rback.animation.play("bop");
	if (curBeat >= 32 && curBeat < 64 && curBeat % 2 == 0 || curBeat >= 384 && curBeat < 448)
	{
		camGame.zoom += 0.02;
		FlxTween.tween(camGame, {zoom: 0.6}, 0.2);
	}

	if (curBeat == 32 || curBeat == 48)
	{
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

		game.defaultCamZoom = 0.6;
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

		game.defaultCamZoom = 0.36;
		camGame.flash(FlxColor.WHITE, 0.45);
		bgF.visible = charF.visible = false;
		game.curPlayer = boyfriend;
		game.curOpponent = dad;
		game.disableCamera = false;
		game.moveCamera(true);
		snapCamera(camFollow);
		// camGame.zoom = game.defaultCamZoom;
	}
	else if (curBeat == 384)
	{
		for (i in blackBars)
			i.visible = true;

		camGame.flash(FlxColor.WHITE, 0.45);
		game.disableCamera = true;
		game.disableModCamera = true;
		snapCamera(new FlxPoint(bgR.x + (bgR.width / 2), bgR.y + (bgR.height / 2) - 100));
		bgRCar.visible = splitBG1.visible = true;
		splitBG2.visible = true;
		game.defaultCamZoom = 0.6;
		camGame.zoom = 0.6;
		game.curOpponent = charR;
		game.curPlayer = charF;
		charF.visible = charR.visible = true;
		charR.setPosition(splitBG1.x + 125, splitBG1.y - 50);
		charF.setPosition(splitBG1.x + 991, splitBG1.y + 55);

		camGame.scroll.y += 80;
		FlxTween.tween(camGame.scroll, {y: camGame.scroll.y - 80}, 0.8, {ease: FlxEase.quartInOut});
		game.remove(bgRCar, true);
		add(bgRCar, getIndexOfMember(splitBG1) + 1);

		game.remove(charR, true);
		add(charR, getIndexOfMember(splitBG1) + 1);
	}
	else if (curBeat == 448)
	{
		for (i in blackBars)
			i.visible = false;

		camGame.flash(FlxColor.WHITE, 0.45);
		game.disableCamera = false;
		game.disableModCamera = false;
		charF.visible = charR.visible = false;
		splitBG1.visible = splitBG2.visible = bgRCar.visible = false;
		game.curPlayer = boyfriend;
		game.curOpponent = dad;
		game.moveCamera(true);
		snapCamera(camFollow);
		rfront.alpha = 1;
		rback.alpha = 1;
		game.defaultCamZoom = 0.36;
	}
}
