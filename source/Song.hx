package;

import haxe.Json;
import lime.utils.Assets;

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
	public static var artists:Map<Array<String>, String> = [
		[
			"hallow",
			"portrait",
			"soul",
			"hardships",
			"banish",
			"bloom",
			"dead-mans-melody",
			"grando"
		] => "FPLester",
		["c354r", "loaded", "gears", "space-demons", "princess", "tranquility"] => "Biddle3",
		["party-crasher"] => "BirdBonanza"
	];

	public static function getArtist(_song:String):String
	{
		for (s => a in artists)
		{
			if (s.contains(_song.toLowerCase()))
			{
				return a;
			}
		}

		return 'Foodieti';
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
