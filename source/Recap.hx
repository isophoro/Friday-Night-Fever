package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

class Recap extends MusicBeatState
{
	public var dialogue:Array<String> = [];

	public static var inRecap:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Week 7 RECAP", null);
		#end

		super.create();

		inRecap = true;
		var dialogueString:String = 'recap';
		dialogue = CoolUtil.coolTextFile(Paths.txt(dialogueString));

		var doof:DialogueBox = new DialogueBox("");
		doof.finishCallback = () ->
		{
			inRecap = false;
			LoadingState.loadAndSwitchState(new PlayState());
		}

		recappslsss(doof);
	}

	function recappslsss(?dialogueBox:DialogueBox):Void
	{
		add(dialogueBox);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
