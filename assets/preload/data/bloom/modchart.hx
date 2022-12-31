import ("flixel.effects.FlxFlicker");
import("flixel.text.FlxText");
import("shaders.BWShader");

var BLACK_BAR_HEIGHT:Int = 115;
var spr:FlxSprite;
var spr2:FlxSprite;
var clap:FlxSprite;
var prevScore:String = "";
var prevHealth:Float = 1;
var prevTime:Float = 0;
var BW:BWShader;
var help:FlxText;

function onCreate()
{
	clap = new FlxSprite(dad.x - 270, dad.y - 50);
	clap.frames = Paths.getSparrowAtlas("characters/scarlet/Scarlet_Final_Clap");
	clap.animation.addByPrefix("clap", "Final scarlet slap", 24, false);
	clap.antialiasing = true;
	add(clap);
	clap.visible = false;

	spr = new FlxSprite(0, 0).makeGraphic(1280, BLACK_BAR_HEIGHT, FlxColor.BLACK);
	add(spr, 0, camHUD);
	spr.visible = false;

	spr2 = new FlxSprite(0, FlxG.height - BLACK_BAR_HEIGHT).makeGraphic(1280, BLACK_BAR_HEIGHT, FlxColor.BLACK);
	add(spr2, 0, camHUD);
	spr2.visible = false;

	BW = new BWShader();
	BW.colorFactor = 0;
	gf.shader = BW;
	getGlobalVar("whittyBG").shader = BW;
}

function onMoveCamera(isDad:Bool)
{
	if (curBeat >= 191 && curBeat < 256)
	{
		dad.visible = true;
		for (i in game.curComboSprites)
		{
			if (curBeat < 255)
				i.visible = !isDad;
		}

		if (isDad)
		{
			snapCamera(new FlxPoint(DAD_CAM_POS.x - 70, DAD_CAM_POS.y - 70));
		}
		else
		{
			snapCamera(new FlxPoint(BF_CAM_POS.x + 70, BF_CAM_POS.y + 165));
			dad.visible = false;
		}
	}
}

var fireOnce:Bool = false;

function onPostUpdate(elapsed:Float)
{
	if (curBeat >= 192 && curBeat <= 255)
	{
		game.songPositionBar = prevTime;
		iconP1.scale.set(1, 1);
		iconP2.scale.set(1, 1);
		scoreTxt.scale.set(1, 1);
		scoreTxt.text = prevScore;
		game.health = prevHealth;
		scoreTxt.x = (FlxG.width / 2) - (scoreTxt.width / 2);
	}
	else if (curBeat == 256 && !fireOnce)
	{
		fireOnce = true;
		game.updateScoring(false);
	}
}

function onBeatHit(curBeat:Int)
{
	if (curBeat < 192 && curBeat > 256)
	{
		if (curBeat >= 64 && curBeat < 128)
			camGame.zoom += 0.04;
		else if (curBeat % 4 == 0)
			camGame.zoom += 0.012;
	}

	if (curBeat == 191)
	{
		game.gfSpeed = 9999999999;
		FlxTween.tween(gf.animation.curAnim, {frameRate: 0}, Conductor.crochet / 1000, {
			onComplete: function(t)
			{
				gf.animation.curAnim.frameRate = 24;
				gf.animation.curAnim.pause();
			}
		});

		FlxTween.tween(BW, {colorFactor: 1}, Conductor.crochet / 1000);
	}

	if (curBeat == 192)
	{
		game.defaultCamZoom -= 0.2;
		game.disableCamera = false;
		clap.visible = false;
		dad.visible = true;

		spr.visible = true;
		spr2.visible = true;
		game.defaultCamZoom += 0.35;
		camGame.zoom = FlxG.state.defaultCamZoom;

		onMoveCamera(true);

		for (i in 0...4)
			strumLineNotes[i].alpha = 0.43;

		prevScore = scoreTxt.text;
		prevHealth = game.health;
		prevTime = game.songPositionBar;

		currentTimingShown.alpha = 0;
		forceComboPos = new FlxPoint(FlxG.width * 1.5, 0);
		for (i in game.curComboSprites)
		{
			FlxTween.cancelTweensOf(i);
			i.velocity.set(0, 0);
			i.acceleration.set(0, 0);
			i.ID = -420;
			i.visible = false;
		}
	}
	else if (curBeat == 256)
	{
		snapCamera(DAD_CAM_POS);
		forceComboPos.set(0, 0);
		FlxTween.tween(spr, {y: -BLACK_BAR_HEIGHT}, 0.24);
		FlxTween.tween(spr2, {y: FlxG.height}, 0.24);
		game.defaultCamZoom -= 0.35;
		game.gfSpeed = 1;

		gf.shader = null;
		getGlobalVar("whittyBG").shader = null;

		for (i in game.curComboSprites)
		{
			if (i.ID == -420)
			{
				FlxTween.tween(i, {alpha: 0, y: i.y + FlxG.random.int(15, 36)}, 0.3 + FlxG.random.float(0.1, 0.25), {
					onComplete: function(tween)
					{
						i.kill();
						i.exists = false;
					}
				});
			}
		}

		curComboSprites = [];

		for (i in 0...4)
			strumLineNotes[i].alpha = 1;
	}
}

function onStepHit(curStep:Int)
{
	if (curStep == 762)
	{
		clap.visible = true;
		dad.visible = false;
		game.disableCamera = true;
		camFollow.x -= 250;
		game.defaultCamZoom += 0.2;

		clap.animation.play("clap");
	}
}
