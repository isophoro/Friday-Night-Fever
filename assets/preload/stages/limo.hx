import flixel.math.FlxPoint;

var bunnies = [];

function onCreate()
{
	game.defaultCamZoom = 0.6;

	var bg:FlxSprite = new FlxSprite(-1100, -360).loadGraphic(Paths.image("limo/bg", "week4"));
	bg.antialiasing = true;
	bg.scale.set(0.9, 0.9);
	add(bg);

	var lines = new FlxSprite(-995, 500);
	lines.frames = Paths.getSparrowAtlas("limo/road", "week4");
	lines.animation.addByPrefix("idle", "road", 24, true);
	lines.animation.play("idle");
	lines.antialiasing = true;
	lines.scale.set(0.9, 0.9);
	add(lines);
	setGlobalVar("lines", lines);

	carBG = new FlxSprite(-845, 480);
	carBG.frames = Paths.getSparrowAtlas("limo/limoBG", "week4");
	carBG.animation.addByPrefix("idle", "limobg", 24, true);
	carBG.animation.play("idle");
	carBG.antialiasing = true;
	carBG.scale.set(0.9, 0.9);
	add(carBG);

	for (i in 0...3)
	{
		var bunny:FlxSprite = new FlxSprite(-145 + (160 * i), 236 - (30 * i));
		bunny.frames = Paths.getSparrowAtlas("limo/bunnyboppers", "week4");
		bunny.animation.addByPrefix("idle", "bunnicus", 24, true);
		bunny.animation.play("idle");
		bunny.antialiasing = true;
		bunny.scale.set(0.9, 0.9);
		add(bunny);
		bunnies.push(bunny);
	}

	carFG = new FlxSprite(-565, 555);
	carFG.frames = Paths.getSparrowAtlas("limo/limoFG", "week4");
	carFG.animation.addByPrefix("idle", "limofg", 24, true);
	carFG.animation.play("idle");
	carFG.antialiasing = true;
	carFG.scale.set(0.9, 0.9);
	add(carFG);
}

function onCreatePost()
{
	dad.setPosition(15, 170);
	gf.setPosition(310, 169);
	gf.scrollFactor.set(1, 1);

	DAD_CAM_OFFSET.y = 320;
	BF_CAM_OFFSET.x -= 30;
}

function onBeatHit(curBeat)
{
	for (i in bunnies)
		i.animation.play("idle");
}
