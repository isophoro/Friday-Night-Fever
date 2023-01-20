package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import sys.thread.Thread;

class CostumeState extends MusicBeatState
{
	var CharacterList:Array<CostumeName> = [FEVER, TEASAR, FEVER_NUN, FEVER_CASUAL, FEVER_MINUS, FEVER_COAT];

	var character:Character;
	var cam:FlxCamera = new FlxCamera();
	var camHUD:FlxCamera = new FlxCamera();

	var curSelected:Int = 0;
	var lock:FlxSprite;

	var loadingGrp:FlxGroup = new FlxGroup();
	var loadedCharacters:Array<Character> = [];
	var loadingProgress:FlxBar;
	var _loadingProgress:Int = 0;

	var name:FlxText;

	override function create()
	{
		super.create();
		FlxG.cameras.reset(cam);
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(cam, true);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('locker'));
		bg.antialiasing = true;
		bg.alpha = 0.7;
		bg.screenCenter();
		add(bg);

		lock = new FlxSprite().loadGraphic(Paths.image('lock'));
		lock.cameras = [camHUD];
		lock.screenCenter();
		add(lock);
		lock.visible = false;

		var border:FlxSprite = new FlxSprite().loadGraphic(Paths.image('lockerBorder'));
		border.antialiasing = true;
		border.cameras = [camHUD];
		add(border);

		name = new FlxText(15, 668, 0, "", 42);
		name.setFormat(Paths.font("OpenSans-ExtraBold.ttf"), 36, 0xFFFFFFFF);
		name.cameras = [camHUD];
		add(name);

		add(loadingGrp);
		var blackScreen = new FlxSprite().loadGraphic(Paths.image("lockerLoading"));
		blackScreen.screenCenter();
		loadingGrp.add(blackScreen);

		loadingProgress = new FlxBar(0, FlxG.height * 0.83, HORIZONTAL_INSIDE_OUT, 800, 15, this, '_loadingProgress', 0, 100);
		loadingProgress.createFilledBar(FlxColor.GRAY, 0xFF00FF00, true, 0xFF000000);
		loadingGrp.add(loadingProgress);
		loadingGrp.cameras = [camHUD];
		loadingProgress.screenCenter(X);

		var text:FlxText = new FlxText(0, loadingProgress.y - 40, 0, "Preparing Costumes... (0%)", 18);
		text.borderStyle = OUTLINE;
		text.borderSize = 1.4;
		text.alignment = CENTER;
		loadingGrp.add(text);
		text.screenCenter(X);

		new FlxTimer().start(0.25, (t) ->
		{
			Thread.create(() ->
			{
				for (i in CharacterList)
				{
					var char = new Character(150, 150, CostumeHandler.data[i].character, true);
					add(char);
					remove(char);
					loadedCharacters.push(char);

					if (!CostumeHandler.unlockedCostumes.exists(i))
						char.color = FlxColor.BLACK;

					_loadingProgress = Math.ceil((loadedCharacters.length / CharacterList.length) * 100);
					text.text = 'Preparing Costumes... ($_loadingProgress%)';

					if (_loadingProgress >= 100)
					{
						loadingGrp.remove(text);
						remove(loadingGrp);

						FlxG.camera.flash(0xFFA93C9F, 0.69);
						FlxG.camera.zoom = 0.75;
						changeSelection();
						trace("Finished loading.");
					}
				}
			});
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;

		if (_loadingProgress >= 100)
		{
			if (controls.LEFT_P)
			{
				changeSelection(-1);
			}
			else if (controls.RIGHT_P)
			{
				changeSelection(1);
			}

			if (controls.ACCEPT)
			{
				if (!lock.visible && CharacterList[curSelected] != CostumeHandler.curCostume)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CostumeHandler.curCostume = CharacterList[curSelected];
					character.playAnim('hey', true);
				}
			}
			else if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new MainMenuState(true));
			}
		}
	}

	override function beatHit()
	{
		if (character != null && (character.animation.finished || character.animation.curAnim.name == 'idle'))
			character.dance();
	}

	function changeSelection(change:Int = 0)
	{
		if (character != null)
		{
			character.playAnim('idle', true);
			remove(character);
		}

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		if (curSelected >= CharacterList.length)
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = CharacterList.length - 1;

		addCharacter();

		var charData = CostumeHandler.data[CharacterList[curSelected]];
		name.text = CostumeHandler.unlockedCostumes[CharacterList[curSelected]] != null ? charData.displayName : "???";
		lock.visible = !CostumeHandler.unlockedCostumes.exists(CharacterList[curSelected]);
	}

	function addCharacter()
	{
		character = loadedCharacters[curSelected];
		add(character);

		var offsets:Array<Float> = [0, 0];
		if (CostumeHandler.data[CharacterList[curSelected]].characterOffset != null)
			offsets = CostumeHandler.data[CharacterList[curSelected]].characterOffset;

		character.setPosition(450 + offsets[0], 240 + offsets[1]);
	}
}
