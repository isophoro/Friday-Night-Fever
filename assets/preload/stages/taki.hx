function onCreate()
{
	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("takiBG", "week2"));
	bg.antialiasing = true;
	add(bg);
	setGlobalVar("bg", bg);

	dad.x += 150;
	dad.y += 50;
	boyfriend.setPosition(1850, 1200);
	gf.setPosition(1280, 815);

	BF_CAM_OFFSET.y -= 200;
	DAD_CAM_OFFSET.x += 170;
}

function onCreatePost()
{
	camGame.zoom = game.defaultCamZoom = 0.47;
	gf.scrollFactor.set(1, 1);
}

function onOpponentNoteHit()
{
	game.disableCamera = false;
}
