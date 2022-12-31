package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Assets;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

class FreeplayState extends MusicBeatState
{
	static var curSelected:Int = 0;

	var songs:Array<SongMetadata> = [];
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<HealthIcon> = [];

	var curDifficulty:Int = 1;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var halloween:FlxText;
	var scoreText:FlxText;
	var diffText:FlxText;
	var scoreBG:FlxSprite;

	var peeps:FlxSprite;
	var feva:Character;
	var peppa:Character;

	override function create()
	{
		PlayState.deaths = 0;

		if (FlxG.sound.music == null || FlxG.sound.music != null && !FlxG.sound.music.playing)
		{
			Main.playFreakyMenu();
		}

		var initSonglist:Array<String> = CoolUtil.coolTextFile(Paths.txt('normalSonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));
		bg.antialiasing = true;
		add(bg);

		peeps = new FlxSprite(19, 65);
		peeps.frames = Paths.getSparrowAtlas('freeplay/peeps');
		peeps.animation.addByPrefix('bop', 'people', 24, false);
		peeps.animation.play("bop");
		peeps.origin.set(0, 0);
		peeps.scale.scale(0.67);
		peeps.antialiasing = true;
		add(peeps);

		var chairs:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/chairs'));
		chairs.antialiasing = true;
		add(chairs);

		feva = new Character(622, -60, "bf-freeplay", true);
		feva.scale.set(0.67, 0.67);
		add(feva);

		peppa = new Character(74, 176, "pepper-freeplay", false);
		peppa.scale.set(0.67, 0.67);
		add(peppa);

		var table:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/table'));
		table.antialiasing = true;
		add(table);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.ID = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);

			if (Highscore.fullCombos.exists(songs[i].songName))
			{
				icon.animation.play("hurt");
			}
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.antialiasing = true;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.31), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.origin.set(scoreBG.width, scoreBG.height / 2);
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.antialiasing = true;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
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

		Conductor.songPosition = FlxG.sound.music.time;
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		// score positoning shit
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = (scoreText.width / scoreBG.width) * 1.055;
		diffText.x = scoreBG.x + ((scoreBG.width / 2) / scoreBG.scale.x) - (diffText.width / 2);

		if (controls.UP_P)
		{
			changeSelection(-1);
		}
		else if (controls.DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.getLeft())
		{
			changeDiff(-1);
		}
		else if (controls.getRight())
		{
			changeDiff(1);
		}

		if (controls.getBack())
		{
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			FlxTransitionableState.skipNextTransOut = false;
			var poop:String = Highscore.formatSong(StringTools.replace(songs[curSelected].songName, " ", "-").toLowerCase(), curDifficulty);

			trace(poop);

			if (poop.toLowerCase().contains("mechanical"))
			{
				FlxTransitionableState.skipNextTransOut = true;
				FlxTransitionableState.skipNextTransIn = true;
			}

			PlayState.SONG = Song.loadFromJson(poop, StringTools.replace(songs[curSelected].songName, " ", "-").toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty = Difficulty.bound(curDifficulty + change);

		PlayState.minus = curDifficulty == 4;

		diffText.text = '< ' + CoolUtil.difficultyArray[curDifficulty].toUpperCase() + ' >';

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		diffText.alignment = CENTER;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		changeDiff();

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
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

	override function beatHit()
	{
		if (curBeat >= 16 && !FlxG.sound.muted && FlxG.sound.volume > 0)
		{
			var icon = iconArray[curSelected];
			icon.origin.set(icon.width / 2, 0);
			icon.scale.set(1 + (.135 * FlxG.sound.volume), 1 + (.135 * FlxG.sound.volume));
			FlxTween.tween(icon.scale, {x: 1, y: 1}, (Conductor.crochet / 1000) / 2);
		}

		peeps.animation.play("bop");
		peppa.dance();
		feva.dance();
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
