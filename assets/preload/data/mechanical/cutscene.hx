var hands:FlxSprite;

function onCreate()
{
	hands = getGlobalVar("hands");
	game.defaultCamZoom = 1;
	camGame.zoom = 1;
	game.camZooming = true;
	camHUD.visible = false;
}

function onCreatePost()
{
	dad.x -= 800;
	FlxG.sound.play(Paths.sound("stoneslide"));
	FlxTween.tween(dad, {x: dad.x + 800}, 1.2, {ease: FlxEase.quadInOut});
	dad.playAnim("arrive");
	dad.animation.finishCallback = function(a)
	{
		dad.animation.finishCallback = null;
		game.startCountdown();
		camHUD.visible = true;
	}
}

function onUpdate(elapsed:Float)
{
	if (dad.animation.curAnim.name == "arrive" && !hands.visible && dad.animation.curAnim.curFrame >= 35)
	{
		hands.visible = true;
		hands.animation.play("come", true);
	}
}
