package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class WeekPreviewSubState extends MusicBeatSubstate
{
	public var week:Int = 0;
	public var allowInputs:Bool = false;

	var side:FlxSprite;
	var bg:FlxSprite;
	var weekSpr:FlxSprite;
	var characters:Array<FlxSprite> = [];

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

		bg = new FlxSprite(513, -29);
		bg.frames = Paths.getSparrowAtlas("story/characterBGS");
		bg.animation.addByPrefix("bg", characterStr == "tea" ? "peakek" : characterStr, 24, true);
		bg.animation.play("bg");
		bg.antialiasing = true;
		bg.origin.set(0, 0);
		bg.scale.scale(0.75);
		bg.x += bg.width;
		add(bg);

		if (characterStr == "wee")
		{
			createCharacter("taki", 125, 0);
			createCharacter(characterStr, -50, 100);
		}
		else
			createCharacter(characterStr);

		side = new FlxSprite(-70, -28).loadGraphic(Paths.image("story/selectBG"));
		side.x -= side.width;
		side.antialiasing = true;
		side.origin.set(0, 0);
		side.scale.scale(0.75);
		add(side);

		weekSpr = new FlxSprite(0, 120);
		weekSpr.frames = Paths.getSparrowAtlas("story/weeks");
		weekSpr.animation.addByPrefix("week", weekAnim, 24, true);
		weekSpr.animation.play("week");
		weekSpr.antialiasing = true;
		weekSpr.x = -70 + (side.width * 0.75 / 2) - (weekSpr.width * 0.75 / 2) - 225;
		weekSpr.scale.set(0, 0);
		add(weekSpr);

		curDifficulty = new FlxSprite();
		curDifficulty.frames = Paths.getSparrowAtlas("story/difficulties");
		for (i in 0...CoolUtil.difficultyArray.length)
		{
			curDifficulty.animation.addByPrefix('$i', CoolUtil.difficultyArray[i].toLowerCase(), 24, false);
		}
		curDifficulty.ID = 1;
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
		var char:FlxSprite = new FlxSprite();
		char.frames = Paths.getSparrowAtlas("story/characters/" + characterStr);
		char.animation.addByPrefix("idle", characterStr + "art0", 24, true);
		char.animation.addByPrefix("confirm", characterStr + "art flare", 24, false);
		char.animation.play("idle");
		char.updateHitbox();
		char.screenCenter(Y);
		char.setPosition(FlxG.width, char.y + 100);
		char.antialiasing = true;
		add(char);

		var charDest = FlxG.width * 0.8 - (char.width / 2);
		switch (characterStr)
		{
			case "taki":
				charDest += 50;
				char.scale.set(0.9, 0.9);
			case "pepper":
				char.y -= 100;
			case "mako":
				charDest -= 50;
			case "mega":
				char.y += 30;
		}

		char.y += offsetY;
		FlxTween.tween(char, {x: charDest + offsetX}, 1.55, {ease: FlxEase.elasticOut});

		characters.push(char);
	}

	function updateDifficulty(change:Int = 0)
	{
		curDifficulty.ID += change;

		if (curDifficulty.ID < 0)
			curDifficulty.ID = CoolUtil.difficultyArray.length - 1;
		else if (curDifficulty.ID >= CoolUtil.difficultyArray.length)
			curDifficulty.ID = 0;

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
			allowInputs = false;

			for (i in [leftArrow, rightArrow, curDifficulty])
				i.visible = false;

			for (i in [bg].concat(characters))
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
							close();
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
			for (i in characters)
			{
				i.animation.play("confirm");
				i.centerOffsets();
				i.animation.finishCallback = (a) ->
				{
					if (i != characters[0])
						return;

					var diffic = "";

					switch (curDifficulty.ID)
					{
						case 0 | 1:
							diffic = '-easy';
						case 3 | 4:
							diffic = '-hard';
					}

					PlayState.storyDifficulty = curDifficulty.ID;
					PlayState.storyPlaylist = StoryMenuState.weekData[week];
					PlayState.isStoryMode = true;

					PlayState.SONG = Song.loadFromJson(StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() + diffic,
						StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase());
					PlayState.storyWeek = week;
					PlayState.campaignScore = 0;

					LoadingState.loadAndSwitchState(new PlayState(), true);
				}
			}
		}
	}
}
