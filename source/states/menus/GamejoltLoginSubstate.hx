package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.api.FlxGameJolt;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GamejoltLoginSubstate extends MusicBeatSubstate
{
	public function new(username:String, token:String)
	{
		super();
		var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		add(bg);
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.65}, 0.24, {
			onComplete: function(twn:FlxTween)
			{
				var loadingText:FlxText = new FlxText(0, 0, 0, "Logging in...", 30);
				add(loadingText);
				loadingText.screenCenter();
				ClientPrefs.username = username;
				ClientPrefs.userToken = token;
				AchievementHandler.loginToGamejolt(function()
				{
					trace("Logging in as " + username);
					if (FlxGameJolt.username.toLowerCase() != 'no user')
					{
						loadingText.text = "Logged in as " + FlxGameJolt.username + "!";
						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							FlxG.switchState(new MainMenuState());
						});
					}
					else
					{
						loadingText.text = "Failed logging in";

						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							close();
						});
					}
					loadingText.screenCenter();
				});
			}
		});
	}
}
