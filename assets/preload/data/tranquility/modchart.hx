import flixel.util.FlxTimer;
import options.ClientPrefs;
import shaders.WiggleEffect;

var wiggleEffect:WiggleEffect;
var purpleOverlay:FlxSprite;
var blackScreen:FlxSprite;
var whittyBG:FlxSprite;

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

	new FlxTimer().start(1.35, function(t)
	{
		FlxTween.tween(purpleOverlay, {alpha: FlxG.random.float(0.235, 0.425)}, 1.15);
	}, 0);

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
				onComplete: function(twn)
				{
					FlxTween.tween(wiggleEffect, {waveAmplitude: 0}, 0.6);
					FlxTween.cancelTweensOf(purpleOverlay);
					FlxTween.tween(purpleOverlay, {alpha: 0}, 0.1);
					FlxTimer.globalManager._timers[0].cancel();

					game.disableHUD = true;

					for (i in strumLineNotes)
						FlxTween.tween(i, {alpha: 0.6}, 0.6);
					for (i in [iconP1, iconP2, healthBar, healthBarBG])
						FlxTween.tween(i, {alpha: 0}, 0.46, {
							onComplete: function(twn)
							{
								if (i == healthBarBG)
								{
									FlxTween.tween(scoreTxt, {y: ClientPrefs.downscroll ? scoreTxt.y - 80 : scoreTxt.y + 80}, 0.38);
									game.disableScoreBop = true;
									FlxTween.tween(scoreTxt.scale, {x: 0.8, y: 0.8}, 0.38, {
										onComplete: function(twn)
										{
											game.disableScoreBop = false;
										}
									});
								}
							}
						});
				}
			});
		case 146:
			for (i in [dad, boyfriend, gf])
			{
				i.color = FlxColor.WHITE;
				FlxTween.color(i, 3, FlxColor.WHITE, FlxColor.fromString("#C956FF"));
			}
			FlxTween.tween(whittyBG, {alpha: 0.65}, 3);
		case 176 | 180 | 194:
			FlxTween.tween(whittyBG, {alpha: 0.9}, (Conductor.crochet / 1000) * 2);
		case 178 /* | 192 */:
			FlxTween.tween(whittyBG, {alpha: 0.65}, (Conductor.crochet / 1000) * 2);
		case 208:
			for (i in [dad, boyfriend, gf])
			{
				FlxTween.color(i, (Conductor.crochet / 1000) * 2, FlxColor.fromString("#C956FF"), FlxColor.WHITE);
			}
			FlxTween.tween(whittyBG, {alpha: 1}, (Conductor.crochet / 1000) * 2);
		case 304:
			FlxTimer.globalManager._timers[0].cancel();
			FlxTween.tween(purpleOverlay, {alpha: 0}, 2.6);
			FlxTween.tween(wiggleEffect, {waveAmplitude: 0}, 2.6);
	}
}
