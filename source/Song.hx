package;

import haxe.Json;
import lime.utils.Assets;
import meta.FeverConfig;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	@:deprecated var ?validScore:Bool;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
	var ?sectionBeats:Int;
}

class Song
{
	public static function getArtist(_song:String):String
	{
		for (s => a in FeverConfig.songArtists)
		{
			if (s.contains(_song.toLowerCase()))
			{
				return a;
			}
		}

		return 'Foodieti';
	}

	public static var costumesEnabled(get, never):Bool;

	public static function get_costumesEnabled():Bool
	{
		return !FeverConfig.costumeDisabledSongs.contains(PlayState.SONG.song.toLowerCase());
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		return swagShit;
	}
}
