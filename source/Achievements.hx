package;

import flixel.tweens.FlxEase;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.tweens.FlxTween;
import openfl.Lib;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKey;
import GameJolt.GameJoltAPI;

using StringTools;


class Achievements
{

    public static var achievements:Array<Dynamic> =
    [
        //bronze
        ["Pwned", "Die 5 Times on a Single Song", "achievements/pwned", false, 160615],
        ["Marketable NFT", "Die 5 Times on Hallow", "achievements/markNFT", false, 160616],
        ["Miracle", "Die on Milk Tea with Baby Mode", "achievements/miracle", false, 160617],
        ["Cheater", "Turn on BotPlay", "achievements/cheater", false, 160618],
        //silver
        ["Getting There!", "FC Tutorial", "achievements/fc", false, 160619],
        ["Expenisve NFT", "Die to Hallow Notes 10 Times", "achievements/expensive nft", false, 160621],
        //gold
        ["Nerd Emoji", "Get 'isophoro' Costume", "achievements/nerd", true, 160620],
        ["The End", "Beat Every Week", "achievements/theend", false, 160622],
        //platinum
        ["Shelton883", "Be Shelton883", "achievements/shelton", true, 160623],
        ["FC Week 1", "FC Week 1", "achievements/fc", false, 160624],
        ["Nightmares Turned to Dreams", "FC Week 2", "achievements/fc", false, 160625],
        ["New Friends", "FC Week 2.5", "achievements/fc", false, 160626],
        ["No More NFTS", "FC Week ???", "achievements/fc", false, 160627],
        ["The Eater", "FC Week 3", "achievements/fc", false, 160628],
        ["FC Week 4", "FC Week 4", "achievements/fc", false, 160629],
        ["Tax Evader", "FC Week 5", "achievements/fc", false, 160630],
        ["FC Week 6", "FC Week 6", "achievements/fc", false, 160631]
    ];  //0           1            2                  3      4


    public static function getAchievement(achieveID:Int, alreadyHave:Null<Bool> = false):Void 
    {
        if (!FlxG.save.data.achievements[achieveID])
        {
            FlxG.save.data.achievements[achieveID] = true;
            
            if(!alreadyHave) 
                GameJoltAPI.getTrophy(achievements[achieveID][4]);

            FlxG.save.flush();
        }
    }

    public static function checkAchievementsLogged():Void 
    {
		for (i in 0...achievements.length)
		{
			if (FlxG.save.data.achievements[i])
			{
				GameJoltAPI.getTrophy(achievements[i][4]);
			}
		}
    }

	public static function defaultYAYY()
	{
		if (FlxG.save.data.achievements == null)
		{
			FlxG.save.data.achievements = [
				false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
			];
		}
	}

}

