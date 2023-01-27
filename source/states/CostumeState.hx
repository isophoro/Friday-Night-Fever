package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class CostumeState extends MusicBeatState
{
	var CharacterList:Array<CostumeName> = [
		FEVER, TEASAR, FEVER_NUN, FEVER_CASUAL, FEVER_MINUS, DOODLE, CEABUN, FLU, CLASSIC, MCDIETIS, SKELLY, SHELTON, CEDAR, FEVER_ISO, FEVER_COAT
	];

	var character:Character;
	var cam:FlxCamera = new FlxCamera();
	var camHUD:FlxCamera = new FlxCamera();

	var curSelected:Int = 0;
	var lock:FlxSprite;

	var loadingGrp:FlxGroup = new FlxGroup();
	var loadedCharacters:Array<Character> = [];
	var loaded:Bool = false;

	var boxEnd:FlxSprite;
	var box:FlxSprite;
	var desc:FlxText;

	var name:FlxText;

	override function create()
	{
		super.create();

		CostumeHandler.checkRequisites();

		FlxG.cameras.reset(cam);
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(cam, true);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('costumeMenu/locker'));
		bg.antialiasing = true;
		bg.alpha = 0.7;
		bg.screenCenter();
		add(bg);

		lock = new FlxSprite().loadGraphic(Paths.image('costumeMenu/lock'));
		lock.cameras = [camHUD];
		lock.screenCenter();
		add(lock);
		lock.visible = false;

		var border:FlxSprite = new FlxSprite().loadGraphic(Paths.image('costumeMenu/lockerBorder'));
		border.antialiasing = true;
		border.cameras = [camHUD];
		add(border);

		name = new FlxText(15, 668, 0, "", 42);
		name.setFormat(Paths.font("OpenSans-ExtraBold.ttf"), 36, 0xFFFFFFFF);
		name.cameras = [camHUD];
		add(name);

		boxEnd = new FlxSprite(-50, FlxG.height * 0.9).loadGraphic(Paths.image("costumeMenu/lockerArrow"));
		boxEnd.antialiasing = true;
		boxEnd.cameras = [camHUD];
		add(boxEnd);

		box = new FlxSprite(-50, FlxG.height * 0.9).makeGraphic(20, cast boxEnd.height, 0xFF000000);
		box.origin.x = 0;
		box.antialiasing = true;
		box.cameras = [camHUD];
		add(box);

		desc = new FlxText(FlxG.width, FlxG.height * 0.9, 0, "", 24);
		desc.setFormat(Paths.font("OpenSans-ExtraBold.ttf"), 24, 0xFFFFFFFF);
		desc.cameras = [camHUD];
		add(desc);

		for (i in 0...2)
		{
			var a = new FlxSprite().loadGraphic(Paths.image("costumeMenu/arrow"));
			a.setPosition((i == 0 ? FlxG.width * 0.25 : FlxG.width * 0.75) - (a.width / 2), (FlxG.height * 0.5) - (a.height / 2));
			if (i == 0)
			{
				a.flipX = a.flipY = true;
			}
			a.antialiasing = true;
			add(a);
		}

		add(loadingGrp);
		var blackScreen = new FlxSprite().loadGraphic(Paths.image("costumeMenu/lockerLoading"));
		blackScreen.screenCenter();
		loadingGrp.add(blackScreen);

		var text:FlxText = new FlxText(0, FlxG.height * 0.83 - 40, 0, "Preparing Costumes...", 18);
		text.borderStyle = OUTLINE;
		text.borderSize = 1.4;
		text.alignment = CENTER;
		loadingGrp.add(text);
		text.screenCenter(X);

		new FlxTimer().start(0.7, (t) ->
		{
			for (i in CharacterList)
			{
				var char = new Character(150, 150, CostumeHandler.data[i].character, true);
				add(char);
				remove(char);
				loadedCharacters.push(char);

				if (!CostumeHandler.unlockedCostumes.exists(i))
					char.color = FlxColor.BLACK;

				if (i == CharacterList[CharacterList.length - 1])
				{
					loadingGrp.remove(text);
					remove(loadingGrp);
					loaded = true;

					FlxG.camera.flash(0xFFA93C9F, 0.69);
					FlxG.camera.zoom = 0.75;
					changeSelection();
					trace("Finished loading.");
				}
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;

		if (loaded)
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
					FlxG.sound.play(Paths.sound('select'));
					CostumeHandler.curCostume = CharacterList[curSelected];
					character.playAnim('hey', true);
					updateText();
				}
			}
			else if (controls.BACK)
			{
				CostumeHandler.save();
				FlxG.sound.play(Paths.sound('return'));
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

		updateText();
	}

	function updateText()
	{
		var charData = CostumeHandler.data[CharacterList[curSelected]];
		desc.text = charData.description;
		if (CostumeHandler.unlockedCostumes[CharacterList[curSelected]] != null)
		{
			desc.text = CharacterList[curSelected] == CostumeHandler.curCostume ? "Currently Equipped" : "Not Equipped";
		}
		desc.x = FlxG.width - 14 - desc.width;
		box.x = desc.x;
		box.scale.x = (desc.width + 2) / box.width;
		boxEnd.x = box.x - boxEnd.width;
	}

	function addCharacter()
	{
		character = loadedCharacters[curSelected];
		add(character);

		var offsets:Array<Float> = [0, 0];
		if (CostumeHandler.data[CharacterList[curSelected]].characterOffset != null)
			offsets = CostumeHandler.data[CharacterList[curSelected]].characterOffset;

		character.setPosition(450 + offsets[0], 190 + offsets[1]);
	}
}
