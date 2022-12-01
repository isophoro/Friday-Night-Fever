setLabel("stage");
import("flixel.effects.FlxFlicker");
import("shaders.ColorShader");

var sky:FlxSprite;
var ads:FlxSprite;
var mainBG:FlxSprite;
var frontBG:FlxSprite;
var makolicious:FlxSprite;
var robos:FlxSprite;
var truck:FlxSprite;
var broken:FlxSprite;
var zombie:FlxSprite;
var glow1:FlxSprite;
var glow2:FlxSprite;

// STREETLIGHT / CAR STUFF
var streetlight:FlxSprite;
var cars:Array<FlxSprite> = [];
var randomWait:Float = 0;
var elapsedTimer:Float = 0;
var streetlightTimer:Float = 0;
var streetlightMaxTime:Float = 8;

//
var zombFlicker:Bool = false;

function image(img:String)
{
	return Paths.image("roboStage/C354R/" + img, 'shared');
}

function centerSpriteX(sprite1, sprite2)
{
	return sprite1.x + (sprite1.width / 2) - (sprite2.width / 2);
}

function centerSpriteY(sprite1, sprite2)
{
	return sprite1.y + (sprite1.height / 2) - (sprite2.height / 2);
}

function onCreate()
{
	game.defaultCamZoom = 0.41;

	sky = new FlxSprite(-1350, -800).loadGraphic(image("sky"));
	sky.antialiasing = true;
	add(sky);

	makolicious = new FlxSprite(-1350, -550);
	makolicious.frames = Paths.getSparrowAtlas("roboStage/C354R/tower");
	makolicious.animation.addByPrefix("normal", "building0", 24, true);
	makolicious.animation.addByPrefix("MAKO", "building mako0", 24, false);
	makolicious.animation.addByPrefix("weewoo", "building mako loop", 24, true);
	makolicious.animation.play("normal");
	makolicious.antialiasing = true;
	add(makolicious);

	robos = new FlxSprite(-1350, -430);
	robos.frames = Paths.getSparrowAtlas("roboStage/C354R/robots");
	robos.animation.addByPrefix("loop", "robot", 24, true);
	robos.animation.play("loop");
	robos.antialiasing = true;
	robos.visible = false;
	add(robos);

	ads = new FlxSprite(-1350, -800).loadGraphic(image("ads"));
	ads.antialiasing = true;
	add(ads);

	mainBG = new FlxSprite(-1350, -800).loadGraphic(image("back_bg"));
	mainBG.antialiasing = true;
	add(mainBG);

	zombie = new FlxSprite();
	zombie.frames = Paths.getSparrowAtlas("roboStage/C354R/zog");
	zombie.animation.addByPrefix("zog", "zogs0", 24, true);
	zombie.animation.addByPrefix("EXPLODE", "zogs explod0", 24, false);
	zombie.animation.play("zog");
	zombie.antialiasing = true;
	add(zombie);
	setGlobalVar("zombie", zombie);

	zombie.setPosition(centerSpriteX(mainBG, zombie) - 850, centerSpriteY(mainBG, zombie) - 60);

	makolicious.x = centerSpriteX(mainBG, makolicious) + 88;
	robos.x = makolicious.x - 250;

	truck = new FlxSprite();
	truck.frames = Paths.getSparrowAtlas("roboStage/C354R/foodtruck");
	truck.animation.addByPrefix("bop", "food truck", 24, false);
	truck.animation.play("bop");
	truck.antialiasing = true;
	add(truck);

	truck.setPosition(centerSpriteX(mainBG, truck) + 1200, centerSpriteY(mainBG, truck) + 70);

	broken = new FlxSprite(-910, 865);
	broken.frames = Paths.getSparrowAtlas("roboStage/C354R/light");
	broken.animation.addByPrefix("idle", "light broken", 24, true);
	broken.animation.play("idle");
	broken.antialiasing = true;
	add(broken);

	streetlight = new FlxSprite(1350, -760);
	streetlight.frames = Paths.getSparrowAtlas("roboStage/C354R/streetlight");
	streetlight.animation.addByPrefix("stop", "street light stop", 24, true);
	streetlight.animation.addByPrefix("go", "street light go", 24, true);
	streetlight.animation.play("stop");
	streetlight.antialiasing = true;
	add(streetlight);

	frontBG = new FlxSprite(-1350, -800).loadGraphic(image("front_stuff"));
	frontBG.antialiasing = true;
	add(frontBG);

	glow1 = new FlxSprite(-1350, -800).loadGraphic(image("glow"));
	glow1.antialiasing = true;
	add(glow1);

	glow2 = new FlxSprite(-1350, -800).loadGraphic(image("top_glow"));
	glow2.antialiasing = true;
	add(glow2);
}

function onCreatePost()
{
	gf.x -= 120;
	gf.scrollFactor.set(1, 1);

	dad.y -= 365;
	dad.x += 200;
	dad.scrollFactor.set(1, 1);

	remove(gf);
	add(gf, getIndexOfMember(frontBG));
}

function onUpdate(elapsed:Float)
{
	if (!robos.visible && makolicious.animation.curAnim.name == "MAKO" && makolicious.animation.curAnim.curFrame >= 60)
	{
		robos.visible = true;
		robos.animation.play("loop", true);
	}

	if (!zombFlicker && zombie.animation.curAnim.name == "EXPLODE" && zombie.animation.curAnim.curFrame > 22)
	{
		zombFlicker = true;
		FlxFlicker.flicker(zombie, 0.5, 0.06, false, false);
	}

	if (streetlight.animation.curAnim.name == "go")
	{
		streetlightTimer += elapsed;

		if (streetlightTimer >= streetlightMaxTime && cars.length < 1)
		{
			trace("streetlight stop");
			streetlightTimer = 0;

			streetlight.animation.play("stop");
			streetlight.centerOffsets();
			streetlight.offset.x = 0;
		}

		if (streetlightTimer != 0 && streetlightTimer < streetlightMaxTime)
		{
			if (elapsedTimer >= randomWait)
			{
				elapsedTimer = 0;
				randomWait = FlxG.random.float(0.4, 0.95);
				spawnCar();
			}
			else
				elapsedTimer += elapsed;
		}
	}

	var cringeCars = [];
	for (car in cars)
	{
		if (car.x >= gf.x - 150 && car.ID == 0)
		{
			car.ID = 1;
			gf.animation.play("hairBlow", true);
		}

		if (car.ID == 1 && car.x + car.width > mainBG.x + mainBG.width)
		{
			trace("killing car");
			car.kill();
			cringeCars.push(car);
		}
	}

	for (i in cringeCars)
		cars.remove(i);

	if (gf.animation.curAnim.name == "hairBlow" && gf.animation.curAnim.finished)
		gf.animation.play("hairFall", true);
}

function spawnCar()
{
	trace("spawning car");
	var cShader = new ColorShader();
	cShader.hue = FlxG.random.float(-1, 1);
	cShader.onUpdate();

	var carNum = FlxG.random.int(1, 3);
	var car:FlxSprite = new FlxSprite(-8550, boyfriend.y - 125 + (carNum == 3 ? -85 : 0)).loadGraphic(image("car_" + carNum));
	car.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
	car.scale.set(1.3, 1.3);
	car.ID = 0;
	car.shader = cShader;
	add(car, getIndexOfMember(truck) + 1);
	cars.push(car);
	trace("car added");

	FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
}

function onBeatHit(curBeat:Int)
{
	truck.animation.play("bop", true);

	switch (streetlight.animation.curAnim.name)
	{
		case "stop":
			if (curBeat % 12 == 0 && FlxG.random.bool(20))
			{
				trace("streetlight go");
				streetlight.animation.play("go");
				streetlight.centerOffsets();
				streetlight.offset.x += 90;
				streetlightMaxTime = FlxG.random.int(6, 9);
			}
	}

	switch (curBeat)
	{
		case 281:
			makolicious.animation.play("MAKO");
			makolicious.offset.x += 278;
			makolicious.offset.y += 158;
			game.disableCamera = true;
			game.camZooming = true;
			game.camFollow.setPosition(makolicious.x + (makolicious.width / 2), makolicious.y + (makolicious.height / 2));
			game.defaultCamZoom = 0.6;
		case 302:
			game.defaultCamZoom = 0.41;
			game.disableCamera = false;
			game.moveCamera(false);
	}

	if (makolicious.animation.curAnim.name == "MAKO" && makolicious.animation.finished || makolicious.animation.curAnim.name == "weewoo")
	{
		if (curBeat % 2 == 0)
		{
			makolicious.animation.play("weewoo");
			makolicious.centerOffsets();
			makolicious.offset.x += 58;
		}
	}
}

function onStepHit(curStep:Int)
{
	if (curStep == 1851)
	{
		dad.playAnim("hey", true);
		gf.playAnim("cheer", true);
		boyfriend.playAnim("hey", true);
	}
}
