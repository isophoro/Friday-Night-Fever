import PlayState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import openfl.filters.ShaderFilter;
import shaders.BWShader;
import shaders.ScreenMultiply;

var BLACK_BAR_HEIGHT:Int = 115;
var spr:FlxSprite;
var spr2:FlxSprite;
var clap:FlxSprite;
var prevScore:String = "";
var prevHealth:Float = 1;
var prevTime:Float = 0;
var BW:BWShader;
var help:FlxText;
var clocks:FlxSprite;
var screen:ScreenMultiply;

function onCreate()
{
	gf.visible = false;
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
	getGlobalVar("whittyBG").shader = BW;

	screen = new ScreenMultiply();
	screen.value = 1;
	camGame.filtersEnabled = true;
	camHUD.filtersEnabled = true;
	var sc = new ShaderFilter(screen);
	camGame.setFilters([sc]);
	camHUD.setFilters([sc]);
}

var prevDad:Bool = true;

function onMoveCamera(isDad:Bool)
{
	if (curBeat >= 191 && curBeat < 256)
	{
		dad.visible = true;

		if (isDad)
		{
			prevDad = true;
			snapCamera(new FlxPoint(DAD_CAM_POS.x - 70, DAD_CAM_POS.y - 70));
		}
		else
		{
			if (prevDad)
				screen.value += 1;

			prevDad = false;
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
		PlayState.songPosBar = prevTime;
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
		for (i in getGlobalVar("bgElements"))
		{
			i.shader = BW;
		}

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
		prevTime = PlayState.songPosBar;

		currentTimingShown.alpha = 0;
		forceComboPos = new FlxPoint(FlxG.width * 1.5, 0);
	}
	else if (curBeat == 256)
	{
		screen.value = 1;
		snapCamera(DAD_CAM_POS);
		forceComboPos.set(0, 0);
		FlxTween.tween(spr, {y: -BLACK_BAR_HEIGHT}, 0.24);
		FlxTween.tween(spr2, {y: FlxG.height}, 0.24);
		game.defaultCamZoom -= 0.35;

		getGlobalVar("whittyBG").shader = null;

		for (i in 0...4)
			strumLineNotes[i].alpha = 1;

		for (i in getGlobalVar("bgElements"))
		{
			i.shader = null;
		}

		getGlobalVar("bgElements")[0].shader = getGlobalVar("shader");
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

function onPlayerNoteHit(note)
{
	if (curBeat >= 192 && curBeat <= 255)
		game.health = prevHealth;
}
