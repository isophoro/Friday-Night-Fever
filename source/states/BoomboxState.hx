package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
#if windows
import Discord.DiscordClient;
#end

typedef JukeboxSong =
{
	var display:String;
	var ?song:String;
	var cover:String;
	var bpm:Float;
	var ?special:Bool;
}

@:enum abstract Playback(Int) to Int from Int
{
	var DUAL = 0;
	var INST = 1;
	var VOCALS = 2;

	public static function getString(pb:Playback):String
	{
		switch (pb)
		{
			case DUAL:
				return 'Normal';
			case INST:
				return 'Inst';
			case VOCALS:
				return 'Vocals';
		}
	}
}

class BoomboxState extends MusicBeatState
{
	override function create()
	{
	}
}
