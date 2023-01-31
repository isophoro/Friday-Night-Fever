import Character;
import PlayState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;
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
var pasteSlam:FlxSprite;
var feverParry:FlxSprite;
var inMechanic:Bool = false;
var parried:Bool = false;

function onCreate()
{
	forceComboPos = new FlxPoint(5, 5);
	PlayState.instance.gotSmushed = false;

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

	feverParry = new FlxSprite(570, -10);
	feverParry.antialiasing = true;
	feverParry.frames = Paths.getSparrowAtlas('characters/fever/Fever_paste_anims');
	feverParry.animation.addByPrefix("parry", "fever parry", 24, false);
	feverParry.animation.play("parry");
	add(feverParry);
	feverParry.alpha = 0.0000000000000000000009;

	pasteSlam = new FlxSprite(pasta.x - 200, pasta.y - 165);
	pasteSlam.antialiasing = true;
	pasteSlam.frames = Paths.getSparrowAtlas('characters/paste/paste_anims');
	pasteSlam.animation.addByPrefix("smash", "toothpaste smash", 24, false);
	pasteSlam.animation.addByPrefix("parry", "toothpaste parry", 24, false);
	pasteSlam.animation.play("smash");
	add(pasteSlam);
	pasteSlam.alpha = 0.0000000000000000000009;

	setHUDVisibility(false);
	// if the player has died before, skip the countdown and intro part of the song
	if (PlayState.deaths > 0)
	{
		FlxTimer.globalManager.clear();
		game.startSong();
		// game.disableCamera = true;

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
		}

		if (!PlayState.isStoryMode)
			onDialogueFinish();
	}
}

function onDialogueFinish()
{
	game.startCountdown();
	for (i in [getGlobalVar("bg"), getGlobalVar("fire"), boyfriend, gf])
	{
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

function onUpdate(elapsed:Float)
{
	var cB = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
	pasta.y = (dad.y - 580) + (11 * Math.cos((cB / 2) * Math.PI));

	for (i in ghosts)
	{
		if (i.animation.curAnim.name == "idle"
			&& i.x >= tea.x - 160 - i.health
			|| i.animation.curAnim.name == "idle-flip"
			&& i.x <= tea.x + tea.width + i.health)
		{
			teaPunch(i);
		}
	}

	if (inMechanic == true)
	{
		// trace("SPACE BITCH");
		// trace(PlayState.instance.canHey);

		trace(pasteSlam.animation.curAnim.curFrame);

		if (ClientPrefs.botplay)
		{
			parried = FlxG.random.bool(10);
			PlayState.instance.spacePressed = true;
		}

		if (PlayState.instance.spacePressed == true && !ClientPrefs.botplay)
		{
			PlayState.canPressSpace = false;
			if (pasteSlam.animation.curAnim.curFrame <= 11)
			{
				trace("dodge");
				boyfriend.playAnim('dodge', true);

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					boyfriend.playAnim('idle', true);
				});

				inMechanic = false;
				PlayState.instance.health += 0.05;
				pasteSlam.animation.finishCallback = function(anim)
				{
					PlayState.instance.spacePressed = false;
					pasta.alpha = 1;
					pasteSlam.alpha = 0.0000000000000000000009;
					PlayState.instance.canHey = true;
				};
			}
			else if (pasteSlam.animation.curAnim.curFrame >= 12 && pasteSlam.animation.curAnim.curFrame <= 15)
			{
				trace("parry");
				parried = true;
				boyfriend.playAnim('idle');
			}
		}

		if (pasteSlam.animation.curAnim.curFrame >= 15 && PlayState.instance.spacePressed == false)
		{
			trace("dead");
			inMechanic = false;
			PlayState.canPressSpace = false;
			PlayState.instance.gotSmushed = true;
			PlayState.instance.canHey = true;
			PlayState.instance.health = -1;
			return; // possible fix?? idk i've never crashed.
		}
	}

	// so it does it at the right time, its like 3 am so this code probably sucks okay LOL
	if (pasteSlam.animation.curAnim.curFrame >= 14 && parried == true)
	{
		PlayState.instance.spacePressed = false;
		game.parried = true;
		PlayState.instance.spaceDelay = 0;

		if (boyfriend.curCharacter == 'bf-demon')
		{
			boyfriend.alpha = 0.0000000000000000000009;
			feverParry.alpha = 1;
			feverParry.animation.play('parry', true);
		}
		else
			boyfriend.playAnim('hey', true);

		pasteSlam.animation.play('parry', true);
		FlxG.sound.play(Paths.sound('parry', 'preload'), 1);
		PlayState.instance.health += 0.1;
		inMechanic = false;
		parried = false;
		pasteSlam.animation.finishCallback = function(anim)
		{
			boyfriend.alpha = 1;
			pasta.alpha = 1;
			PlayState.instance.canHey = true;

			feverParry.alpha = 0.0000000000000000000009;
			pasteSlam.alpha = 0.0000000000000000000009;
		};
	}

	if (pasteSlam.animation.curAnim.name == 'parry')
	{
		pasteSlam.offset.set(-511, -200);
	}
	else
	{
		pasteSlam.offset.set(-50, -25);
	}
}

function onMoveCamera(dad:Bool)
{
	isDad = dad;
}

function onBeatHit(curBeat:Int)
{
	if (curBeat == 363 || curBeat == 716)
	{
		game.healthTween(0.1, false, 1);
		camGame.shake(0.005, 1);
		camHUD.shake(0.007, 1);
		pasta.playAnim('scream', true);
	}

	if (pasta.animation.curAnim.name != "scream")
	{
		if (curBeat >= 146 && curBeat % 5 == 0 && FlxG.random.bool(10))
		{
			trace("WORK");
			smashMechanic();
		}
		else if (game.curStep >= 1472 && curBeat % 5 == 0 && FlxG.random.bool(25))
		{
			trace("WORK");
			smashMechanic();
		}
	}

	var idleAnim = getTeaIdle();
	if (tea.animation.curAnim.name != idleAnim && tea.animation.finished || tea.animation.curAnim.name == idleAnim)
		tea.playAnim(idleAnim);

	if (curBeat >= 146 && curBeat % 5 == 0 && FlxG.random.bool(60))
		spawnGhost();
	else if (game.curStep >= 1472 && curBeat % 3 == 0 && FlxG.random.bool(72))
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
	ghost.health = FlxG.random.int(-30, 30);
	ghost.color = FlxG.random.int();

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

function smashMechanic()
{
	var swagCounter:Int = 0;
	new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
	{
		var warning = new FlxSprite(768, 164.5);
		warning.loadGraphic(Paths.image('mechanicShit/warning', 'shared'));
		warning.cameras = [camHUD];
		add(warning);

		FlxG.sound.play(Paths.sound('alert', 'shared'), 1);
		FlxTween.tween(warning, {alpha: 0}, Conductor.crochet / 1000, {
			onComplete: (twn) ->
			{
				remove(warning);
				warning.destroy();
			}
		});

		swagCounter++;
		trace(swagCounter);

		if (swagCounter == 2)
		{
			PlayState.instance.canHey = false;
			FlxG.sound.play(Paths.sound('smash', 'preload'), 1);

			pasta.alpha = 0.0000000000000000000009;
			pasteSlam.alpha = 1;
			pasteSlam.animation.play('smash', true);

			PlayState.instance.spacePressed = false;
			PlayState.canPressSpace = true;
			inMechanic = true;
		}
	}, 3);
}
