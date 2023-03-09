package sprites.ui;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

class SongPosBar extends FlxBar
{
	private static final WIDTH:Int = 450;
	private static final HEIGHT:Int = 10;
	private static final BORDER:Int = 4;

	public var border:FlxSprite;
	public var name:FlxText;
	public var time:FlxText;

	public function new()
	{
		border = new FlxSprite().makeGraphic(WIDTH + (BORDER * 2), HEIGHT + (BORDER * 2), FlxColor.BLACK);
		border.active = false;
		border.antialiasing = true;

		name = new FlxText(0, 0, 0,
			CoolUtil.capitalizeFirstLetters(StringTools.replace(PlayState.SONG.song, '-', ' ')) + ' - ${Song.getArtist(PlayState.instance.curSong)}', 16);
		name.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		name.borderSize = 1.25;
		name.antialiasing = true;
		name.moves = false;
		name.active = false;

		time = new FlxText(0, 0, 0, "0:00", 16);
		time.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		time.borderSize = 1.7;
		time.antialiasing = true;
		time.moves = false;
		time.active = false;
		time.updateHitbox();

		super(0, (ClientPrefs.downscroll ? FlxG.height * 0.9 + 45 : 10), LEFT_TO_RIGHT, WIDTH, HEIGHT, null, null, 0, FlxG.sound.music.length);
		antialiasing = true;
		numDivisions = 750;

		createFilledBar(0xFF662C77, 0xFFC353E3);
		screenCenter(X);
	}

	var curSegment:Int = 1;
	var timeUpdate:Float = 0;

	override function update(elapsed:Float)
	{
		if (Conductor.songPosition / numDivisions >= curSegment)
		{
			value = Conductor.songPosition;
			curSegment++;
		}

		// Prevents text from being updated every frame
		if (FlxG.sound.music != null && FlxG.sound.music.time > timeUpdate)
		{
			time.text = FlxStringUtil.formatTime((FlxG.sound.music.length - FlxG.sound.music.time) / 1000);
			timeUpdate = FlxG.sound.music.time + 1000;
		}
	}

	override function set_x(newX:Float):Float
	{
		border.x = newX - BORDER;
		name.x = newX + (WIDTH / 2) - (name.width / 2);
		time.x = newX + (WIDTH / 2) - (time.width / 2);

		super.set_x(newX);
		return newX;
	}

	override function set_y(newY:Float):Float
	{
		border.y = newY - BORDER;
		name.y = newY + (HEIGHT / 2) - (name.height / 2) - 20;
		time.y = newY + (HEIGHT / 2) - (time.height / 2);

		super.set_y(newY);
		return newY;
	}

	override function set_cameras(cameras:Array<FlxCamera>)
	{
		border.cameras = cameras;
		name.cameras = cameras;
		time.cameras = cameras;

		super.set_cameras(cameras);
		return cameras;
	}

	override function set_alpha(a:Float)
	{
		border.alpha = a;
		name.alpha = a;
		time.alpha = a;

		super.set_alpha(a);
		return a;
	}

	override function set_visible(v:Bool)
	{
		border.visible = v;
		name.visible = v;
		time.visible = v;

		super.set_visible(v);
		return v;
	}

	override function draw()
	{
		border.draw();
		super.draw();
		name.draw();
		time.draw();
	}
}
