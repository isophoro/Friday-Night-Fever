package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;

/**
	*DEBUG MODE
 */
class AnimationDebug extends FlxUIState
{
	var bf:Boyfriend;
	var dad:Character;
	var ghost:Character;

	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var UI_box:FlxUITabMenu;

	var gridBG:FlxSprite;
	var camHUD:FlxCamera;
	var camGame:FlxCamera;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		super.create();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var saveButton:FlxButton = new FlxButton(FlxG.width - 150, 10, "Save to File", function()
		{
			save();
		});

		var characters = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var charSwitch = new FlxUIDropDownMenu(FlxG.width - 150, 50, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			FlxG.switchState(new AnimationDebug(characters[Std.parseInt(character)]));
		});
		charSwitch.dropDirection = Down;
		charSwitch.selectedLabel = daAnim;
		charSwitch.scrollFactor.set();
		charSwitch.cameras = [camHUD];

		gridBG = FlxGridOverlay.create(10, 10, 1280, 720);
		gridBG.scrollFactor.set(0, 0);
		add(gridBG);

		add(charSwitch);

		if (daAnim == 'bf')
			isDad = false;

		if (isDad)
		{
			dad = new Character(0, 0, daAnim);
			dad.debugMode = true;

			char = dad;
			dad.flipX = false;
		}
		else
		{
			bf = new Boyfriend(0, 0);
			bf.debugMode = true;

			char = bf;
			bf.flipX = false;
		}

		ghost = new Character(char.x, char.y, char.curCharacter, char.isPlayer);
		ghost.playAnim("idle");
		ghost.screenCenter();
		char.playAnim("idle");
		char.setPosition(ghost.x, ghost.y);

		ghost.debugMode = true;
		ghost.animOffsets = char.animOffsets;
		add(ghost);
		ghost.alpha = 0.6;
		ghost.flipX = char.flipX;
		add(char);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
		dumbTexts.cameras = [camHUD];

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.setBorderStyle(OUTLINE, FlxColor.BLACK, 1, 1);
		textAnim.scrollFactor.set();
		add(textAnim);
		textAnim.cameras = [camHUD];

		saveButton.cameras = [camHUD];
		saveButton.scrollFactor.set();
		add(saveButton);

		var facingLeft = new FlxUICheckBox(FlxG.width - 250, 10, null, null, "Facing Left", 100);
		facingLeft.checked = char.charData.facingLeft;
		// _song.needsVoices = check_voices.checked;
		facingLeft.callback = function()
		{
			char.charData.facingLeft = facingLeft.checked;
			trace('CHECKED!');
		};
		add(facingLeft);
		facingLeft.cameras = [camHUD];

		var noAnti = new FlxUICheckBox(FlxG.width - 250, 30, null, null, "No Anti-Aliasing", 100);
		noAnti.checked = char.charData.noAntialiasing;
		// _song.needsVoices = check_voices.checked;
		noAnti.callback = function()
		{
			char.charData.noAntialiasing = noAnti.checked;
			char.antialiasing = !noAnti.checked;
			trace('CHECKED!');
		};
		add(noAnti);
		noAnti.cameras = [camHUD];

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.setPosition(char.getGraphicMidpoint().x, char.getGraphicMidpoint().y);
		add(camFollow);

		FlxG.camera.follow(camFollow);
	}

	function save()
	{
		var json:Character.CharacterData = {
			file: char.charData.file,
			animations: [],
			color: char.iconColor,
			facingLeft: char.charData.facingLeft,
			noAntialiasing: !char.antialiasing
		};

		if (char.scale.x != 1)
		{
			trace("SCALE: " + char.scale.x);
			json.scale = char.scale.x;
		}

		for (k => v in char.animOffsets)
		{
			if (char.animation.getByName(k) != null)
			{
				var anim = char.animation.getByName(k);
				json.animations.push({
					name: k,
					anim: char.internalNames[k],
					offsets: v,
					fps: Std.int(anim.frameRate),
					loop: anim.looped
				});

				if (char.internalIndices.exists(k))
				{
					trace("Saving indices for animation " + k);
					json.animations[json.animations.length - 1].indices = char.internalIndices[k];
				}
			}
			else
				trace("Unable to save null animation: " + k);
		}

		#if sys
		sys.io.File.saveContent("assets/characters/" + char.curCharacter + ".json", Json.stringify(json, "\t"));
		#end
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1, 1);
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float)
	{
		gridBG.scale.x = gridBG.scale.y = (FlxG.camera.zoom < 1 ? 1 * (1 / FlxG.camera.zoom) : 1);
		FlxG.mouse.visible = true;

		if (char != null && char.animation.curAnim != null)
		{
			textAnim.text = char.curCharacter + " | " + char.animation.curAnim.name;
			textAnim.x = (FlxG.width / 2) - (textAnim.width / 2);
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
		{
			#if sys
			var string = "";
			for (k => v in char.animOffsets)
				string += 'addOffset(\"$k\", ${v[0]}, ${v[1]});\n';

			sys.io.File.saveContent(char.curCharacter + ".txt", string);
			#end
		}

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);

			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		super.update(elapsed);
	}
}
