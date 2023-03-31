package states.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

typedef FreeplayWeek =
{
	image:String,
	songs:Array<Array<String>>
}

class FreeplayMenu extends MusicBeatSubstate
{
	// fuck it we hardcode
	static final FREEPLAY_SONGS:Array<FreeplayWeek> = [
		{
			"image": "week1",
			"songs": [
				["Milk-Tea", "gf"],
				["Peastep", "peakek"],
				["Eros", "peakek"],
				["Down-Horrendous", "peasus"]
			]
		},
		{
			"image": "week2",
			"songs": [
				["Star-Baby", "spooky"],
				["Last-Meow", "feralspooky"],
				["Bazinga", "taki"],
				["Crucify", "taki"]
			]
		},
		{
			"image": "week2.5",
			"songs": [["Prayer", "taki"], ["Bad-Nun", "taki"]]
		},
		{
			"image": "week3",
			"songs": [["Mako", "mako"], ["VIM", "mako"], ["Retribution", "mako-demon"]]
		},
		{
			"image": "week4",
			"songs": [["Honey", "hunni"], ["Bunnii", "hunni"], ["Throw-It-Back", "hunni"]]
		},
		{
			"image": "week5",
			"songs": [["Mild", "pepper"], ["Spice", "pepper"], ["Party-Crasher", "yukichi"]]
		},
		{
			"image": "week6",
			"songs": [
				["Ur-Girl", "mega-real"],
				["Chicken-Sandwich", "mega-real"],
				["Funkin-God", "flippy-real"]
			]
		},
		{
			"image": "extras",
			"songs": [
				["Metamorphosis", "peakek"],
				["Void", "peakek"],
				["Down Bad", "peakek"],
				["Farmed", "mako-demon"],
				["Space-Demons", "bf-old"],
				["Old-Hardships", "tea-bat"]
			]
		}
	];

	static final FRENZY_SONGS:Array<FreeplayWeek> = [
		{
			"image": "week7",
			"songs": [
				["Preparation", "gf"],
				["C354R", "robo-cesar"],
				["Loaded", "robo-cesar"],
				["Gears", "robofvr-final"]
			]
		},
		{
			"image": "week8",
			"songs": [
				["Tranquility", "scarlet"],
				["Princess", "scarlet"],
				["Crack", "scarlet"],
				["Bloom", "scarlet-final"],
			]
		},
		{
			"image": "weekhallow",
			"songs": [
				["Hallow", "hallow"],
				["Eclipse", "hallow"],
				["SOUL", "hallow"],
				["Dead-Mans-Melody", "toothpaste"]
			]
		},
		{
			"image": "weekminus",
			"songs": [["Grando", "robo-cesar"], ["Feel-The-Rage", "taki"]]
		},
		{
			"image": "week9",
			"songs": [
				["DUI", "rolldog"],
				["Cosmic-Swing", "rolldog"],
				["Cell-From-Hell", "rolldog"],
				["W00F", "rolldog"]
			]
		},
		{
			"image": "extras",
			"songs": [
				["Hardships", "tea-bat"],
				["Erm...", "pepper"],
				["Mechanical", "scarlet"],
				// ["Shadow", "bf"],
				["Old-Hallow", "hallow"],
				["Old-Portrait", "hallow"],
				["Old-Soul", "hallow"]
			]
		}
	];

	var isFrenzy:Bool = false;

	final PADDING = 45;

	var curSelected:Int = 0;
	var textGrp:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var icons:FlxTypedGroup<HealthIcon> = new FlxTypedGroup<HealthIcon>();
	var body:MenuSprite;
	var allowInput:Bool = false;
	var diffText:FlxText;
	var curDifficulty:Int = 2;

	public function new(isFrenzy:Bool = false)
	{
		super();

		this.isFrenzy = isFrenzy;
	}

	override function create()
	{
		super.create();

		var header:MenuSprite = new MenuSprite(0, 0, "header " + (isFrenzy ? "frenzy" : "classic"));
		header.screenCenter(X);
		add(header);

		body = new MenuSprite(header.x, 0, "body");
		body.y = header.y + header.height - 1;
		add(body);

		var nextLoc:Float = PADDING;

		var list = isFrenzy ? FRENZY_SONGS : FREEPLAY_SONGS;
		for (i in list)
		{
			var ind = list.indexOf(i);

			var image:MenuSprite = new MenuSprite(body.x, body.y, i.image);
			image.x = body.x + (body.width * ((ind + 1) % 2 == 0 ? 0.75 : 0.25)) - (image.width / 2);
			image.y = body.y + nextLoc;
			add(image);

			for (ii in 0...i.songs.length)
			{
				var song = i.songs[ii];
				var textX = (ind + 1) % 2 == 0 ? image.x - 20 : image.x + image.width + 20;

				var text = new FlxText(textX, 0, 0, '${song[0]}\n   '.replace("-", " ").replace("Old ", "[OLD] "));
				text.setFormat(Paths.font("Funkin.otf"), 40, FlxColor.WHITE);
				if ((ind + 1) % 2 == 0)
					text.x -= text.width;

				if (i.image == "extras")
					text.y = image.y + (70 * ii);
				else
					text.y = (image.y + (image.height / 2)) - ((text.height + 10) * (i.songs.length / 2)) + ((text.height + 10) * ii);

				text.ID = textGrp.length;

				var icon:HealthIcon = new HealthIcon(song[1]);
				icon.origin.set(0, 0);
				icon.scale.scale(0.6);
				icon.updateHitbox();
				icon.setPosition(image.x > text.x ? text.x - icon.width - 10 : text.x + text.width + 5, text.y - (icon.height / 2) + 20);
				add(icon);
				icons.add(icon);

				add(text);
				textGrp.add(text);
			}

			nextLoc += image.height + PADDING;
		}

		body.scale.y = ((body.y + nextLoc - PADDING) / body.height) * 1.8;
		body.updateHitbox();
		body.antialiasing = false;
		var footer:MenuSprite = new MenuSprite(header.x, 0, "footer");

		footer.y = body.y + body.height - 1;
		add(footer);

		diffText = new FlxText(0, 0, 0, "< Normal >", 24);
		diffText.setFormat(Paths.font("Funkin.otf"), 24, FlxColor.WHITE, CENTER);
		diffText.antialiasing = true;
		add(diffText);
		diffText.visible = false;

		changeSelection();
		FlxG.camera.scroll.y = -500;
		FlxTween.tween(FlxG.camera.scroll, {y: 0}, 0.65, {
			onComplete: (t) ->
			{
				allowInput = true;
			},
			ease: FlxEase.elasticOut
		});
	}

	var waitTimer:Float = 0;
	var intervalTimer:Float = 0.16;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!allowInput)
			return;

		if (controls.ACCEPT)
		{
			allowInput = false;

			loadSong(textGrp.members[curSelected].text, curDifficulty);
		}

		if (controls.UP_P)
			changeSelection(-1);
		else if (controls.DOWN_P)
			changeSelection(1);
		else if (controls.BACK)
		{
			allowInput = false;
			FlxTween.tween(FlxG.camera.scroll, {y: -950}, 0.65, {
				onComplete: (t) ->
				{
					close();
				},
				ease: FlxEase.quadInOut
			});
		}

		if (controls.UP || controls.DOWN)
		{
			waitTimer += elapsed;

			if (waitTimer >= 0.45)
			{
				intervalTimer += elapsed;

				if (intervalTimer > 0.16)
				{
					intervalTimer = 0;
					changeSelection(controls.UP ? -1 : 1);
				}
			}
		}
		else
		{
			waitTimer = 0;
			intervalTimer = 0.16;
		}

		if (controls.LEFT_P)
			changeDifficulty(-1);
		else if (controls.RIGHT_P)
			changeDifficulty(1);
	}

	function changeDifficulty(change:Int = 0)
	{
		curDifficulty = Difficulty.bound(curDifficulty + change);

		var text = textGrp.members[curSelected].text.replace("\n", "").trim().replace(" ", "-").replace("[OLD]", "Old").replace("...", "").toLowerCase();
		if (!lime.utils.Assets.exists(Paths.json('$text/$text')) && curDifficulty == 1)
		{
			curDifficulty = 2;
		}

		diffText.text = '< ${Difficulty.data[curDifficulty].name} >';
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected >= textGrp.length)
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = textGrp.length - 1;

		changeDifficulty(); // check incase difficutly is missing
		textGrp.forEach((text) ->
		{
			text.color = curSelected == text.ID ? FlxColor.WHITE : FlxColor.GRAY;
			icons.members[text.ID].alpha = curSelected == text.ID ? 1 : 0.7;
			if (curSelected == text.ID)
			{
				FlxTween.cancelTweensOf(FlxG.camera.scroll);
				FlxTween.tween(FlxG.camera.scroll, {y: text.y - 400 < 0 ? 0 : text.y - 400}, 0.3, {ease: FlxEase.smootherStepInOut});
				diffText.setPosition(text.x + (text.width / 2) - (diffText.width / 2), text.y + text.height - 27);
				diffText.visible = true;
			}
		});
	}

	public static function loadSong(song:String, curDifficulty:Int)
	{
		// i am so sorry
		var txt = song.replace("\n", "").trim().replace(" ", "-").replace("[OLD]", "Old").replace("...", "").toLowerCase();
		var poop:String = Highscore.formatSong(txt, curDifficulty);

		if (poop.toLowerCase().contains("mechanical") || poop.toLowerCase().contains("erm"))
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxTransitionableState.skipNextTransIn = true;
		}

		PlayState.SONG = Song.loadFromJson(poop, txt);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.storyWeek = 0;
		FreeplayState.loading = true;
		if (!FlxTransitionableState.skipNextTransOut)
		{
			@:privateAccess
			{
				var instance = cast(FlxG.state, FreeplayState);
				instance.frenzy.visible = false;
				instance.classic.visible = false;
			}
		}

		if (FlxG.state.subState != null)
		{
			FlxTween.tween(FlxG.camera.scroll, {y: -950}, 0.65, {
				onComplete: (t) ->
				{
					if (FlxG.state.subState != null)
						FlxG.state.subState.close();
				},
				ease: FlxEase.cubeInOut
			});
		}
		else
			FlxG.state.closeSubState();
	}
}

class MenuSprite extends FlxSprite
{
	override public function new(x:Float, y:Float, anim:String)
	{
		super(x, y);
		antialiasing = true;
		frames = Paths.getSparrowAtlas("freeplay/menu");
		animation.addByPrefix(anim, anim, 0);
		animation.play(anim);
		origin.set(0, 0);
		scale.set(1.8, 1.8);
		updateHitbox();
	}
}
