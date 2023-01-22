function onCreate()
{
	forceComboPos = new FlxPoint(80, 500);
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
	if (curStep == 1400)
	{
		gf.playAnim("pull");
		remove(gf);
		getGlobalVar("phands").visible = false;
		add(gf, game.members.length);
		gf.useAlternateIdle = true;
	}
}
