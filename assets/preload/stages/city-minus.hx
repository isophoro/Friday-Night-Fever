var roach:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = 0.5;

	var sky = new FlxSprite(290, -340).loadGraphic(Paths.image("roboStage/grando/sky"));
	sky.scrollFactor.set(0.96, 0.96);
	sky.antialiasing = true;
	sky.scale.scale(1.65);
	add(sky);

	var bg = new FlxSprite(-370, -100).loadGraphic(Paths.image("roboStage/grando/bg"));
	bg.antialiasing = true;
	bg.scale.scale(1.65);
	add(bg);

	roach = new FlxSprite(bg.x + (614 * 1.65) - 750, bg.y + (886 * 1.65) - 350);
	roach.frames = Paths.getSparrowAtlas("roboStage/grando/roach");
	roach.animation.addByPrefix("bop", "roach", 24, false);
	roach.antialiasing = true;
	roach.scale.set(1.65, 1.65);
	add(roach);
}

function onCreatePost()
{
	gf.scrollFactor.set(1, 1);
	dad.x -= 150;
	boyfriend.x += 230;
	boyfriend.y -= 75;
}

function onBeatHit(curBeat:Int)
{
	roach.animation.play("bop");
}
