package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.input.FlxPointer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import flixel.util.FlxTimer;
import haxe.xml.Access;
import openfl.Assets;

using StringTools;

typedef DialogueAction =
{
	?msg:String,
	?portrait:String,
	?portraits:Array<String>,
	?emotion:String,
	?library:String,

	?playSound:String,
	?fadeInMus:String,
	?fadeOutMus:String,
	?side:Null<FlxDirection>,
	?fillBG:Null<FlxColor>,
	?setBG:String,
	?effect:String,
	?narrate:Bool,
	?proceedImmediately:Bool,
	?showOnlyBackground:Null<Bool>,
	?removePortrait:String,
	?fadeBG:String,
	?shake:Bool
}

class DialoguePortrait extends FlxSprite
{
	public var character:String = "";

	var ogScale:Float = 0.9;

	public function new(character:String, library:String)
	{
		super(0, -90);
		antialiasing = true;
		this.character = character;

		frames = Paths.getSparrowAtlas('dialogue/${character.toLowerCase()}', library);
		for (i in frames.frames)
		{
			var name = i.name.replace('${character.toLowerCase()} ', '');
			if (!animation.exists(name))
			{
				animation.addByNames(name, [i.name], 0);
			}
		}

		if (animation.exists("neutral"))
			animation.play("neutral");

		if (character == "mega")
		{
			origin.set(0, 0);
			setGraphicSize(Std.int(width * 2.4));
			updateHitbox();
			width -= 250;
			antialiasing = false;
		}
		else
		{
			setGraphicSize(Std.int(width * 0.9));
			updateHitbox();
		}

		ogScale = scale.x;
	}

	public function jump()
	{
		FlxTween.tween(this, {"scale.y": ogScale + 0.025, y: y - 18}, 0.05, {
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(this, {"scale.y": ogScale, y: y + 18}, 0.04, {ease: FlxEase.elasticInOut});
			}
		});
	}
}

class DialogueBox extends FlxTypedSpriteGroup<FlxSprite>
{
	public var fadeOut:Bool = true;

	var bg:FlxSprite;
	var box:FlxSprite;
	var text:FlxTypeText;

	var actions:Array<DialogueAction> = [];
	var portraits:Map<String, DialoguePortrait> = [];
	var curLeft:DialoguePortrait;
	var curRight:DialoguePortrait;
	var curPortrait:DialoguePortrait;

	var dialogueStarted:Bool = false;
	var skip:Bool = false;

	public var finishCallback:Void->Void;

	public function new(?dialogue:String)
	{
		super();

		bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		bg.antialiasing = true;
		bg.alpha = 0.7;
		add(bg);

		parseDialogue(dialogue);

		box = new FlxSprite(0, 460).loadGraphic(Paths.image("dialogue/box", "shared"));
		box.updateHitbox();
		box.screenCenter(X);
		box.antialiasing = true;
		add(box);

		text = new FlxTypeText(box.x + 25, box.y + 25, Std.int(FlxG.width * 0.85), "", 40);
		text.font = 'Plunge';
		text.color = 0xffffff;
		text.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		text.delay = 0.033;
		text.setTypingVariation(0.5, true);
		add(text);

		var skipDia = new FlxText(50, FlxG.height - 40, FlxG.width, "PRESS ESCAPE/BACKSPACE TO SKIP", 32);
		skipDia.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(skipDia);
		FlxTween.tween(skipDia, {alpha: 0}, 3, {startDelay: 3});

		box.y = FlxG.height;
		if (actions[0].setBG != null)
		{
			setBG(actions[0].setBG);
		}
		else if (actions[0].fillBG != null)
		{
			fillBG(actions[0].fillBG);
		}

		FlxTween.tween(box, {y: 460}, 0.5, {
			ease: FlxEase.elasticOut,
			onComplete: (t) ->
			{
				dialogueStarted = true;
				startDialogue();
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!dialogueStarted)
			return;

		if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
		{
			return endDialogue();
		}

		text.delay = FlxG.keys.pressed.SHIFT ? 0.02 : 0.033;

		@:privateAccess
		if (FlxG.keys.anyJustPressed([ENTER, SPACE]) || !text._typing && skip)
		{
			@:privateAccess
			if (!text._typing)
			{
				// FlxG.sound.play(Paths.sound("dialogue"), 0.4);
				startDialogue();
			}
			else
				text.skip();
		}
	}

	var daLibrary:String;

	function startDialogue()
	{
		if (actions[0] == null)
		{
			return endDialogue();
		}

		var action = actions[0];
		actions.shift();

		trace(daLibrary);

		if (action.playSound != null)
		{
			FlxG.sound.play(Paths.sound(action.playSound, daLibrary), 1);
		}

		if (daLibrary == null)
		{
			daLibrary = 'shared';
		}

		if (action.fadeInMus != null)
		{
			var split = action.fadeInMus.split(":");
			if (lime.utils.Assets.exists(Paths.inst(split[0])))
				FlxG.sound.playMusic(Paths.inst(split[0]), 0);
			else
				FlxG.sound.playMusic(Paths.music(split[0], daLibrary), 0);
			FlxG.sound.music.fadeIn(1, 0, split[1] != null ? Std.parseFloat(split[1]) : 1);
		}

		if (action.shake)
		{
			for (i in cameras)
				i.shake(0.05, 0.5);
		}

		if (action.fadeOutMus != null)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.fadeOut(1, 0);
		}

		if (action.fillBG != null)
		{
			fillBG(action.fillBG);
		}
		else if (action.setBG != null)
		{
			setBG(action.setBG);
		}
		else if (action.fadeBG != null) // this doesnt work
		{
			var newBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image(action.fadeBG, daLibrary));
			newBG.antialiasing = true;
			preAdd(newBG);
			members.insert(0, newBG);
			var oldBG = bg;
			bg = newBG;
			FlxTween.tween(oldBG, {alpha: 0}, 0.7, {
				onComplete: function(t)
				{
					oldBG.destroy();
					remove(oldBG);
					bg = newBG;
				}
			});
		}

		if (action.portrait != null && portraits[action.portrait] != null)
		{
			setCorrectPortrait(action);

			if (action.effect != null && action.effect == "jump")
			{
				FlxTween.completeTweensOf(portraits[action.portrait]);
				portraits[action.portrait].jump();
			}
		}
		else if (action.portraits != null)
		{
			for (i in action.portraits)
			{
				setCorrectPortrait({portrait: i});

				if (action.effect != null && action.effect == "jump")
				{
					FlxTween.completeTweensOf(portraits[i]);
					portraits[i].jump();
				}
			}

			var prev = portraits[action.portraits[0]];
			prev.color = 0xFFFFFFFF;
		}

		if (action.narrate)
		{
			text.sounds = null;

			if (curLeft != null)
				curLeft.color = 0xFF828282;
			if (curRight != null)
				curRight.color = 0xFF828282;
		}

		if (action.emotion != null && curPortrait != null)
		{
			curPortrait.animation.play(action.emotion);
		}

		if (action.showOnlyBackground != null)
		{
			showOnlyBG = action.showOnlyBackground;
		}

		if (showOnlyBG != null)
		{
			if (curLeft != null)
				curLeft.visible = !showOnlyBG;
			if (curRight != null)
				curRight.visible = !showOnlyBG;

			box.alpha = showOnlyBG ? 0.65 : 1;
		}

		skip = action.proceedImmediately;

		if (action.msg != null)
		{
			text.resetText(action.msg.trim());
			text.start(0.04, true);

			@:privateAccess
			{
				if (text.sounds != null && text.sounds[0] != null)
					text.sounds[0].volume = 0.35;
			}
		}
		else if (actions[0] != null)
			startDialogue();
	}

	function fillBG(color:FlxColor)
	{
		bg.makeGraphic(1280, 720, color);
		bg.alpha = 1;
	}

	function setBG(bgStr:String)
	{
		if (bgStr.length > 0)
		{
			var diaPath:String = 'dialogue_backgrounds/${bgStr}';
			bg.loadGraphic(Paths.image(Assets.exists(Paths.image(diaPath)) ? diaPath : bgStr, daLibrary));
			bg.alpha = 1;
		}
		else
		{
			bg.makeGraphic(1280, 720, FlxColor.BLACK);
			bg.alpha = 0.7;
		}
	}

	var showOnlyBG:Null<Bool> = null;

	function setCorrectPortrait(action:DialogueAction)
	{
		var portrait = portraits[action.portrait];
		if (curLeft == portrait || curRight == portrait)
			action.side = curLeft == portrait ? LEFT : RIGHT;

		if (action.side == null)
			action.side = portrait.character.startsWith("fever") ? RIGHT : LEFT;

		switch (action.side)
		{
			case RIGHT:
				if (curRight != null && curRight != portrait)
					curRight.visible = false;

				if (curRight != portrait)
				{
					portrait.setPosition(box.x + box.width - portrait.width + 40, box.y - portrait.height + 15);
					FlxTween.tween(portrait, {x: portrait.x - 40}, 0.18);
					portrait.alpha = 0;
					FlxTween.tween(portrait, {alpha: 1}, 0.13);

					if (PlayState.SONG.song.toLowerCase() == "shadow")
						portrait.y += 20;
				}

				portrait.flipX = !portrait.character.startsWith("fever");

				curRight = portrait;
				curRight.visible = true;
				curPortrait = curRight;

				if (curLeft != null)
					curLeft.color = 0xFF828282;
				if (curRight != null)
					curRight.color = 0xFFFFFFFF;
			default:
				if (curLeft != null && curLeft != portrait)
					curLeft.visible = false;

				if (curLeft != portrait)
				{
					portrait.setPosition(box.x - 40, box.y - portrait.height + 15);
					FlxTween.tween(portrait, {x: portrait.x + 40 + (portrait.character == "mega" ? -130 : 0)}, 0.18);
					portrait.alpha = 0;
					FlxTween.tween(portrait, {alpha: 1}, 0.13);
				}

				portrait.flipX = portrait.character.startsWith("fever");

				curLeft = portrait;
				curLeft.visible = true;
				curLeft.setPosition(box.x, box.y - curLeft.height + 15);
				curPortrait = curLeft;

				if (curLeft.character == "mega")
					curLeft.x -= 130;

				if (curRight != null)
					curRight.color = 0xFF828282;
				if (curLeft != null)
					curLeft.color = 0xFFFFFFFF;
		}

		if (action.removePortrait != null)
		{
			var portrait = (curLeft.character == action.removePortrait ? curLeft : curRight);
			portrait.visible = false;

			if (curLeft.character == action.removePortrait)
				curLeft = null;
			else
				curRight = null;
		}

		var char = portrait.character.split("-")[0];
		text.sounds = [
			FlxG.sound.load(Paths.sound("dialogue/" + (char.startsWith("fever") ? "fever" : char)), 0.6)
		];
	}

	function endDialogue()
	{
		dialogueStarted = false;

		if (FlxG.sound.music.volume >= 0.1)
		{
			FlxG.sound.music.stop();
		}

		if (!fadeOut)
		{
			return finishCallback();
		}

		for (i in [curLeft, curRight, box, text, bg])
		{
			if (i != null)
			{
				FlxTween.cancelTweensOf(i);
				FlxTween.tween(i, {alpha: 0}, 0.2, {
					onComplete: (t) ->
					{
						i.kill();
						if (i == box)
						{
							kill();

							for (i in portraits)
								i.destroy();

							if (finishCallback != null)
								finishCallback();
						}
					}
				});
			}
		}
	}

	function parseDialogue(rawDialogue:String)
	{
		var xml = Xml.parse(sys.io.File.getContent(rawDialogue));
		var data:Access = new Access(xml.firstElement());
		for (a in data.nodes.action)
		{
			var action:DialogueAction = {};

			action.shake = (a.has.shake && a.att.shake.charAt(0).toLowerCase() == "t");

			if (a.has.showOnlyBG)
			{
				action.showOnlyBackground = a.att.showOnlyBG.charAt(0).toLowerCase() == "t" ? true : false;
			}
			else
				action.showOnlyBackground = null;

			if (a.has.removePortrait)
				action.removePortrait = a.att.removePortrait;

			if (a.has.portrait || a.has.portraits)
			{
				if (a.has.portraits)
				{
					var s = a.att.portraits.split(",");
					for (i in s)
						addPortrait(i, daLibrary);

					action.portraits = s;
				}
				else
				{
					var portrait = a.att.portrait;
					action.portrait = portrait;
					addPortrait(portrait, daLibrary);

					if (a.has.side)
						action.side = a.att.side.toLowerCase().charAt(0) == "r" ? RIGHT : LEFT;
				}
			}

			if (a.has.emotion)
				action.emotion = a.att.emotion.toLowerCase();

			if (a.has.msg)
			{
				if (a.att.msg.length < 1)
					action.msg = "...";
				else
					action.msg = a.att.msg.replace('’', "'").replace("&quot;", '"');
			}
			else if (a.has.narrate)
			{
				action.msg = a.att.narrate;
				action.narrate = true;
			}

			if (a.has.fillBG)
				action.fillBG = FlxColor.fromString(a.att.fillBG);
			else if (a.has.setBG)
				action.setBG = a.att.setBG;
			else if (a.has.fadeBG)
				action.fadeBG = a.att.fadeBG;

			if (a.has.library)
			{
				action.library = a.att.library;
				daLibrary = a.att.library;
			}

			if (a.has.playSound)
				action.playSound = a.att.playSound;

			if (a.has.fadeInMus)
				action.fadeInMus = a.att.fadeInMus;

			if (a.has.fadeOutMus)
				action.fadeOutMus = a.att.fadeOutMus;

			if (a.has.effect)
				action.effect = a.att.effect.toLowerCase();

			action.proceedImmediately = a.has.proceedImmediately;

			if (Reflect.fields(action).length > 0)
				actions.push(action);
		}

		trace('Pushed ${actions.length} actions');
	}

	function addPortrait(portrait:String, library:String)
	{
		if (!portraits.exists(portrait))
		{
			var _portrait = new DialoguePortrait(portrait, library);
			add(_portrait);
			_portrait.visible = false;
			portraits[portrait] = _portrait;
		}
	}
}
