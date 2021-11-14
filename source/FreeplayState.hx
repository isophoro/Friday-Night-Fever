package;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

@:enum abstract FreeplayStyle(String) from String to String 
{
	var NORMAL = "normal";
	var HALLOWEEN = "halloween";
	
	@:keep
	public static function getArrayInOrder():Array<String>
	{
		return [NORMAL, HALLOWEEN];
	}
}

class FreeplayState extends MusicBeatState
{
	@:allow(SelectingSongState)
	static var currentStyle:FreeplayStyle = NORMAL;

	@:allow(SelectingSongState)
	static var curSelected:Int = 0;

	var songs:Array<SongMetadata> = [];
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<HealthIcon> = [];

	var curDifficulty:Int = 1;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var bghalloween:FlxSprite;
	var halloween:FlxText;
	var scoreText:FlxText;
	var diffText:FlxText;
	var scoreBG:FlxSprite;

	final secretCode:String = '354';
	var userInput:String;
	var secretFound:Bool = false;

	override function create()
	{
		var initSonglist:Array<String> = CoolUtil.coolTextFile(Paths.txt(currentStyle + 'Songlist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		//FlxG.random.shuffle(songs);

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu" + "[" + CoolUtil.capitalizeFirstLetters(currentStyle) + "]", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		bghalloween = new FlxSprite().loadGraphic(Paths.image('halloweenBG'));
		add(bghalloween);
		bghalloween.alpha = 0;

		halloween = new FlxText(700, 0, "HALLOWEEN UPDATE SONG");
		halloween.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.ORANGE, CENTER, OUTLINE, FlxColor.BLACK);
		halloween.scrollFactor.set();
		add(halloween);
		halloween.screenCenter(Y);
		halloween.visible = false;

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.31), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();

		userInput = secretCode;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;


		if (controls.UP_P)
		{
			changeSelection(-1);
		}
		else if (controls.DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
		{
			changeDiff(-1);
		}
		else if (controls.RIGHT_P)
		{
			changeDiff(1);
		}

		if (controls.BACK)
		{
			if (currentStyle != HALLOWEEN)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}
	
			FlxG.switchState(new SelectingSongState());
		}

		if (controls.ACCEPT)
		{	
			var poop:String = Highscore.formatSong(StringTools.replace(songs[curSelected].songName," ", "-").toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, StringTools.replace(songs[curSelected].songName," ", "-").toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (FlxG.keys.justPressed.ANY && !secretFound)
		{
			var keyPressed = FlxG.keys.getIsDown()[0].ID.toString().toLowerCase();

			var numbers:Map<String, String> = [
				'one' => '1', 
				'two' => '2', 
				'three' => '3', 
				'four' => '4', 
				'five' => '5', 
				'six' => '6', 
				'seven' => '7',
				'eight' => '8', 
				'nine' => '9', 
				'zero' => '0'
			];

			if(numbers.get(keyPressed) != null)
				keyPressed = numbers.get(keyPressed);

			if (userInput.charAt(0) == keyPressed)
			{
				userInput = userInput.substring(1, userInput.length);
				trace(userInput);

				if (userInput.length <= 0)
				{
					secretFound = true;
					trace('swag');

					var poop:String = Highscore.formatSong("C354R", 2);

					PlayState.SONG = Song.loadFromJson(poop, "C354R");
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;
	
					PlayState.storyWeek = 0;
					PlayState.loadRep = false;
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				userInput = secretCode;
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		switch(currentStyle)
		{
			case HALLOWEEN:
				FlxTween.tween(bghalloween, {alpha: 1}, 1, {onComplete: (twn) -> {
					halloween.visible = true;
				}});

				curDifficulty = 2;
				diffText.color = FlxColor.ORANGE;
				diffText.text = CoolUtil.difficultyArray[curDifficulty].toUpperCase();
			default:
				diffText.text = '< ' +CoolUtil.difficultyArray[curDifficulty].toUpperCase() + ' >';
		}

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		diffText.alignment = CENTER;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
