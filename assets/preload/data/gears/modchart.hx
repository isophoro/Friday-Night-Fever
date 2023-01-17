import Boyfriend;
import flixel.util.FlxTimer;

// this truly was a friday night fever

var fallBG:FlxSprite;
var fallStreaks:FlxSprite;
var feverFalling:Boyfriend;
var roboFalling:Character;
var roboFallingCool:Character;
var feverTunnel:Boyfriend;
var roboTunnel:Character;
var ogBF:FlxPoint = new FlxPoint(0, 0);
var ogDad:FlxPoint = new FlxPoint(0, 0);

function createCharacter(char:String, x:Float, y:Float)
{
	var _char = new Character(x, y, char, false);
	_char.visible = false;
	return _char;
}

function createBoyfriend(char:String, x:Float, y:Float)
{
	var _char = new Boyfriend(x, y, char);
	_char.visible = false;
	return _char;
}

function setHUDVisible(visible:Bool)
{
	for (i in [iconP1, iconP2, healthBar, healthBarBG, scoreTxt])
		i.visible = visible;

	notes.visible = visible;
	for (i in 0...strumLineNotes.length)
		strumLineNotes[i].visible = visible;
}

function onCreate()
{
	fallBG = new FlxSprite().loadGraphic(Paths.image("roboStage/gears/fallBG"));
	fallBG.visible = false;
	fallBG.antialiasing = true;
	fallBG.scale.set(1.25, 1.25);
	add(fallBG);

	fallStreaks = new FlxSprite();
	fallStreaks.frames = Paths.getSparrowAtlas("roboStage/gears/streaks");
	fallStreaks.animation.addByPrefix("idle", "streaks bg", 24);
	fallStreaks.animation.play("idle");
	fallStreaks.antialiasing = true;
	fallStreaks.scale.set(0.9, 0.9);
	add(fallStreaks);
	fallStreaks.visible = false;

	feverTunnel = createBoyfriend("bf-mad-glow", boyfriend.x, boyfriend.y);
	feverTunnel.scrollFactor.set(boyfriend.scrollFactor.x, boyfriend.scrollFactor.y);
	add(feverTunnel);

	roboTunnel = createCharacter("robo-final-glow", dad.x, dad.y);
	roboTunnel.scrollFactor.set(dad.scrollFactor.x, dad.scrollFactor.y);
	add(roboTunnel);

	feverFalling = createBoyfriend("bf-fall", 3350, 1295);
	add(feverFalling);

	roboFalling = createCharacter("robo-fall", 2200, 1030);
	add(roboFalling);

	roboFallingCool = createCharacter("robo-fall-cool", 2200, 1030);
	add(roboFallingCool);

	trace("Finish creating assets");
	snapCamera();

	dad.scale.set(1.14, 1.14);
	dad.y -= 50;
	roboTunnel.scale.set(1.14, 1.14);
	setHUDVisible(false);
}

function onUpdate(elapsed:Float)
{
	if (curBeat >= 528)
	{
		roboFallingCool.visible = roboFallingCool.animation.curAnim.name != "idle";
		roboFalling.visible = !roboFallingCool.visible;
	}
	else if (curBeat == 496)
	{
		roboFalling.visible = true;
		roboFallingCool.visible = false;
	}

	if (FlxG.keys.justPressed.SHIFT)
	{
		shootTrain();
	}

	if (boyfriend.animation.curAnim.name == "fall" && boyfriend.animation.curAnim.curFrame >= 15)
	{
		boyfriend.y += elapsed * 2660;
		boyfriend.x += elapsed * 960;
	}

	if (dad.animation.curAnim.name == "fall" && dad.animation.finished)
	{
		dad.y += elapsed * 3660;
	}
}

var introBumps:Array<Int> = [40, 50, 57, 59, 60, 61, 62, 63];

function onStepHit(curStep:Int)
{
	if (introBumps.contains(curStep))
	{
		camGame.zoom += 0.02;
	}
}

function onBeatHit(curBeat:Int)
{
	handleNonEvents(curBeat);

	switch (curBeat)
	{
		case 205:
			getGlobalVar("enterTunnel")();
		case 206:
			roboTunnel.visible = true;
			dad.visible = false;

			feverTunnel.visible = true;
			boyfriend.visible = false;

			game.curPlayer = feverTunnel;
			game.curOpponent = roboTunnel;
		case 271:
			getGlobalVar("exitTunnel")();
		case 272:
			roboTunnel.visible = false;
			dad.visible = true;

			feverTunnel.visible = false;
			boyfriend.visible = true;

			game.curPlayer = boyfriend;
			game.curOpponent = dad;
		case 428:
			shootTrain();
		case 432:
			boyfriend.setPosition(ogBF.x, ogBF.y);
			dad.setPosition(ogDad.x, ogDad.y);

			camGame.flash(FlxColor.WHITE, 0.45);
			forceComboPos = new FlxPoint(FlxG.width * (ClientPrefs.downscroll ? 0.78 : 0.05), 30);

			var yAdd:Int = ClientPrefs.downscroll ? -200 : 200;
			for (i in [iconP1, iconP2, healthBar, healthBarBG])
			{
				FlxTween.tween(i, {y: i.y + yAdd, alpha: 0}, 0.4, {
					ease: FlxEase.quartInOut,
					onComplete: function(t)
					{
						if (i == healthBarBG)
							FlxTween.tween(scoreTxt, {y: scoreTxt.y + (ClientPrefs.downscroll ? yAdd / 3.3 : 0), alpha: 0.7}, 0.4);
					}
				});
			}

			for (i in [dad, boyfriend, roboTunnel, feverTunnel])
				i.visible = false;

			game.disableCamera = true;
			snapCamera(new FlxPoint(BF_CAM_POS.x - 140, BF_CAM_POS.y + 260));
			game.curPlayer = feverFalling;
			game.curOpponent = roboFalling;

			FlxTween.tween(fallBG, {"scale.x": 2.5, "scale.y": 2.5}, 29);
			fallBG.visible = true;
			fallBG.setPosition(camFollow.x - 800, camFollow.y - 550);
			fallStreaks.visible = true;
			fallStreaks.setPosition(camFollow.x - 900, camFollow.y - 550);

			roboFalling.visible = true;
			feverFalling.visible = true;

			game.defaultCamZoom += 0.635;
			camGame.zoom = game.defaultCamZoom + 0.15;

			for (i in 0...4)
				strumLineNotes[i].visible = false;
		case 495:
			bfAltSuffix = '-cool';
		case 528:
			game.curOpponent = roboFallingCool;
			bfAltSuffix = '';
	}

	if (curBeat >= 464 && curBeat < 496)
	{
		roboFalling.playAnim("idle");
	}
}

function handleNonEvents(curBeat:Int)
{
	switch (curBeat)
	{
		case 1:
			camGame.zoom += 0.02;
		case 4:
			camGame.zoom += 0.02;
		case 8:
			camGame.zoom += 0.02;
		case 16:
			setHUDVisible(true);
	}

	if (curBeat >= 80 && curBeat < 432 && curBeat % 4 == 0)
	{
		camGame.zoom += 0.005;
	}
}

function shootTrain()
{
	trace("SHOOT");
	ogDad.set(dad.x, dad.y);
	ogBF.set(boyfriend.x, boyfriend.y);
	var td = getGlobalVar("trainDeath");
	getGlobalVar("train").visible = false;
	td.visible = true;
	td.animation.play("death", true);
	dad.playAnim("shoot", true);
	new FlxTimer().start(0.26, function(t)
	{
		FlxTween.tween(boyfriend, {x: boyfriend.x + 200}, 0.3, {ease: FlxEase.cubeInOut});
	});
	boyfriend.playAnim("fall");
	camGame.shake(0.09, 0.2);
	dad.animation.finishCallback = function(a)
	{
		trace("finish");
		dad.animation.finishCallback = null;
		dad.playAnim("fall", true);
	}

	game.curOpponent = roboFalling;
	game.curPlayer = feverFalling;
}
