var peeps:FlxSprite;
var bg:FlxSprite;
var hands:FlxSprite;
var phands:FlxSprite;
var seats:FlxSprite;

function onCreate()
{
	bg = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));
	bg.antialiasing = true;
	add(bg);

	peeps = new FlxSprite(19, 65);
	peeps.frames = Paths.getSparrowAtlas('freeplay/peeps');
	peeps.animation.addByPrefix('bop', 'people', 24, false);
	peeps.animation.play("bop");
	peeps.origin.set(0, 0);
	peeps.scale.set(0.67, 0.67);
	peeps.antialiasing = true;
	add(peeps);

	var chairs:FlxSprite = new FlxSprite(319, 134).loadGraphic(Paths.image('freeplay/chairs'));
	chairs.antialiasing = true;
	add(chairs);

	add(dad);

	seats = new FlxSprite().loadGraphic(Paths.image('freeplay/frontChairs'));
	seats.antialiasing = true;
	add(seats);

	hands = new FlxSprite();
	hands.scale.set(0.67, 0.67);
	hands.frames = Paths.getSparrowAtlas('characters/scarlet/hands');
	hands.animation.addByPrefix("come", "scarlet", 24, false);
	hands.animation.play("come");
	hands.antialiasing = true;
	setGlobalVar("hands", hands);

	phands = new FlxSprite(259, 16);
	phands.frames = Paths.getSparrowAtlas("characters/pepper/hands", "shared");
	phands.animation.addByPrefix("idle", "pepper", 24, false);
	phands.animation.play('idle');
	phands.scale.set(0.67, 0.67);
	phands.antialiasing = true;
}

function onCreatePost()
{
	boyfriend.setPosition(742, 115);
	gf.setPosition(154, 291);

	dad.x += 250;
	dad.y -= 110;

	var table:FlxSprite = new FlxSprite(257, 385).loadGraphic(Paths.image('freeplay/table'));
	table.antialiasing = true;
	add(table);

	hands.visible = false;
	add(hands);
	add(phands);
	hands.setPosition(bg.x + 255, bg.y + 350);

	dad.scale.set(0.67, 0.67);
	for (ii in dad.animOffsets.keys())
	{
		dad.animOffsets[ii] = [dad.animOffsets[ii][0] * 0.67, dad.animOffsets[ii][1] * 0.67];
	}

	game.camZooming = true;
	game.disableCamera = true;
	snapCamera(new FlxPoint(bg.width / 2, bg.height / 2));
}

function onBeatHit(curBeat)
{
	peeps.animation.play("bop");
	phands.animation.play("idle");
}
