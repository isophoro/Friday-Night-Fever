package states;

/**
 * UNFINISHED
 */
import flixel.FlxSprite;

class WeekPreviewSubState extends MusicBeatSubstate
{
	public var week:Int = 0;

	public function new(week:Int)
	{
		super();
		this.week = week;
	}

	override function create()
	{
		super.create();

		var character:String = switch (week)
		{
			default: "tea";
			case 1: "peakek";
			case 2: "wee";
			case 3: "taki";
			case 4: "mako";
			case 5: "hunni";
			case 6: "pepper";
			case 7: "mega";
			case 8: "hallow";
			case 9: "robo";
			case 10: "scarlet";
			case 11: "rolldog";
		}
		// 0, -28
		// 578, -29

		var side:FlxSprite = new FlxSprite(0, -28).loadGraphic(Paths.image("story/selectBG"));
	}
}
