package;

import flixel.FlxG;
import flixel.FlxSprite;
import shaders.ColorShader;

using StringTools;

typedef QueuedNote =
{
	strumTime:Float,
	noteData:Int,
	mustPress:Bool,
	sustainLength:Float,
	?type:Int
}

class Note extends FlxSprite
{
	public static final dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	public static final colorSuffix:Array<String> = ['PURPLE', 'BLUE', 'GREEN', 'RED'];

	public var strumTime:Float = 0;
	public var timeDiff(get, never):Float;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var animPlayed:Bool;
	public var wasGoodHit:Bool = false;

	public var prevNote:Note;
	public var nextNote:Note;

	public var modifiedByLua:Bool = false;
	public var isSustainNote:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;

	public var type:Int = 0;

	public var rating:String = "shit";
	public var properties:Dynamic = {};

	public function new()
	{
		super();

		loadNote(PlayState.SONG.noteStyle);
	}

	public function loadNote(note:String)
	{
		switch (note)
		{
			case 'pixel':
				antialiasing = false;
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
			default:
				antialiasing = true;
				switch (type)
				{
					case 1:
						frames = Paths.getSparrowAtlas('notes/hallowNotes');
					default:
						switch (PlayState.SONG.song.toLowerCase())
						{
							case 'party-crasher':
								frames = Paths.getSparrowAtlas('notes/yukichiNotes');
							case 'bazinga' | 'crucify':
								frames = Paths.getSparrowAtlas('notes/takiNotes');
							default:
								frames = Paths.getSparrowAtlas('notes/defaultNotes');
						}
				}

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				if (type == 0)
				{
					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');

					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
		}
	}

	public function create(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, noteType:Int = 0)
	{
		this.strumTime = strumTime < 0 ? 0 : strumTime;
		this.noteData = noteData;
		this.isSustainNote = sustainNote;
		this.prevNote = prevNote == null ? this : prevNote;

		// As notes are recycled, reset all usual changed properties to their defaults
		// clipRects are a must if sustain notes are involved!! this shit was broken for like two years till i realized
		alive = true;
		exists = true;
		nextNote = null;
		mustPress = false;
		wasGoodHit = false;
		canBeHit = false;
		animPlayed = false;
		type = noteType;
		alpha = 1;
		visible = true;
		clipRect = null;
		flipY = ClientPrefs.downscroll && isSustainNote;
		properties = {};

		var noteStyle:String = PlayState.SONG.noteStyle;

		if (PlayState.SONG.song == 'Loaded')
		{
			if (strumTime >= Conductor.crochet * 320 && strumTime < Conductor.crochet * 336)
				noteStyle = 'pixel';
		}
		else if (PlayState.SONG.song == 'Party-Crasher')
		{
			if (strumTime >= Conductor.crochet * 96 && strumTime < Conductor.crochet * 160)
				noteStyle = 'pixel';
		}

		loadNote(noteStyle);

		if (isSustainNote)
		{
			alpha = 0.6;

			animation.play(colorSuffix[noteData].toLowerCase() + 'holdend', true);

			updateHitbox();

			if (prevNote != null && prevNote.isSustainNote)
			{
				prevNote.animation.play(colorSuffix[noteData].toLowerCase() + 'hold', true);

				if (ClientPrefs.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * ClientPrefs.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;

				prevNote.updateHitbox();
			}
		}
		else
			animation.play(colorSuffix[noteData].toLowerCase() + 'Scroll', true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= (((125 * Conductor.timeScale) * 0.5))
					&& strumTime - Conductor.songPosition >= (((-125 * Conductor.timeScale))))
					canBeHit = true;
				else
					canBeHit = false;
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}
	}

	private function get_timeDiff():Float
	{
		return strumTime - Conductor.songPosition;
	}

	override public function kill()
	{
		super.kill();

		if (nextNote != null)
			nextNote.prevNote = null;
	}
}
