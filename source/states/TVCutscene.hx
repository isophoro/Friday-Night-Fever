package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.text.FlxText;

class TVCutscene extends MusicBeatState
{
	var reporter:FlxSprite;

	var randomLines:Array<Array<Dynamic>> = [
		[
			"This just in, multiple reports are coming in, 
            suggesting that our VERY MAYOR is currently stopping traffic near Kips Pizzeria. 
            Could this be the first look of the mayors insanity letting loose?",
			"lettingloose",
			4
		],
		[
			"On other news, a traffic jam is stopping multiple residents from getting home today, 
            and it seems that the cause of the jam is our very mayor, Fever!",
			"othernews",
			2
		],
		[
			"Residents are angered this afternoon! Many bystanders are threatening to leave Fever Town 
            after what appears to be a doppelganger was found trashing the streets of Fever Town! More at 8.",
			"doppelganger",
			2
		]
	];

	var lines:Array<Array<Dynamic>> = [
		// ["Hahaha, I don't get paid enough for this job.", "paidenough", 3],
		// ["I need some coffee.", "anger", 2]
	];

	var curLine:FlxSound;
	var text:FlxText;
	var box:FlxSprite;

	override function create()
	{
		super.create();
		FlxG.sound.music.stop();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("tv/bg"));
		bg.antialiasing = true;
		add(bg);

		reporter = new FlxSprite(740, 40);
		reporter.frames = Paths.getSparrowAtlas("tv/funnyWoman");
		reporter.animation.addByPrefix("idle", "reporter", 24);
		reporter.animation.play("idle");
		add(reporter);

		box = new FlxSprite(-50, FlxG.height * 0.7).makeGraphic(20, 20, 0xFF000000);
		box.origin.y = 0;
		box.antialiasing = true;
		box.alpha = 0.7;
		add(box);

		text = new FlxText(0, FlxG.height * 0.7, 0, "", 24);
		text.setFormat(Paths.font("Plunge.otf"), 24, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		add(text);

		lines.insert(0, FlxG.random.getObject(randomLines));

		loadLine();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function loadLine()
	{
		text.text = lines[0][0];
		text.screenCenter(X);

		box.scale.x = (text.width + 5) / box.width;
		box.scale.y = (text.height + 5) / box.height;
		box.screenCenter(X);

		curLine = new FlxSound();
		FlxG.sound.list.add(curLine);
		curLine.loadEmbedded(Paths.soundRandom('tv/${lines[0][1]}', 1, lines[0][2]));
		curLine.play();
		curLine.onComplete = () ->
		{
			curLine.destroy();
			if (lines.length > 0)
				loadLine();
		}
		lines.shift();
	}
}
