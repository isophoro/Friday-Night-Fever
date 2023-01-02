import Character;
import vlc.MP4Handler;

var video:MP4Handler;
var hallowDum:Character;

function onCreate()
{
	// i fucking hate hscript
	// i can do "getGlobalVar("changeBG")" in console but not here for some reason
	game.scripts.grp[0].variables["changeBG"]();
	video = new MP4Handler();

	hallowDum = new Character(0, 0, "hallow-dum");
	add(hallowDum);
	hallowDum.visible = false;
}

function onStepHit(curStep:Int)
{
	if (curStep == 1936)
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.2);
	}

	if (curStep == 1952)
	{
		game.inCutscene = true;

		trace("PLAY VIDEO");
		video.playVideo(Paths.video("soul"));
		hallowDum.visible = true;
		hallowDum.setPosition(dad.x, dad.y);
		video.finishCallback = function()
		{
			trace("VIDEO FINISH");
			game.inCutscene = false;
			video.finishCallback = null;
			video.stop();
			FlxG.camera.fade(FlxColor.BLACK, 0, true);
			game.disableCamera = true;
			game.disableModCamera = true;
			game.camZooming = false;
			boyfriend.useAlternateIdle = true;
			FlxG.camera.zoom += 0.45;
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.45}, 0.35, {
				onComplete: function(t)
				{
					game.disableCamera = false;
					game.disableModCamera = false;
					game.camZooming = true;
				}
			});
			game.curOpponent = hallowDum;
			dad.visible = false;
		}
	}
}
