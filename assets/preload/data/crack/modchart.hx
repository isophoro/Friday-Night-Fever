import Character;
import ShadersHandler;

var scarlet:Character;

function onCreate()
{
	iconP2.swapCharacter("scarlet");
	scarlet = new Character(dad.x + 375, dad.y + 475, "scarlet");
	scarlet.scrollFactor.set(0.95, 0.95);
	add(scarlet);
	dad.visible = false;
	game.curOpponent = scarlet;

	DAD_CAM_OFFSET.y = 100;
	game.moveCamera(true);
}

function onBeatHit(curBeat:Int)
{
	if (curBeat < 202 && curBeat % 4 == 0)
	{
		game.camZooming = true;
		camHUD.zoom += 0.025;
	}

	if (curBeat == 202)
	{
		camGame.setFilters([ShadersHandler.chromaticAberration]);
		ShadersHandler.chromaticAberration.shader.redOffset = 0;
		ShadersHandler.chromaticAberration.shader.blueOffset = 0;

		game.curOpponent = dad;
		scarlet.playAnim("transform");
		game.disableCamera = true;
		DAD_CAM_OFFSET.x = -160;
		game.moveCamera(true);
		FlxTween.tween(camGame, {zoom: 0.9}, (Conductor.crochet / 1000) * 5);
	}

	if (curBeat == 205)
	{
		camGame.filtersEnabled = true;
		camGame.shake(0.009, (Conductor.crochet / 1000) * 2.5);
		FlxTween.tween(ShadersHandler.chromaticAberration.shader, {redOffset: 0.0095}, (Conductor.crochet / 1000) * 2.5);
		FlxTween.tween(ShadersHandler.chromaticAberration.shader, {blueOffset: -0.0095}, (Conductor.crochet / 1000) * 2.5);
	}

	if (curBeat == 207)
	{
		ShadersHandler.chromaticAberration.shader.redOffset = 0;
		ShadersHandler.chromaticAberration.shader.blueOffset = 0;
		camGame.filtersEnabled = false;
		game.disableCamera = false;

		iconP2.swapCharacter("scarlet-final");
		dad.visible = true;
		scarlet.visible = false;
		DAD_CAM_OFFSET.set(0, 0);
		game.moveCamera(true);
	}

	if (curBeat == 288)
	{
		game.useDirectionalCamera = true;
	}
}

function onStepHit(curStep:Int)
{
	if (curStep == 828)
	{
		camGame.flash(FlxColor.WHITE, 1.4);
	}
}

function onUpdate(elapsed:Float)
{
	var cB = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);
	scarlet.y = (dad.y + 475) + (11 * Math.cos((cB / 5) * Math.PI));
}
