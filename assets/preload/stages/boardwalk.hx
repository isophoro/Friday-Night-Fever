function onCreate()
{
	game.defaultCamZoom = 0.65;
	game.camZooming = true;

	for (i in ["sky", "city", "water", "boardwalk"])
	{
		var spr = new FlxSprite(-300, -300).loadGraphic(Paths.image(i, 'week4'));
		spr.scale.set(1.4, 1.4);
		spr.antialiasing = true;
		add(spr);
	}
}

function onCreatePost()
{
	boyfriend.setPosition(850, 395);
	for (i in [boyfriend, dad, gf])
		i.scrollFactor.set(1, 1);
}
