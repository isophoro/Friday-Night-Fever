var bop:FlxSprite;
var leo:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = 0.7;
	game.camZooming = true;

	var bg:FlxSprite = new FlxSprite(-820, -200).loadGraphic(Paths.image(getSong("song") == "Party-Crasher" ? 'yukichi' : 'diner', 'week5'));
	bg.antialiasing = true;
	bg.scrollFactor.set(0.9, 0.9);
	add(bg);

	leo = new FlxSprite(bg.x + 2087, bg.y + 171).loadGraphic(Paths.image('leo', 'week5'));
	leo.origin.set(leo.width / 2, leo.height);
	leo.antialiasing = true;
	leo.scrollFactor.set(0.9, 0.9);
	leo.scale.set(0.9, 0.9);
	add(leo);
	setGlobalVar("leo", leo);

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

	FlxTween.cancelTweensOf(leo);
	leo.scale.set(0.88, 0.9);
	FlxTween.tween(leo, {"scale.y": 0.86, "scale.x": 0.9}, Conductor.crochet / 1000);
}
