var bop:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = 0.7;
	game.camZooming = true;

	var bg:FlxSprite = new FlxSprite(-820, -200).loadGraphic(Paths.image(getSong("song") == "Party-Crasher" ? 'yukichi' : 'diner', 'week5'));
	bg.antialiasing = true;
	bg.scrollFactor.set(0.9, 0.9);
	add(bg);

	bop = new FlxSprite(-420, 730);
	bop.frames = Paths.getSparrowAtlas('crowd', 'week5');
	bop.animation.addByPrefix("bop", "people", 24, false);
	bop.animation.play("bop");
	bop.antialiasing = true;
	bop.scrollFactor.set(0.85, 0.85);
	setGlobalVar("bop", bop);
}

function onCreatePost()
{
	add(bop);
}

function onBeatHit()
{
	bop.animation.play("bop");
}
