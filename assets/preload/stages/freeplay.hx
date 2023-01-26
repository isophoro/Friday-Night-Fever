import PlayState;

var peeps:FlxSprite;
var bg:FlxSprite;
var hands:FlxSprite;
var phands:FlxSprite;
var seats:FlxSprite;
var classic:FlxSprite;
var frenzy:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = 1;
	camGame.zoom = 1;
	camHUD.alpha = 0;
	FlxTween.tween(camHUD, {alpha: 1}, 0.76, {ease: FlxEase.quadInOut});

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

	if (PlayState.SONG.song == "Mechanical")
	{
		hands = new FlxSprite();
		hands.scale.set(0.67, 0.67);
		hands.frames = Paths.getSparrowAtlas('characters/scarlet/hands');
		hands.animation.addByPrefix("come", "scarlet", 24, false);
		hands.animation.play("come");
		hands.antialiasing = true;
		setGlobalVar("hands", hands);
	}

	phands = new FlxSprite(259, 16);
	phands.frames = Paths.getSparrowAtlas("characters/pepper/hands", "shared");
	phands.animation.addByPrefix("idle", "pepper", 24, false);
	phands.animation.play('idle');
	phands.scale.set(0.67, 0.67);
	phands.antialiasing = true;
	setGlobalVar("phands", phands);

	classic = new FlxSprite(609, 456);
	classic.frames = Paths.getSparrowAtlas("freeplay/classicm");
	classic.animation.addByPrefix("n", "Classicn", 0);
	classic.animation.addByPrefix("s", "Classics", 0);
	classic.animation.play(hands == null ? 's' : 'n');
	classic.scale.set(0.67, 0.67);
	classic.antialiasing = true;

	frenzy = new FlxSprite(374, 456);
	frenzy.frames = Paths.getSparrowAtlas("freeplay/frenzym");
	frenzy.animation.addByPrefix("n", "Frenzyn", 0);
	frenzy.animation.addByPrefix("s", "Frenzys", 0);
	frenzy.animation.play(hands == null ? 'n' : 's');
	frenzy.scale.set(0.67, 0.67);
	frenzy.antialiasing = true;
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
	add(classic);
	add(frenzy);

	if (hands != null)
	{
		hands.visible = false;
		add(hands);
		hands.setPosition(bg.x + 255, bg.y + 350);
	}
	add(phands);

	if (dad.curCharacter == "scarlet-freeplay")
	{
		dad.scale.set(0.67, 0.67);
		for (ii in dad.animOffsets.keys())
		{
			dad.animOffsets[ii] = [dad.animOffsets[ii][0] * 0.67, dad.animOffsets[ii][1] * 0.67];
		}
	}

	game.camZooming = true;
	game.disableCamera = true;
	camGame.target = null;
	camGame.scroll.set(0, 0);
}

function onBeatHit(curBeat)
{
	peeps.animation.play("bop");
	phands.animation.play("idle");
}
