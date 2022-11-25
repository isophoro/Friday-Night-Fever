package;

import flixel.FlxG;
import flixel.FlxSprite;
import shaders.ColorShader;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var animPlayed:Bool;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;

	public var type:Int = 0;

	public var rating:String = "shit";

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, noteType:Int = 0)
	{
		super();
		type = noteType;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.strumTime = strumTime;

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;
		var noteStyle:String = PlayState.SONG.noteStyle;

		if (PlayState.SONG.song == 'Loaded')
		{
			if (strumTime >= Conductor.crochet * 320 && strumTime < Conductor.crochet * 336)
				noteStyle = 'pixel';
		}

		switch (noteStyle)
		{
			case 'pixel':
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
				if (noteType == 0)
				{
					switch (PlayState.SONG.song.toLowerCase())
					{
						case 'throw-it-back':
							frames = Paths.getSparrowAtlas('customArrows/throwIBNotes');
						case 'party-crasher':
							frames = Paths.getSparrowAtlas('customArrows/partyCrasherNotes');
						case 'bazinga' | 'crucify':
							frames = Paths.getSparrowAtlas('customArrows/TakiNotes');
						default:
							frames = Paths.getSparrowAtlas('NOTE_assets');
					}
				}
				else
				{
					switch (noteType)
					{
						case 1: // hallow
							frames = Paths.getSparrowAtlas('NOTE_HALLOW');
							if (FlxG.save.data.brighterNotes)
							{
								var cshader = new ColorShader();
								cshader.saturation = 0.65;
								cshader.hue = 0.45;
								cshader.onUpdate();
								shader = cshader;
							}
						default:
							frames = Paths.getSparrowAtlas('NOTE_assets');
					}
				}

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		switch (noteData)
		{
			case 0:
				animation.play('purpleScroll');
			case 1:
				animation.play('blueScroll');
			case 2:
				animation.play('greenScroll');
			case 3:
				animation.play('redScroll');
		}

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote)
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				if (FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) * 0.5))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale)))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale))))
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
