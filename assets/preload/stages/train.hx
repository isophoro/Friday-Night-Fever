import flixel.addons.display.FlxBackdrop;

var buildings1:FlxBackdrop;
var buildings2:FlxBackdrop;
var buildings3:FlxBackdrop;
var sky:FlxSprite;
var train:FlxSprite;
var trainGlow:FlxSprite;
var poles:FlxSprite;
var inTunnel:Bool = false;
var tunnelEnterance:FlxSprite;
var tunnelBG:FlxBackdrop;
var lights:FlxBackdrop;
var fakeTunnelBG:FlxSprite;
var outerBuilding:FlxSprite;
var bomb:FlxSprite;
var trainDeath:FlxSprite;

function onCreate()
{
	setGlobalVar("enterTunnel", enterTunnel);
	setGlobalVar("exitTunnel", exitTunnel);

	game.defaultCamZoom = 0.3;

	sky = new FlxSprite(0, -1000).loadGraphic(Paths.image('roboStage/sky'));
	sky.antialiasing = true;
	sky.scrollFactor.set(0.9, 0.9);
	sky.setGraphicSize(Std.int(sky.width * 1.75));
	sky.updateHitbox();
	add(sky);
	setGlobalVar("sky", sky);

	buildings1 = createBackdrop(Paths.image('roboStage/gears/furthestBuildings'), 0, 0);
	buildings1.antialiasing = true;
	buildings1.scrollFactor.set(0.9, 0.9);
	buildings1.origin.set(0, 0);
	buildings1.setGraphicSize(Std.int(buildings1.width * 1.75));
	buildings1.updateHitbox();
	buildings1.y -= 150;
	buildings1.x -= 600;
	add(buildings1);

	buildings2 = createBackdrop(Paths.image('roboStage/gears/middleBuildings'), 0, 0);
	buildings2.antialiasing = true;
	buildings2.scrollFactor.set(0.9, 0.9);
	buildings2.origin.set(0, 0);
	buildings2.setGraphicSize(Std.int(buildings2.width * 1.75));
	buildings2.updateHitbox();
	buildings2.y -= 350;
	buildings2.x -= 600;
	add(buildings2);

	buildings3 = createBackdrop(Paths.image('roboStage/gears/frontBuildings'), 0, 0);
	buildings3.antialiasing = true;
	buildings3.scrollFactor.set(0.9, 0.9);
	buildings3.origin.set(0, 0);
	buildings3.setGraphicSize(Std.int(buildings3.width * 1.75));
	buildings3.updateHitbox();
	buildings3.y -= 750;
	buildings3.x -= 600;
	add(buildings3);

	tunnelBG = createBackdrop(Paths.image('roboStage/gears/tunnel'));
	tunnelBG.antialiasing = true;
	tunnelBG.y -= 950;
	tunnelBG.setGraphicSize(Std.int(tunnelBG.width * 1.15));
	tunnelBG.color = 0xFFA672B2;
	add(tunnelBG);
	tunnelBG.visible = false;

	lights = createBackdrop(Paths.image('roboStage/gears/lights'));
	lights.antialiasing = true;
	lights.y -= 700;
	lights.setGraphicSize(Std.int(lights.width * 1.6));
	add(lights);
	lights.visible = false;

	train = new FlxSprite(0, 666);
	train.frames = Paths.getSparrowAtlas('roboStage/train');
	train.animation.addByPrefix('drive', "all train", 24, false);
	train.animation.play('drive');
	train.antialiasing = true;
	train.scrollFactor.set(0.9, 0.9);
	train.setGraphicSize(Std.int(train.width * 1.75));
	train.updateHitbox();
	add(train);
	setGlobalVar("train", train);

	trainDeath = new FlxSprite(-7, 453);
	trainDeath.frames = Paths.getSparrowAtlas('roboStage/gears/death');
	trainDeath.animation.addByPrefix('death', "Train be like", 24, false);
	// trainDeath.animation.play('death');
	trainDeath.antialiasing = true;
	trainDeath.scrollFactor.set(0.9, 0.9);
	trainDeath.setGraphicSize(Std.int(trainDeath.width * 1.75));
	trainDeath.updateHitbox();
	trainDeath.visible = false;
	add(trainDeath);
	setGlobalVar("trainDeath", trainDeath);

	poles = new FlxSprite(2900, 600).loadGraphic(Paths.image("roboStage/gears/poles"));
	poles.antialiasing = true;
	poles.velocity.x = (FlxG.random.int(120, 170) / FlxG.elapsed) * -0.95;
	add(poles);

	outerBuilding = new FlxSprite(32900, 490).loadGraphic(Paths.image("roboStage/gears/randomBuilding"));
	outerBuilding.antialiasing = true;
	outerBuilding.velocity.x = (FlxG.random.int(120, 170) / FlxG.elapsed) * -0.95;
	add(outerBuilding);
	outerBuilding.visible = false;

	trainGlow = new FlxSprite(-60, 600);
	trainGlow.frames = Paths.getSparrowAtlas('roboStage/trainGlow');
	trainGlow.animation.addByPrefix('drive', "all train", 24, false);
	trainGlow.animation.play('drive');
	trainGlow.antialiasing = true;
	trainGlow.scrollFactor.set(0.9, 0.9);
	trainGlow.setGraphicSize(Std.int(trainGlow.width * 1.75));
	trainGlow.updateHitbox();
	add(trainGlow);
	trainGlow.visible = false;

	bomb = new FlxSprite(2350, 103.442);
	bomb.frames = Paths.getSparrowAtlas('roboStage/gears/regular_bomb');
	bomb.scrollFactor.set(0.9, 0.9);
	bomb.animation.addByPrefix("idle", "Mako Bomb Normal", 24);
	bomb.animation.play("idle");
	bomb.antialiasing = true;
	bomb.scale.set(1.5, 1.5);
	add(bomb);
	setGlobalVar("bomb", bomb);

	fakeTunnelBG = new FlxSprite(0, -50).loadGraphic(Paths.image("roboStage/gears/tunnel"));
	fakeTunnelBG.antialiasing = true;
	fakeTunnelBG.x = FlxG.width;
	fakeTunnelBG.color = 0xFF565656;
	add(fakeTunnelBG, 0, camHUD);

	tunnelEnterance = new FlxSprite(0, -50).loadGraphic(Paths.image("roboStage/gears/tunnelEnterance"));
	tunnelEnterance.antialiasing = true;
	tunnelEnterance.x = FlxG.width;
	add(tunnelEnterance, 1, camHUD);
}

var p_elapsedT:Float = 0;
var p_randT:Float = FlxG.random.float(2, 7);

function enterTunnel()
{
	FlxTween.tween(tunnelEnterance, {x: 0}, 0.3);
	FlxTween.tween(fakeTunnelBG, {x: 0}, 0.3, {
		onComplete: function(t)
		{
			inTunnel = true;
			tunnelEnterance.visible = false;
			fakeTunnelBG.visible = false;
			tunnelBG.visible = true;
			lights.visible = true;
			poles.visible = false;
			trainGlow.visible = true;
			camGame.flash(FlxColor.BLACK, 1.3);
		}
	});
}

function exitTunnel()
{
	tunnelEnterance.visible = true;
	trainGlow.visible = false;
	train.visible = true;

	fakeTunnelBG.visible = true;
	tunnelBG.visible = false;
	lights.visible = false;
	inTunnel = false;
	tunnelEnterance.x = FlxG.width - tunnelEnterance.width;
	fakeTunnelBG.x = (FlxG.width - tunnelEnterance.width) - fakeTunnelBG.width + 3;

	FlxTween.tween(tunnelEnterance, {x: -tunnelEnterance.width}, 0.5, {
		onUpdate: function(elapsed)
		{
			fakeTunnelBG.x = tunnelEnterance.x - fakeTunnelBG.width;
		},
		onComplete: function(t)
		{
			fakeTunnelBG.visible = false;
			tunnelEnterance.visible = false;
			poles.visible = true;
		}
	});
}

function onUpdate(elapsed:Float)
{
	var currentBeat = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
	bomb.y = -50 + (5 * Math.sin(currentBeat * Math.PI));

	if (FlxG.keys.justPressed.V && !inTunnel)
		enterTunnel();
	else if (FlxG.keys.justPressed.V)
		exitTunnel();

	if (!inTunnel)
	{
		buildings3.x -= elapsed * 1950;
		buildings2.x -= elapsed * 1020;
		buildings1.x -= elapsed * 820;

		p_elapsedT += elapsed;
		if (poles.x < sky.x - 16000 && p_elapsedT >= p_randT)
		{
			poles.x = 2900 + (FlxG.random.int(0, 1520));
			p_randT = FlxG.random.float(2, 7);
			p_elapsedT = 0;
		}
	}
	else
	{
		tunnelBG.x -= elapsed * 2330;
		lights.x -= elapsed * 2330;
	}
}

function onBeatHit(curBeat:Int)
{
	if (inTunnel)
		trainGlow.animation.play('drive');
	else
		train.animation.play('drive');

	if (curBeat == 206)
	{
		trainGlow.visible = true;
		train.visible = false;
	}
}
