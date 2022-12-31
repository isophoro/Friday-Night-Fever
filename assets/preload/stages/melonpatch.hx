import PlayState;

function onCreate()
{
	game.defaultCamZoom = 0.9;

	var bg:FlxSprite = new FlxSprite(-90, -20).loadGraphic(Paths.image(PlayState.SONG.song == "Retribution" ? 'skyMoon' : 'sky', 'week3'));
	bg.antialiasing = true;
	bg.scrollFactor.set(0.7, 0.7);
	add(bg);

	var outerBuilding:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('mako_buildings_2', 'week3'));
	outerBuilding.antialiasing = true;
	outerBuilding.scrollFactor.set(0.46, 0.7);
	add(outerBuilding);

	var innerBuilding:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('mako_buildings', 'week3'));
	innerBuilding.scrollFactor.set(0.7, 0.8);
	innerBuilding.antialiasing = true;
	add(innerBuilding);

	var ground:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('mako_ground', 'week3'));
	ground.antialiasing = true;
	add(ground);
}
