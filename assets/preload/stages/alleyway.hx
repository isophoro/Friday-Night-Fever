import PlayState;

var whittyBG:FlxSprite;
var princessBG:FlxSprite;
var princessFloor:FlxSprite;
var princessCrystals:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = PlayState.SONG.song == "Bloom" ? 0.6 : 0.7;

	whittyBG = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/alleywaybroken'));
	whittyBG.antialiasing = true;
	whittyBG.scrollFactor.set(0.9, 0.9);
	whittyBG.scale.set(1.25, 1.25);
	add(whittyBG);
	setGlobalVar("whittyBG", whittyBG);

	if (PlayState.SONG.song == 'Princess')
	{
		princessBG = new FlxSprite(-446, -611).loadGraphic(Paths.image('roboStage/princessBG'));
		princessBG.antialiasing = true;
		princessBG.scrollFactor.set(0.75, 0.8);
		princessBG.scale.set(1.25, 1.25);
		add(princessBG);
		princessBG.visible = false;

		princessFloor = new FlxSprite(-446, -611).loadGraphic(Paths.image('roboStage/princessFloor'));
		princessFloor.antialiasing = true;
		princessFloor.scrollFactor.set(0.9, 0.9);
		princessFloor.scale.set(1.25, 1.25);
		add(princessFloor);
		princessFloor.visible = false;

		princessCrystals = new FlxSprite(-446, -591).loadGraphic(Paths.image('roboStage/princessCrystals'));
		princessCrystals.antialiasing = true;
		princessCrystals.scrollFactor.set(0.9, 0.9);
		princessCrystals.scale.set(1.25, 1.25);
		add(princessCrystals);
		princessCrystals.visible = false;
		FlxTween.tween(princessCrystals, {y: princessCrystals.y - 70}, 3.4, {type: FlxTweenType.PINGPONG});
	}
}

function onStepHit(curStep)
{
	if (PlayState.SONG.song.toLowerCase() == 'princess')
	{
		switch (curStep)
		{
			case 128:
				camHUD.flash(FlxColor.WHITE, 0.5);
				princessBG.visible = true;
				princessFloor.visible = true;
				princessCrystals.visible = true;
				game.defaultCamZoom = 0.65;
				gf.y += 60;
		}
	}
}
