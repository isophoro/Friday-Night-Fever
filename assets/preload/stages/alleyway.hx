import PlayState;
import openfl.filters.ShaderFilter;
import shaders.WiggleEffect;

var whittyBG:FlxSprite;
var princessBG:FlxSprite;
var princessFloor:FlxSprite;
var princessCrystals:FlxSprite;
var clocks:FlxSprite;
var clockScar:FlxSprite;
var clockFever:FlxSprite;
var wiggleEffect:WiggleEffect;

function onCreate()
{
	game.defaultCamZoom = PlayState.SONG.song == "Bloom" ? 0.6 : 0.7;

	whittyBG = new FlxSprite(-728, -230).loadGraphic(Paths.image(PlayState.SONG.song == "Bloom" ? 'roboStage/alleyway-night' : 'roboStage/alleywaybroken'));
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
	else if (PlayState.SONG.song == "Bloom")
	{
		clocks = new FlxSprite(200, 80).loadGraphic(Paths.image("roboStage/princessClocks"));
		clocks.scale.set(2.55, 2.55);
		clocks.antialiasing = true;
		add(clocks);
		clocks.visible = false;

		clockScar = new FlxSprite(-190, 680).loadGraphic(Paths.image("roboStage/princessClock"));
		clockScar.scale.set(1.65, 1.65);
		clockScar.antialiasing = true;
		add(clockScar);
		clockScar.visible = false;

		clockFever = new FlxSprite(990, 695).loadGraphic(Paths.image("roboStage/princessClock"));
		clockFever.scale.set(1.25, 1.25);
		clockFever.antialiasing = true;
		add(clockFever);
		clockFever.visible = false;

		wiggleEffect = new WiggleEffect();
		wiggleEffect.shader.effectType.value = [4]; // non h-scriptphobic version
		wiggleEffect.waveAmplitude = 0.02;
		wiggleEffect.waveFrequency = 3;
		wiggleEffect.waveSpeed = 0.71;

		clocks.shader = wiggleEffect.shader;
		setGlobalVar("shader", wiggleEffect.shader);
		setGlobalVar("bgElements", [clocks, clockScar, clockFever]);
		dad.color = 0xFFA569BC;
		boyfriend.color = 0xFFA569BC;
	}
}

function onUpdate(elapsed:Float)
{
	if (wiggleEffect != null)
		wiggleEffect.update(elapsed);
}

function onCreatePost()
{
	clockScar.scrollFactor.set(dad.scrollFactor.x, dad.scrollFactor.y);
	clockFever.scrollFactor.set(boyfriend.scrollFactor.x, boyfriend.scrollFactor.y);
}

function onStepHit(curStep)
{
	switch (PlayState.SONG.song.toLowerCase())
	{
		case 'princess':
			if (curStep == 128)
			{
				camHUD.flash(FlxColor.WHITE, 0.5);
				princessBG.visible = true;
				princessFloor.visible = true;
				princessCrystals.visible = true;
				game.defaultCamZoom = 0.65;
				gf.y += 60;
			}
		case 'bloom':
			if (curStep == 256)
			{
				dad.color = boyfriend.color = FlxColor.WHITE;
				game.defaultCamZoom = 0.53;
				camHUD.flash(FlxColor.WHITE, 0.5);
				clocks.visible = true;
				clockScar.visible = true;
				clockFever.visible = true;
			}
	}
}
