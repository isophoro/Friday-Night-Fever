// the "city" stage from V.S Taki Mod
setLabel("stage");
import("flixel.effects.FlxFlicker");
import("shaders.ColorShader");

var sky:FlxSprite;
var mainBG:FlxSprite;
var frontBG:FlxSprite;
var lights:FlxSprite;
var tower:FlxSprite;
var makolicious:FlxSprite;
var debra:FlxSprite;
var robos:FlxSprite;
var truck:FlxSprite;
var broken:FlxSprite;
var zombie:FlxSprite;
var glow1:FlxSprite;
var glow2:FlxSprite;
var zombFlicker:Bool = false;

// STREETLIGHT / CAR STUFF
var streetlight:FlxSprite;
var cars:Array<FlxSprite> = [];
var randomWait:Float = 0;
var elapsedTimer:Float = 0;
var streetlightTimer:Float = 0;
var streetlightMaxTime:Float = 8;
var adsGrp:Array<FlxSprite> = [];

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
	game.defaultCamZoom = 0.36;

	sky = new FlxSprite(-1450, -900).loadGraphic(image("sky"));
	sky.antialiasing = true;
	add(sky);

	makolicious = new FlxSprite(-1350, -650);
	makolicious.frames = Paths.getSparrowAtlas("roboStage/C354R/tower");
	makolicious.animation.addByPrefix("normal", "building0", 24, true);
	makolicious.animation.addByPrefix("MAKO", "building mako0", 24, false);
	makolicious.animation.addByPrefix("weewoo", "building mako loop", 24, true);
	makolicious.animation.play("normal");
	makolicious.antialiasing = true;

	tower = new FlxSprite(-1350, -650);
	tower.frames = Paths.getSparrowAtlas("roboStage/C354R/peakek");
	tower.animation.addByPrefix("normal", "building0", 24, true);
	tower.animation.play("normal");
	tower.antialiasing = true;
	add(tower);

	robos = new FlxSprite(-1350, -430);
	robos.frames = Paths.getSparrowAtlas("roboStage/C354R/robots");
	robos.animation.addByPrefix("loop", "robot", 24, true);
	robos.animation.play("loop");
	robos.antialiasing = true;
	robos.visible = false;
	add(robos);

	createAd("hallow_ad", 21, 120, 1.25, "hallow ad", false);
	createAd("milk_ad", 581, 120, 1.22, "straw ad", false);
	createAd("roll_ad", 1081, 120, 1.22, "roll ad", true);
	createAd("Shino_ad", 2534, 419, 1.22, "shino", false);
	createAd("RaeCody_ad", 2537, 106, 1.22, "soulsplit", false);
	// tacky tacky tacky but dont make her unhappy
	createAd("taki_ad", 3518, 106, 1.22, "tacky tacky tacky sweet like laff", false);
	// don't question it

	mainBG = new FlxSprite(sky.x, sky.y).loadGraphic(image("back_bg"));
	mainBG.antialiasing = true;
	add(mainBG);

	lights = new FlxSprite(sky.x, sky.y).loadGraphic(image("building_lights"));
	lights.antialiasing = true;
	add(lights);

	debra = new FlxSprite(sky.x, sky.y).loadGraphic(image("debris_bg"));
	debra.antialiasing = true;
	add(debra);

	zombie = new FlxSprite();
	zombie.frames = Paths.getSparrowAtlas("roboStage/C354R/zog");
	zombie.animation.addByPrefix("zog", "zogs0", 24, true);
	zombie.animation.addByPrefix("EXPLODE", "zogs explod0", 24, false);
	zombie.animation.play("zog");
	zombie.antialiasing = true;
	add(zombie);
	setGlobalVar("zombie", zombie);

	zombie.setPosition(centerSpriteX(mainBG, zombie) - 850, centerSpriteY(mainBG, zombie));

	makolicious.x = centerSpriteX(mainBG, makolicious) + 88;
	tower.x = centerSpriteX(mainBG, makolicious) + 88;
	robos.x = makolicious.x - 250;

	truck = new FlxSprite();
	truck.frames = Paths.getSparrowAtlas("roboStage/C354R/foodtruck");
	truck.animation.addByPrefix("bop", "food truck", 24, false);
	truck.animation.play("bop");
	truck.antialiasing = true;
	add(truck);

	truck.setPosition(centerSpriteX(mainBG, truck) + 1700, centerSpriteY(mainBG, truck) + 120);

	broken = new FlxSprite(-920, 765);
	broken.frames = Paths.getSparrowAtlas("roboStage/C354R/light");
	broken.animation.addByPrefix("idle", "light broken", 24, true);
	broken.animation.play("idle");
	broken.antialiasing = true;

	streetlight = new FlxSprite(1350, -760);
	streetlight.frames = Paths.getSparrowAtlas("roboStage/C354R/streetlight");
	streetlight.animation.addByPrefix("stop", "street light stop", 24, true);
	streetlight.animation.addByPrefix("go", "street light go", 24, true);
	streetlight.animation.play("stop");
	streetlight.antialiasing = true;
	add(streetlight);

	frontBG = new FlxSprite(sky.x, sky.y).loadGraphic(image("front_stuff"));
	frontBG.antialiasing = true;
	add(frontBG);
	add(broken);

	glow1 = new FlxSprite(sky.x, sky.y).loadGraphic(image("glow"));
	glow1.antialiasing = true;
	add(glow1);

	glow2 = new FlxSprite(sky.x, sky.y).loadGraphic(image("top_glow"));
	glow2.antialiasing = true;
	add(glow2);

	for (i in [boyfriend, dad, gf, zombie, broken])
		i.color = 0xFFC681C6;
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

	remove(boyfriend);
	add(boyfriend, getIndexOfMember(frontBG));
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

	FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.4);
}

function onBeatHit(curBeat:Int)
{
	truck.animation.play("bop", true);

	for (i in adsGrp)
		if (i.ID == 1)
			i.animation.play("animation");

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
			game.camFollow.setPosition(makolicious.x + (makolicious.width / 2), makolicious.y + (makolicious.height / 2) - 50);
			game.defaultCamZoom = 0.65;
		case 287:
			FlxTween.tween(camHUD, {alpha: 0.2}, 0.7);
		case 302:
			game.defaultCamZoom = 0.41;
			game.disableCamera = false;
			game.moveCamera(false);
			FlxTween.tween(camHUD, {alpha: 1}, 0.3);
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

function createAd(img:String, x:Int, y:Int, scale:Float, anim:String, bop:Bool = false)
{
	trace('creating ad');
	var ad:FlxSprite = new FlxSprite(sky.x + x, sky.y + y);
	ad.frames = Paths.getSparrowAtlas("roboStage/C354R/" + img);
	ad.animation.addByPrefix("animation", anim, 24, !bop);
	ad.ID = bop ? 1 : 0;
	ad.animation.play("animation");
	ad.origin.set(0, 0);
	ad.scale.scale(scale);
	ad.antialiasing = true;
	add(ad);
	adsGrp.push(ad);
	trace("ad create");
}
