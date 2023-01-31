import PlayState;

function onCreatePost()
{
	if (PlayState.isStoryMode)
	{
		camHUD.fade(FlxColor.BLACK, 0);
		var video = new MP4Handler();
		video.playVideo(Paths.video("bloom"));
		video.finishCallback = function()
		{
			trace("VIDEO FINISH!");
			video.stop();

			camHUD.fade(FlxColor.BLACK, 0.7, true);
			game.startCountdown();
		}
	}
	else
		game.startCountdown();
}
