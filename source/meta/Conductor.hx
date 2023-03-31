package meta;

import meta.Song.SwagSong;
import meta.interfaces.IBeatReceiver;
import meta.interfaces.IStepReceiver;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float = 0;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	private static var beatInstances:Array<IBeatReceiver> = [];
	private static var stepInstances:Array<IStepReceiver> = [];

	public static function callBeatReceivers(curBeat:Int)
	{
		for (i in beatInstances)
			i.beatHit(curBeat);
	}

	public static function callStepReceivers(curStep:Int)
	{
		for (i in stepInstances)
			i.stepHit(curStep);
	}

	public static function pushPossibleReceivers(obj:Dynamic)
	{
		if (obj is IBeatReceiver)
			beatInstances.push(obj);

		if (obj is IStepReceiver)
			stepInstances.push(obj);
	}

	public static function clearReceivers()
	{
		beatInstances = [];
		stepInstances = [];
	}
}
