var peeps:FlxSprite;
var bg:FlxSprite;
var hands:FlxSprite;

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

	var chairs:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/chairs'));
	chairs.antialiasing = true;
	add(chairs);

	hands = new FlxSprite();
	hands.scale.set(0.67, 0.67);
	hands.frames = Paths.getSparrowAtlas('characters/scarlet/hands');
	hands.animation.addByPrefix("come", "scarlet", 24, false);
	hands.animation.play("come");
	hands.antialiasing = true;
	setGlobalVar("hands", hands);
}

function onCreatePost()
{
	boyfriend.setPosition(622, -60);
	gf.setPosition(74, 176);
	dad.x += 250;
	dad.y -= 110;

	var table:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/table'));
	table.antialiasing = true;
	add(table);

	hands.visible = false;
	add(hands);
	hands.setPosition(table.x + 255, table.y + 350);

	for (i in [dad, boyfriend, gf])
	{
		i.scale.set(0.67, 0.67);
		for (ii in i.animOffsets.keys())
		{
			i.animOffsets[ii] = [i.animOffsets[ii][0] * 0.67, i.animOffsets[ii][1] * 0.67];
		}
	}

	game.camZooming = true;
	game.disableCamera = true;
	snapCamera(new FlxPoint(bg.width / 2, bg.height / 2));
}

function onBeatHit(curBeat)
{
	peeps.animation.play("bop");
}
