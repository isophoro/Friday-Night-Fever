package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flxanimate.FlxAnimate;

class WeekPreviewSubState extends MusicBeatSubstate
{
	public var week:Int = 0;
	public var allowInputs:Bool = false;

	var side:FlxSprite;
	var bg:FlxSprite;
	var weekSpr:FlxSprite;
	var characters:Array<FlxAnimate> = [];

	var curDifficulty:FlxSprite;
	var leftArrow:FlxSprite = new FlxSprite();
	var rightArrow:FlxSprite = new FlxSprite();

	public function new(week:Int)
	{
		super();
		this.week = week;
	}

	override function create()
	{
		super.create();

		var characterStr:String = switch (week)
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

		var weekAnim:String = switch (week)
		{
			case 0: "tutorial";
			default: "week" + (week > 3 ? week - 1 : week) + "0"; // stupid zero so "week2" doesnt also load "week2.5" into its anim
			case 3: "week2.5";
			case 8: "week?";
			case 9: "week7";
			case 10: "week8";
			case 11: "weekbone";
		}

		bg = new FlxSprite(513, -29).loadGraphic(Paths.image("story/characterBGS/" + (characterStr == "tea" ? "peakek" : characterStr)));
		bg.antialiasing = true;
		bg.origin.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.x += bg.width;
		add(bg);

		if (characterStr == "wee")
		{
			createCharacter("taki", 125, 0);
			createCharacter(characterStr);
		}
		else
			createCharacter(characterStr);

		side = new FlxSprite(-70, -28).loadGraphic(Paths.image("story/selectBG"));
		side.x -= side.width;
		side.antialiasing = true;
		add(side);

		weekSpr = new FlxSprite(0, 120);
		weekSpr.frames = Paths.getSparrowAtlas("story/weeks");
		weekSpr.animation.addByPrefix("week", weekAnim, 24, true);
		weekSpr.animation.play("week");
		weekSpr.antialiasing = true;
		weekSpr.x = (side.width / 2) - (weekSpr.width / 2) - 168;
		weekSpr.scale.set(0, 0);
		add(weekSpr);

		curDifficulty = new FlxSprite();
		curDifficulty.frames = Paths.getSparrowAtlas("story/difficulties");
		for (i in Difficulty.DIFFICULTY_MIN...Difficulty.DIFFICULTY_MAX + 2)
		{
			curDifficulty.animation.addByPrefix('$i', Difficulty.data[i].name.toLowerCase(), 24, false);
		}
		curDifficulty.ID = 2;
		curDifficulty.scale.scale(0.4);
		curDifficulty.antialiasing = true;
		add(curDifficulty);

		for (i in [leftArrow, rightArrow])
		{
			i.frames = Paths.getSparrowAtlas("story/arrows");
			i.animation.addByPrefix("idle", "arrow0", 24, true);
			i.animation.addByPrefix("press", "arrow press0", 24, false);
			i.animation.play("idle");
			i.antialiasing = true;
			add(i);

			if (i == leftArrow)
				i.flipX = true;
		}

		for (i in [leftArrow, rightArrow, curDifficulty])
			i.visible = false;

		FlxTween.tween(side, {x: side.x + side.width}, 0.5, {
			onComplete: (t) ->
			{
				FlxTween.tween(weekSpr, {"scale.x": 0.75, "scale.y": 0.75}, 0.65, {
					ease: FlxEase.elasticOut,
					onComplete: (t) ->
					{
						allowInputs = true;

						for (i in [leftArrow, rightArrow, curDifficulty])
							i.visible = true;
					}
				});
			}
		});

		FlxTween.tween(bg, {x: bg.x - bg.width}, 0.5);
		updateDifficulty();
	}

	function createCharacter(characterStr:String, offsetX:Float = 0, offsetY:Float = 0)
	{
		var char:FlxAnimate = new FlxAnimate(0, 0, "assets/images/story/characters/" + characterStr, {Antialiasing: true, ShowPivot: false});
		char.anim.addBySymbol("idle", characterStr + " idle", 24, true);
		char.anim.addBySymbol("confirm", characterStr + " flare", 24, false);
		char.anim.play("idle");
		char.origin.set(0, 0);
		char.screenCenter(Y);
		char.setPosition(FlxG.width);
		char.antialiasing = true;
		add(char);

		var charDest:FlxPoint = new FlxPoint(0, 0);
		switch (characterStr)
		{
			case "hallow":
				charDest.set(700, -150);
			case "scarlet":
				charDest.set(710, 0);
			case "rolldog":
				charDest.set(815, 150);
			case "robo":
				charDest.set(755, 45);
			case "tea":
				charDest.set(750, 75);
			case "wee":
				charDest.set(773, 338);
			case "peakek":
				charDest.set(729, -29.5);
			case "hunni":
				charDest.set(740.5, -54.5);
			case "taki":
				charDest.set(652, -39);
				char.scale.set(0.9, 0.9);
			case "pepper":
				charDest.set(746.5, -101.5);
			case "mako":
				charDest.set(649.5, 146.5);
			case "mega":
				charDest.set(743, 30);
		}

		char.y = charDest.y + offsetY;
		FlxTween.tween(char, {x: charDest.x + offsetX}, 1.55, {ease: FlxEase.elasticOut});

		characters.push(char);
	}

	function updateDifficulty(change:Int = 0)
	{
		curDifficulty.ID = Difficulty.bound(curDifficulty.ID + change, (week == 2 || week == 9) ? 1 : 0);

		curDifficulty.animation.play('${curDifficulty.ID}');
		curDifficulty.updateHitbox();
		curDifficulty.setPosition(weekSpr.x + (weekSpr.width / 2) - (curDifficulty.width / 2), weekSpr.y + 375);

		leftArrow.setPosition(curDifficulty.x - leftArrow.width - 20, curDifficulty.y + (curDifficulty.height / 2) - (leftArrow.height / 2));
		rightArrow.setPosition(curDifficulty.x + curDifficulty.width + 20, curDifficulty.y + (curDifficulty.height / 2) - (leftArrow.height / 2));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (i in [leftArrow, rightArrow])
		{
			var held:Bool = allowInputs ? (i == leftArrow ? controls.LEFT : controls.RIGHT) : false;
			if (held)
				i.animation.play("press");
			else
				i.animation.play("idle");

			i.centerOffsets();
		}

		if (!allowInputs)
			return;

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound("return"));
			allowInputs = false;

			for (i in [leftArrow, rightArrow, curDifficulty])
				i.visible = false;

			var chars:Array<FlxSprite> = [for (i in characters) (cast i : FlxSprite)];
			for (i in [bg].concat(chars))
			{
				FlxTween.tween(i, {x: FlxG.width}, 0.3);
			}

			FlxTween.tween(weekSpr, {x: -weekSpr.width}, 0.2);

			for (i in [side])
			{
				FlxTween.tween(i, {x: -i.width}, 0.3, {
					onComplete: (t) ->
					{
						if (i == side)
						{
							bg.destroy();
							for (ii in chars)
								ii.destroy();
							close();
						}
					}
				});
			}
		}

		if (controls.LEFT_P)
			updateDifficulty(-1);
		else if (controls.RIGHT_P)
			updateDifficulty(1);

		if (controls.ACCEPT)
		{
			allowInputs = false;
			FlxG.sound.play(Paths.sound("select"));
			for (i in characters)
			{
				i.anim.play("confirm");
				i.centerOffsets();
				new FlxTimer().start(0.7, (t) ->
				{
					PlayState.storyDifficulty = curDifficulty.ID;
					if (curDifficulty.ID == 3)
						PlayState.storyPlaylist = StoryMenuState.minusWeekData[week];
					else
						PlayState.storyPlaylist = StoryMenuState.weekData[week];

					PlayState.isStoryMode = true;

					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.storyPlaylist[0], curDifficulty.ID),
						Highscore.formatSong(PlayState.storyPlaylist[0]));
					PlayState.storyWeek = week;
					PlayState.campaignScore = 0;

					LoadingState.loadAndSwitchState(switch (week)
					{
						case 9: if (curDifficulty.ID != 3) new states.TVCutscene(); else new PlayState(true);
						default: new PlayState(true);
					}, true);
				});
			}
		}
	}
}
