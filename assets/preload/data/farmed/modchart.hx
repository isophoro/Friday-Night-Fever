import PlayState;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import haxe.Timer;
import meta.Ratings;
import sprites.ui.SongPosBar;

var score:Int = 0;

function onCreate()
{
	iconP1.swapCharacter("bf-classic");
	iconP2.swapCharacter("mako");

	var kadeEngineWatermark = new FlxText(4, healthBarBG.y + 50, 0, "Farmed " + (PlayState.storyDifficulty == 2 ? "HARD" : "NORMAL") + " - KE 1.5.1", 16);
	kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, "right");
	kadeEngineWatermark.scrollFactor.set();
	kadeEngineWatermark.borderStyle = scoreTxt.borderStyle;
	add(kadeEngineWatermark, -1, camHUD);

	if (ClientPrefs.downscroll)
		kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

	currentTimingShown.font = "Nokia Cellphone FC Small";

	scoreTxt.size = 16;
	scoreTxt.defaultSize = 16;
	scoreTxt.disableBop = true;
	scoreTxt.y = healthBarBG.y + 50;

	for (i in strumLineNotes)
	{
		i.x -= 50;
	}
}

function onSongStart()
{
	if (game.songPosBar != null)
	{
		game.songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		game.songPosBar.name.text = "Farmed";
		game.songPosBar.name.antialiasing = false;
		game.songPosBar.time.alpha = 0;
	}
}

function onPostUpdate(elapsed)
{
	scoreTxt.text = "Score:"
		+ score
		+ " | Combo Breaks:"
		+ PlayState.misses
		+ " | Accuracy:"
		+ (Math.isNaN(accuracy) ? 0 : FlxMath.roundDecimal(game.accuracy, 2))
		+ " % | ("
		+ Ratings.getComboRating()
		+ ") "
		+ Ratings.getWife3Rating(game.accuracy);
	scoreTxt.x += 40;
	scoreTxt.antialiasing = false;

	camGame.followLerp = 0.04 * (30 / FlxG.drawFramerate);

	if (game.songPosBar != null)
	{
		game.songPosBar.name.size = 16;
		game.songPosBar.name.scale.set(1, 1);
		game.songPosBar.name.screenCenter(0x01);
		game.songPosBar.name.y = game.songPosBar.y - 7;
		game.songPosBar.name.antialiasing = false;
	}

	for (i in [iconP1, iconP2])
	{
		FlxTween.cancelTweensOf(i.scale);
		i.centerOrigin();
		i.updateHitbox();
		i.setGraphicSize(Std.int(FlxMath.lerp(150, i.width, 0.50)));
	}
}

function onBeatHit(curBeat)
{
	// fake lag spikes :)
	/*
		if (curBeat % 4 == 0 && FlxG.random.bool(15))
		{
			game.active = false;
			Timer.delay(function()
			{
				game.active = true;
			}, 45);
		}
	 */
}

function onPlayerNoteHit(note)
{
	if (note.isSustainNote)
		return;

	score += 350; // this is me being lazy but also kade engine 1.5.1 had a bug where this happened too lmao
	game.health += 0.1; // this is also something that happened in kade engine im not joking
}
