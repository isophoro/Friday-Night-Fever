var purpleOverlay:FlxSprite;

function onCreate()
{
	forceComboPos = new FlxPoint(80, 500);

	purpleOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.PURPLE);
	purpleOverlay.alpha = 0.0;
	purpleOverlay.scale.set(1.5, 1.5);
	purpleOverlay.scrollFactor.set();
}

function onCreatePost()
{
	add(purpleOverlay);
	FlxTween.tween(purpleOverlay, {alpha: 0.33}, 2.6);
}

function onOpponentNoteHit(note)
{
	if (note.type == 2)
	{
		gf.holdTimer = 0;
		gf.playAnim('sing' + dataSuffix[note.noteData] + '-alt', true);
		note.properties.singAnim = ""; // cancel dad singing
	}
}

function onStepHit(curStep:Int)
{
	if (curStep == 1390)
	{
		gf.playAnim("pull");
		remove(gf);
		getGlobalVar("phands").visible = false;
		add(gf, game.members.length);
		gf.useAlternateIdle = true;
	}

	if (curStep == 1380)
		FlxTween.tween(purpleOverlay, {alpha: 0}, 1);
}
