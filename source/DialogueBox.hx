package;

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

using StringTools;

typedef DialogueAction =
{
	?msg:String,
	?portrait:String,
	?portraits:Array<String>,
	?emotion:String,
	?side:Null<FlxDirection>,
	?fillBG:Null<FlxColor>,
	?setBG:String,
	?effect:String
}

class DialoguePortrait extends FlxSprite
{
	public var character:String = "";

	public function new(character:String)
	{
		super(0, -90);
		antialiasing = true;
		this.character = character;

		frames = Paths.getSparrowAtlas('dialogue/${character.toLowerCase()}', 'shared');
		for (i in frames.frames)
		{
			var name = i.name.replace('${character.toLowerCase()} ', '');
			if (!animation.exists(name))
			{
				animation.addByPrefix(name, i.name, 0);
			}
		}

		if (animation.exists("neutral"))
			animation.play("neutral");
	}

	public function jump()
	{
		FlxTween.tween(this, {"scale.y": 1.025, y: y - 18}, 0.05, {
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(this, {"scale.y": 1, y: y + 18}, 0.04, {ease: FlxEase.elasticInOut});
			}
		});
	}
}

class DialogueBox extends FlxTypedSpriteGroup<FlxSprite>
{
	var bg:FlxSprite;
	var box:FlxSprite;
	var text:FlxTypeText;

	var actions:Array<DialogueAction> = [];
	var portraits:Map<String, DialoguePortrait> = [];
	var curLeft:DialoguePortrait;
	var curRight:DialoguePortrait;

	var dialogueStarted:Bool = false;

	public var finishCallback:Void->Void;

	public function new(?dialogue:String)
	{
		super();

		bg = new FlxSprite();
		bg.antialiasing = true;
		bg.visible = false;
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
		text.delay = 0.04;
		text.setTypingVariation(0.5, true);
		add(text);

		box.y = FlxG.height;
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

		if (FlxG.keys.anyJustPressed([ENTER, SPACE]))
		{
			@:privateAccess
			if (!text._typing)
				startDialogue();
			else
				text.skip();
		}
	}

	function startDialogue()
	{
		if (actions[0] == null)
		{
			return endDialogue();
		}

		var action = actions[0];
		actions.shift();

		if (action.fillBG != null)
		{
			bg.visible = true;
			bg.makeGraphic(1280, 720, action.fillBG);
		}
		else if (action.setBG != null)
		{
			bg.visible = action.setBG.length > 0;
			if (action.setBG.length > 0)
				bg.loadGraphic(Paths.image(action.setBG, "shared"));
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

		if (action.msg != null)
		{
			text.resetText(action.msg);
			text.start(0.04, true);

			@:privateAccess
			{
				text.sounds[0].volume = 0.35;
			}
		}
		else if (actions[0] != null)
			startDialogue();
	}

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

				if (curLeft != null)
					curLeft.color = 0xFF828282;
				if (curRight != null)
					curRight.color = 0xFFFFFFFF;

				if (curRight != portrait)
				{
					portrait.setPosition(box.x + box.width - portrait.width + 40, -90);
					FlxTween.tween(portrait, {x: portrait.x - 40}, 0.18);
					portrait.alpha = 0;
					FlxTween.tween(portrait, {alpha: 1}, 0.13);
				}

				portrait.flipX = !portrait.character.startsWith("fever");

				curRight = portrait;
				curRight.visible = true;
			default:
				if (curLeft != null && curLeft != portrait)
					curLeft.visible = false;

				if (curRight != null)
					curRight.color = 0xFF828282;
				if (curLeft != null)
					curLeft.color = 0xFFFFFFFF;

				if (curLeft != portrait)
				{
					portrait.setPosition(box.x - 40, -90);
					FlxTween.tween(portrait, {x: portrait.x + 40}, 0.18);
					portrait.alpha = 0;
					FlxTween.tween(portrait, {alpha: 1}, 0.13);
				}

				portrait.flipX = portrait.character.startsWith("fever");

				curLeft = portrait;
				curLeft.visible = true;
				curLeft.setPosition(box.x, -90);
		}

		if (action.emotion != null)
			portrait.animation.play(action.emotion);
	}

	function endDialogue()
	{
		dialogueStarted = false;

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
		var xml = Xml.parse(openfl.utils.Assets.getText(rawDialogue));
		var data:Access = new Access(xml.firstElement());
		for (a in data.nodes.action)
		{
			var action:DialogueAction = {};

			if (a.has.portrait || a.has.portraits)
			{
				if (a.has.portraits)
				{
					var s = a.att.portraits.split(",");
					for (i in s)
						addPortrait(i);

					action.portraits = s;
				}
				else
				{
					var portrait = a.att.portrait;
					action.portrait = portrait;
					addPortrait(portrait);

					if (a.has.side)
						action.side = a.att.side.toLowerCase().charAt(0) == "r" ? RIGHT : LEFT;

					if (a.has.emotion)
						action.emotion = a.att.emotion.toLowerCase();
				}
			}

			if (a.has.msg)
				action.msg = a.att.msg;

			if (a.has.fillBG)
				action.fillBG = FlxColor.fromString(a.att.fillBG);
			else if (a.has.setBG)
				action.setBG = a.att.setBG;

			if (a.has.effect)
				action.effect = a.att.effect.toLowerCase();

			if (Reflect.fields(action).length > 0)
				actions.push(action);
		}

		trace('Pushed ${actions.length} actions');
	}

	function addPortrait(portrait:String)
	{
		if (!portraits.exists(portrait))
		{
			var _portrait = new DialoguePortrait(portrait);
			add(_portrait);
			_portrait.visible = false;
			portraits[portrait] = _portrait;
		}
	}
}
