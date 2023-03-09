package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.math.Vector2;
import openfl.Assets;
import openfl.display.BitmapData;

using StringTools;

typedef CharacterData =
{
	file:String,
	animations:Array<JsonAnimation>,
	color:String,
	?icon:String,
	?scale:Float,
	?facingLeft:Bool,
	?noAntialiasing:Bool,
	?isDeathAnim:Bool
}

typedef JsonAnimation =
{
	name:String,
	anim:String,
	fps:Int,
	loop:Bool,
	offsets:Array<Int>,
	?indices:Array<Int>
}

class Character extends FlxSprite
{
	public var charData:CharacterData = {
		file: "",
		animations: [],
		color: "50a5eb",
		facingLeft: false
	};

	// DEBUGGING PURPOSES
	public var internalNames:Map<String, String> = [];
	public var internalIndices:Map<String, Array<Int>> = [];
	public var debugMode:Bool = false;

	public var animOffsets:Map<String, Array<Int>> = new Map<String, Array<Int>>();
	public var curCharacter:String = 'bf';
	public var iconColor:String = "50a5eb";
	public var isPlayer:Bool = false;
	public var isDeathAnim:Bool = false;

	public var danced:Bool = false;
	public var useAlternateIdle:Bool = false;
	public var holdTimer:Float = 0;

	public var loopedIdle:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;
		moves = false;

		var path = 'assets/characters/$character.json';
		if (Assets.exists(path))
		{
			trace('[$character] Reading JSON file');
			charData = haxe.Json.parse(Assets.getText(path));
			frames = getSparrowAtlas('characters/${charData.file}', 'shared');
			iconColor = charData.color;

			antialiasing = !charData.noAntialiasing;

			if (charData.scale != null)
				setGraphicSize(Std.int(width * charData.scale));

			for (i in charData.animations)
			{
				if (i.indices != null)
				{
					addByIndices(i.name, i.anim, i.indices, "", i.fps, i.loop);
				}
				else
					addByPrefix(i.name, i.anim, i.fps, i.loop);

				addOffset(i.name, i.offsets[0], i.offsets[1]);
			}

			isDeathAnim = charData.isDeathAnim;
			if (isDeathAnim)
				playAnim("firstDeath");
			else
				dance();

			trace('[$character] Finished reading JSON.');
		}
		else
		{
			switch (curCharacter)
			{
				// mister SG must be hardcoded to work with embed i THINK
				case 'SG':
					iconColor = '000000';
					frames = getSparrowAtlas('SG', 'shadow');
					addByPrefix('idle', "idle", 24, true);
					addByPrefix('singLEFT', "right", 24, false);
					addByPrefix('singUP', "up", 24, false);
					addByPrefix('singDOWN', "down", 24, true);
					addByPrefix('singRIGHT', "left", 24, false);
					addByPrefix('bye', "disappearend", 24, false);

					addOffset('idle', 0, 0);
					addOffset('singLEFT', 105, -11);
					addOffset('singUP', 19, 29);
					addOffset('singDOWN', -53, -23);
					addOffset('singRIGHT', -77, 2);
					addOffset('bye', 514, 245);

					loopedIdle = true;
					animation.play('idle');
					flipX = true;

				case 'humanDeath' | 'demonDeath' | 'deathAnims/mcdietis':
					frames = getSparrowAtlas('characters/$curCharacter', 'shared');
					addByPrefix('firstDeath', "fever dies", 24, false);
					addByPrefix('deathLoop', "fever dead loop", 24, true);
					addByPrefix('deathConfirm', "fever dead confirm", 24, false);

					switch (curCharacter)
					{
						case 'humanDeath':
							addOffset('firstDeath', 42, 108);
							addOffset('deathLoop', 20, 109);
							addOffset('deathConfirm', 87, 131);
						case 'demonDeath':
							addOffset('firstDeath', 52, 98);
							addOffset('deathLoop', 31, 95);
							addOffset('deathConfirm', 97, 121);
					}

					playAnim('firstDeath');
					flipX = true;
					isDeathAnim = true;
				case 'bf-pixel-dead':
					iconColor = 'E353C8';
					frames = getSparrowAtlas('characters/fever/pixel-death');
					addByPrefix('firstDeath', "BF Dies pixel", 24, false);
					addByPrefix('deathLoop', "Retry Loop", 24, true);
					addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

					addOffset('firstDeath', -37, -25);
					addOffset('deathLoop', -37, -25);
					addOffset('deathConfirm', -37, -25);
					playAnim('firstDeath');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;
					flipX = true;
					isDeathAnim = true;
				case 'bf-demon-pixel-dead':
					iconColor = 'E353C8';
					frames = getSparrowAtlas('characters/fever/pixel-demon-death');
					addByPrefix('firstDeath', "DemonFeverDies", 24, false);
					addByPrefix('deathLoop', "Retry Loop", 24, true);
					addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

					addOffset('firstDeath', -37, -25);
					addOffset('deathLoop', -37, -25);
					addOffset('deathConfirm', -37, -25);
					playAnim('firstDeath');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;
					flipX = true;
					isDeathAnim = true;
				case 'bf-smushed':
					iconColor = 'E353C8';
					frames = getSparrowAtlas('characters/fever/Fever_paste_anims');
					addByIndices('firstDeath', "fever squish0", [
						2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
						37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64
					], "", 24, false);
					addByPrefix('deathLoop', "fever squish loop0", 24, true);
					addByPrefix('deathConfirm', "fever squish confirm0", 24, false);

					addOffset('firstDeath', 326, 323);
					addOffset('deathLoop', -404, -383);
					addOffset('deathConfirm', -417, -58);
					playAnim('firstDeath');

					updateHitbox();
					flipX = true;
					isDeathAnim = true;
				case 'bf-hallow-dead':
					frames = getSparrowAtlas('characters/deathAnims/hallow');
					addByPrefix('firstDeath', "Fever dies0", 24, false);
					addByPrefix('deathLoop', "Fever dies loop", 24, true);
					addByPrefix('deathConfirm', "Fever Dead confirm", 24, false);
					animation.play('firstDeath');

					addOffset('firstDeath');
					addOffset('deathLoop', -73, -35);
					addOffset('deathConfirm', -26, -187);
					playAnim('firstDeath');

					flipX = true;
					isDeathAnim = true;
				case 'madDeath':
					frames = getSparrowAtlas('characters/deathAnims/madDeath');
					addByPrefix('firstDeath', "fever dies", 24, false);
					addByPrefix('deathLoop', "fever dead loop", 24, true);
					addByPrefix('deathConfirm', "fever dead confirm", 24, false);
					animation.play('firstDeath');

					addOffset('firstDeath');
					addOffset('deathLoop', -488, -115);
					addOffset('deathConfirm', -273, -125);
					playAnim('firstDeath');

					flipX = true;
					isDeathAnim = true;
				case 'none': // peak character design. im not recoding kade engine to support no gf lmao
					loadGraphic(new BitmapData(2, 2, true, 0x0), true, 1, 1);
					animation.add('idle', [0], 0, false);
					animation.play('idle');
			}
		}

		if (animation.curAnim == null)
			dance();

		if (charData.facingLeft && !isPlayer || !charData.facingLeft && isPlayer)
		{
			flipX = !flipX;
		}
	}

	var floatX:Float = 0;
	var floatY:Float = 0;
	var floatAngle:Float = 0;

	override function update(elapsed:Float)
	{
		if (animation.curAnim.name.startsWith('sing'))
		{
			holdTimer += elapsed;
		}
		else
		{
			if (holdTimer > 0)
				holdTimer = 0;

			// Used to sync tea's scared anim to taki's singing anims
			holdTimer -= elapsed;
		}

		if (!isPlayer)
		{
			if (holdTimer >= Conductor.stepCrochet * (curCharacter == 'dad' ? 6.1 : 4) * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		if (!debugMode)
		{
			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
			{
				playAnim('idle', true, false, 10);
			}

			switch (curCharacter)
			{
				case 'gf':
					if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
						playAnim('danceRight');
				case 'mom-car' | 'mom-carnight':
					if (animation.curAnim.finished && animation.curAnim.name == 'idle')
					{
						playAnim('idle-loop');
					}
				case 'mako-demon':
					floatY += 0.1; // i'd rather much redo this with tweening but im lazy
					y += Math.sin(floatY);
				case 'hallow' | 'gf-notea':
					floatY += 0.07;
					y += Math.sin(floatY);

					if (curCharacter == 'gf-notea')
					{
						floatAngle += 0.05;
						angle = Math.sin(floatAngle);
					}
				case 'tea-bat':
					floatX += 0.02;
					x += Math.sin(floatX);
					floatY += 0.07;
					y += Math.sin(floatY);
			}
		}

		super.update(elapsed);
	}

	public function dance()
	{
		if (!canIdle())
			return;

		if (!debugMode)
		{
			if (animOffsets.exists('danceLeft'))
			{
				if (animation.curAnim == null || !animation.curAnim.name.startsWith('hair'))
				{
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				}
			}
			else
			{
				switch (curCharacter)
				{
					case 'bf' | 'bf-demon':
						playAnim('idle' + ((PlayState.instance != null
							&& PlayState.SONG.player2 == 'robo-cesar'
							|| useAlternateIdle) ? '-frown' : ''));
					case 'scarlet':
						playAnim('idle' + (useAlternateIdle ? '-mad' : ''));
					default:
						if (useAlternateIdle && (animOffsets.exists('idle-frown') || animOffsets.exists('idle-alt')))
							playAnim(animOffsets.exists('idle-frown') ? 'idle-frown' : 'idle-alt');
						else
							playAnim('idle');
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animOffsets.exists(AnimName))
		{
			animation.play(AnimName, Force, Reversed, Frame);

			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);

			if (animation.exists("danceLeft"))
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}

				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
		else
		{
			if (AnimName.endsWith('miss'))
			{
				FlxTween.cancelTweensOf(this);
				color = FlxColor.fromString('#84009E');
				playAnim(AnimName.replace('miss', ''), Force, Reversed, Frame);
				FlxTween.color(this, 0.33, this.color, FlxColor.WHITE);
			}
		}
	}

	public function canIdle():Bool
	{
		if (animation.curAnim == null)
			return true;

		switch (curCharacter)
		{
			case 'pepper-freeplay':
				return animation.curAnim.name != 'pull' || animation.curAnim.name == 'pull' && animation.finished;
			case 'gf':
				return animation.curAnim.name != 'sad' || animation.curAnim.name == 'sad' && animation.finished;
			default:
				return true;
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [Math.floor(x), Math.floor(y)];
	}

	function addByPrefix(animName:String, xmlName:String, fps:Int = 24, loop:Bool = true)
	{
		animation.addByPrefix(animName, xmlName, fps, loop);
		internalNames.set(animName, xmlName);
	}

	function addByIndices(animName:String, prefix:String, indices:Array<Int>, postFix:String, fps:Int, ?loop:Bool)
	{
		animation.addByIndices(animName, prefix, indices, postFix, fps, loop);
		internalNames.set(animName, prefix);
		internalIndices.set(animName, indices);
	}

	function getSparrowAtlas(file:String, library:String = "shared")
	{
		charData.file = StringTools.replace(file, "characters/", "");
		return Paths.getSparrowAtlas(file, library);
	}
}
