import Character;
import PlayState;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

// TEA FLIPPED = LOOKING RIGHT
var platform:FlxSprite;
var tea:FlxSprite;
var teaFlipped:Bool = false;
var ghosts = [];

//
var pasta:Character;
var isDad:Bool = false;
var camTween:FlxTween;
var rowProperties = [];

function onCreate()
{
	platform = new FlxSprite().loadGraphic(Paths.image("paste/platform"));
	platform.antialiasing = true;
	platform.visible = false;
	add(platform);

	tea = new Character(0, 0, "gf-fight");
	tea.visible = false;
	add(tea);

	pasta = new Character(dad.x - 550, dad.y - 580, "toothpaste-mad", false);
	add(pasta);
	pasta.visible = false;

	setHUDVisibility(false);
	// if the player has died before, skip the countdown and intro part of the song
	if (PlayState.deaths > 0)
	{
		FlxTimer.globalManager.clear();
		game.startSong();
		game.disableCamera = true;
		snapCamera(DAD_CAM_POS);
		FlxG.sound.music.time = 42950;
		Conductor.songPosition = 42950;
		gf.visible = false;
		boyfriend.x -= 50;

		defaultCamZoom = 0.76;
		blackScreen.visible = true;
	}
	else
	{
		for (i in [getGlobalVar("bg"), getGlobalVar("fire"), boyfriend, gf])
		{
			i.color = 0xFF000000;
			FlxTween.color(i, 10, 0xFF000000, 0xFFFFFFFF);
		}

		camGame.zoom = 1;
		camTween = FlxTween.tween(camGame, {zoom: 0.76}, 15, {
			onComplete: function(twn)
			{
				game.defaultCamZoom = 0.76;
			}
		});
	}
}

function onUpdate(elapsed:Float)
{
	var cB = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
	pasta.y = (dad.y - 580) + (11 * Math.cos((cB / 2) * Math.PI));

	for (i in ghosts)
	{
		if (i.animation.curAnim.name == "idle"
			&& i.x >= tea.x - 160
			|| i.animation.curAnim.name == "idle-flip"
			&& i.x <= tea.x + tea.width)
		{
			teaPunch(i);
		}
	}
}

function onMoveCamera(dad:Bool)
{
	isDad = dad;
}

function onBeatHit(curBeat:Int)
{
	var idleAnim = getTeaIdle();
	if (tea.animation.curAnim.name != idleAnim && tea.animation.finished || tea.animation.curAnim.name == idleAnim)
		tea.playAnim(idleAnim);

	if (curBeat >= 146 && curBeat % 3 == 0 && FlxG.random.bool(40))
		spawnGhost();
}

function onStepHit(curStep:Int)
{
	if (curStep == 556)
	{
		game.disableCamera = false;
		game.camZooming = true;
		game.curOpponent = pasta;
		dad.playAnim("transition", true);
		camGame.shake(0.045, 1.3);
		dad.animation.finishCallback = function(a)
		{
			setHUDVisibility(true);
			getGlobalVar("changeBG")();

			camGame.flash(FlxColor.WHITE, 0.85);
			gf.visible = false;
			dad.visible = false;
			pasta.visible = true;

			tea.visible = true;
			platform.visible = true;

			boyfriend.setPosition(770, 225);
			DAD_CAM_OFFSET.y -= 175;
			tea.setPosition(boyfriend.x + 690, boyfriend.y - 500);
			platform.setPosition(tea.x - 28, tea.y + tea.height - 125);

			if (camTween != null)
				camTween.cancel();

			game.defaultCamZoom = game.defaultCamZoom - 0.37;
		}
	}
}

function setHUDVisibility(theBool:Bool)
{
	for (i in strumLineNotes)
		i.visible = theBool;

	for (i in [iconP1, iconP2, healthBar, healthBarBG, scoreTxt])
		i.visible = theBool;
}

function teaTurn(flip)
{
	teaFlipped = flip;
	if (tea.animation.curAnim.name == "idle-flip" && !flip || tea.animation.curAnim.name == "idle" && flip)
	{
		var idleAnim = getTeaIdle();
		tea.playAnim("turn" + (teaFlipped ? "RIGHT" : "LEFT"));
	}
}

function teaPunch(ghost)
{
	tea.playAnim("punch" + (ghost.ID == 1 ? "-flip" : ""), true);

	ghost.velocity.x = 0;
	ghost.animation.play("hurt" + (ghost.ID == 1 ? "-flip" : ""), true);
	ghost.animation.finishCallback = function(a)
	{
		ghosts.remove(ghost);

		FlxFlicker.flicker(ghost, 0.36, 0.12, false, false, function(flicker:FlxFlicker)
		{
			ghost.kill();
		});

		if (ghosts[0] != null)
			teaTurn(ghosts[0].ID == 1);
	}
}

function getTeaIdle()
{
	return "idle" + (teaFlipped ? "-flip" : "");
}

function spawnGhost()
{
	var ghost = new FlxSprite();
	ghost.antialiasing = true;
	ghost.ID = FlxG.random.int(0, 1); // 0 = LEFT GHOST. 1 = RIGHT GHOST

	ghost.frames = Paths.getSparrowAtlas('paste/ghost');
	ghost.animation.addByPrefix("idle", "ghostoguy instance", 24, true);
	ghost.animation.addByPrefix("idle-flip", "ghostoguyRIGHT instance", 24, true);
	ghost.animation.addByPrefix("hurt", "ghostoguyHURT instance", 24, false);
	ghost.animation.addByPrefix("hurt-flip", "ghostoguyHURTright instance", 24, false);
	ghost.animation.play("idle" + (ghost.ID == 1 ? "-flip" : ""));
	ghost.setPosition(ghost.ID == 0 ? tea.x - 900 : tea.x + tea.width + 700, tea.y + 90);
	ghost.scale.y = ghost.scale.x = FlxG.random.float(0.69, 1);

	// idk why its like this but the first ghost will ALWAYS be invisible no matter when spawned
	// adding the position parameter seemed to fix it.
	add(ghost, getIndexOfMember(tea));

	if (ghosts.length <= 0)
	{
		teaTurn(ghost.ID == 1);
	}

	ghosts.push(ghost);

	ghost.velocity.x = FlxG.random.int(590, 1510) * (ghost.ID == 1 ? -1 : 1);
	ghost.alpha = 0;
	FlxTween.tween(ghost, {alpha: FlxG.random.float(0.8, 0.94)}, FlxG.random.float(0.3, 0.6));

	trace("ghost create " + ghost);
}
