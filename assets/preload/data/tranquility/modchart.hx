import flixel.FlxSprite;
import flixel.util.FlxTimer;
import shaders.WiggleEffect;

var wiggleEffect:WiggleEffect;
var purpleOverlay:FlxSprite;
var blackScreen:FlxSprite;
var whittyBG:FlxSprite;
var t1:FlxSprite;
var t2:FlxSprite;
var t3:FlxSprite;
var t4:FlxSprite;

function onCreate()
{
	whittyBG = getGlobalVar("whittyBG");

	purpleOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.PURPLE);
	purpleOverlay.alpha = 0.33;
	add(purpleOverlay);
	purpleOverlay.cameras = [camHUD];
	purpleOverlay.scale.set(1.5, 1.5);
	purpleOverlay.scrollFactor.set();

	blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	blackScreen.alpha = 0;
	blackScreen.scrollFactor.set();
	blackScreen.scale.set(5, 5);
	add(blackScreen);

	t1 = new FlxSprite().loadGraphic(Paths.image("tranquility/1"));
	t1.scrollFactor.set(0, 0);
	t1.scale.set(1 * (1 / game.defaultCamZoom), 1 * (1 / game.defaultCamZoom));
	t1.antialiasing = true;
	add(t1);
	t1.alpha = 0.000000009;

	t2 = new FlxSprite().loadGraphic(Paths.image("tranquility/2"));
	t2.scrollFactor.set(0, 0);
	t2.scale.set(1 * (1 / game.defaultCamZoom), 1 * (1 / game.defaultCamZoom));
	t2.antialiasing = true;
	add(t2);
	t2.alpha = 0.000000009;

	t3 = new FlxSprite().loadGraphic(Paths.image("tranquility/3"));
	t3.scrollFactor.set(0, 0);
	t3.scale.set(1 * (1 / game.defaultCamZoom), 1 * (1 / game.defaultCamZoom));
	t3.antialiasing = true;
	add(t3);
	t3.alpha = 0.000000009;

	t4 = new FlxSprite().loadGraphic(Paths.image("tranquility/4"));
	t4.scrollFactor.set(0, 0);
	t4.scale.set(1 * (1 / game.defaultCamZoom), 1 * (1 / game.defaultCamZoom));
	t4.antialiasing = true;
	add(t4);
	t4.alpha = 0.000000009;

	if (ClientPrefs.shaders)
	{
		wiggleEffect = new WiggleEffect();
		wiggleEffect.waveAmplitude = 0.0055;
		wiggleEffect.waveFrequency = 7;
		wiggleEffect.waveSpeed = 1.15;

		for (i in [iconP1, iconP2, whittyBG, currentTimingShown, scoreTxt])
			i.shader = wiggleEffect.shader;
	}
}

function onUpdate(elapsed:Float)
{
	if (ClientPrefs.shaders)
		wiggleEffect.update(elapsed);
}

function onBeatHit(curBeat)
{
	switch (curBeat)
	{
		case 48:
			game.disableCamera = true;
			FlxTween.tween(camFollow, {y: camFollow.y - 550}, 0.64);
			FlxTween.tween(blackScreen, {alpha: 1}, 0.58, {
				onComplete: function(t)
				{
					FlxTween.tween(purpleOverlay, {alpha: 0}, 0.1);
					for (i in [iconP1, iconP2, healthBar, healthBarBG])
						FlxTween.tween(i, {alpha: 0}, 0.46);

					var yAdd:Int = ClientPrefs.downscroll ? -200 : 200;
					FlxTween.tween(scoreTxt, {y: scoreTxt.y + (ClientPrefs.downscroll ? yAdd / 3.3 : 0), alpha: 0.7}, 0.4, {
						startDelay: 0.46,
						onComplete: function(t)
						{
							game.disableScoreBop = true;
						}
					});

					FlxTween.tween(wiggleEffect, {waveAmplitude: 0}, 0.6, {startDelay: 0.46});

					for (i in 0...strumLineNotes.length)
						FlxTween.tween(strumLineNotes[i], {alpha: i > 3 ? 0.6 : 0}, 0.6);
				}
			});
		case 50:
			forceComboPos = new FlxPoint(strumLineNotes[4].x - 200, strumLineNotes[4].y);
			FlxTween.tween(t1, {alpha: 1}, 0.7);
		case 59:
			FlxTween.tween(t1, {alpha: 0}, 0.7);
		case 62:
			FlxTween.tween(t2, {alpha: 1}, 0.7);
		case 71:
			FlxTween.tween(t2, {alpha: 0}, 0.7);
		case 75:
			FlxTween.tween(t3, {alpha: 1}, 0.7);
		case 83:
			FlxTween.tween(t3, {alpha: 0}, 0.7);
		case 87:
			FlxTween.tween(t4, {alpha: 1}, 0.7);
		case 94:
			FlxTween.tween(t4, {alpha: 0}, 0.7);
		case 96:
			FlxTween.tween(t4, {alpha: 0}, 0.7);
			FlxTween.tween(blackScreen, {alpha: 0}, 1.5);
			FlxTween.tween(purpleOverlay, {alpha: 0.33}, 0.7);
			FlxTween.tween(wiggleEffect, {waveAmplitude: 0.0055}, 0.6, {startDelay: 0.46});
			game.disableCamera = false;
			game.moveCamera(true);
		case 97:
			var yAdd:Int = ClientPrefs.downscroll ? -200 : 200;
			FlxTween.tween(scoreTxt, {y: scoreTxt.y - (ClientPrefs.downscroll ? yAdd / 3.3 : 0), alpha: 1}, 0.4, {
				startDelay: 0.46,
				onComplete: function(t)
				{
					game.disableScoreBop = false;
					for (i in [iconP1, iconP2, healthBar, healthBarBG])
						FlxTween.tween(i, {alpha: 1}, 0.46);

					for (i in strumLineNotes)
						FlxTween.tween(i, {alpha: 1}, 0.6);
				}
			});
	}
}
