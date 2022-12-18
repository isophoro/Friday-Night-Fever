package;

import Controls.KeyboardScheme;
import GameJolt;
import flash.display.DisplayObject;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	public static var alert:FlxText;

	var curSelected:InteractHitbox = null;
	var interactables:FlxTypedGroup<InteractHitbox> = new FlxTypedGroup<InteractHitbox>();
	var order:Array<InteractHitbox> = [];

	var hand:FlxSprite;

	var allowInput:Bool = false;

	override function create()
	{
		super.create();

		persistentUpdate = persistentDraw = true;

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var tunnelBG:MenuBG = new MenuBG("newMain/subway_bg_2", 0, -12, 0.7);
		add(tunnelBG);

		var train = new Interactable('newMain/trainmenu', 150, 75, 0.66, 'Train notselected', 'Train selected', new InteractHitbox(480, 205, 165, 280),
			[0, 42]);
		train.animation.addByPrefix('come', 'Train come', 24, false);
		train.animation.play('come');
		addInteractable(train);

		train.animation.finishCallback = function(anim)
		{
			train.animation.play('idle');
			allowInput = true;
			train.animation.finishCallback = null;
		}

		var mainBG:MenuBG = new MenuBG("newMain/subway_bg", 0, -12, 0.7);
		add(mainBG);

		var options = new Interactable('newMain/options', 915.5, 580.55, 0.7, 'options notselected', 'options selected',
			new InteractHitbox(915.5, 580.55, 365, 105), [0, 34]);
		addInteractable(options);

		var credits = new Interactable('newMain/credits', -10, 45, 0.7, 'credits notselected', 'credits selected', new InteractHitbox(40, 175, 225, 525),
			[216, 172], true, "newMain/creditstext", "credits text", [300, 140]);
		addInteractable(credits);

		var freeplay = new Interactable('newMain/freeplay', 1100, 160, 0.7, 'Freeplay not selected', 'Freeplay selected',
			new InteractHitbox(1100, 160, 145, 225), [256, 170]);
		freeplay.callback = FlxG.switchState.bind(new SelectingSongState());
		addInteractable(freeplay);

		var boombox = new Interactable('newMain/boombox', 779, 433, 0.7, 'boombox not selected', 'boombox selected', new InteractHitbox(779, 433, 165, 135),
			[0, 5], true, "newMain/boomboxtext", "boombox text", [639, 520]);
		addInteractable(boombox);

		var costumes = new Interactable('newMain/costumes', 505, 580, 0.7, 'costume notselected', 'costume selected', new InteractHitbox(505, 580, 240, 115),
			[83, 102]);
		addInteractable(costumes);

		var extras = new Interactable('newMain/extra', 839, 210, 0.7, 'extras notselected', 'extras selected', new InteractHitbox(839, 210, 150, 175),
			[258, 258], true, "newMain/extratext", "extra text", [990, 190], 0.23);
		addInteractable(extras);

		var versionShit:FlxText = new FlxText(0, 0, 0, 'Friday Night Fever ${Application.current.meta.get("version")}', 12);
		versionShit.setFormat("Plunge", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.setPosition(FlxG.width - versionShit.width - 10, FlxG.height - versionShit.height - 10);
		versionShit.antialiasing = true;
		versionShit.alpha = 0.38;
		add(versionShit);

		hand = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
		hand.frames = Paths.getSparrowAtlas('newMain/cursor');
		hand.animation.addByPrefix('idle', 'cursor nonselect', 0);
		hand.animation.addByPrefix('select', 'cursor select', 0);
		hand.animation.addByPrefix('qidle', 'cursor qnonselect', 0);
		hand.animation.addByPrefix('qselect', 'cursor qselect', 0);
		hand.animation.play('idle');
		hand.setGraphicSize(Std.int(hand.width / 1.5));
		hand.antialiasing = true;
		hand.updateHitbox();
		add(hand);

		order = [
			credits.hitbox,
			train.hitbox,
			costumes.hitbox,
			boombox.hitbox,
			extras.hitbox,
			options.hitbox,
			freeplay.hitbox
		];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justMoved)
			hand.setPosition(FlxG.mouse.x, FlxG.mouse.y);

		if (controls.LEFT_P)
		{
			var index = curSelected == null ? 0 : order.indexOf(curSelected);

			if (curSelected != null)
				onMouseLeave(order[index]);

			index--;
			if (index < 0)
				index = order.length - 1;

			hand.setPosition(order[index].x + (order[index].width / 2), order[index].y + (order[index].height / 2));
			FlxG.stage.application.window.warpMouse(Std.int(hand.x), Std.int(hand.y));
			onMouseHover(order[index]);
		}
		else if (controls.RIGHT_P)
		{
			var index = curSelected == null ? -1 : order.indexOf(curSelected);

			if (curSelected != null)
				onMouseLeave(order[index]);

			index++;
			if (index >= order.length)
				index = 0;

			hand.setPosition(order[index].x + (order[index].width / 2), order[index].y + (order[index].height / 2));
			FlxG.stage.application.window.warpMouse(Std.int(hand.x), Std.int(hand.y));
			onMouseHover(order[index]);
		}

		if (FlxG.mouse.pressed || FlxG.keys.anyPressed([ENTER, SPACE]))
		{
			hand.animation.play(curSelected != null ? 'qselect' : 'select');
			hand.offset.set(0, 8);

			if (curSelected != null && !FlxG.mouse.pressed && FlxG.keys.anyJustPressed([ENTER, SPACE]))
			{
				onMouseClick(order[order.indexOf(curSelected)]);
			}
		}
		else
		{
			hand.animation.play(curSelected != null ? 'qidle' : 'idle');
			hand.offset.set(0, 0);
		}
	}

	function addInteractable(item:Interactable)
	{
		add(item);

		if (item.text != null)
			add(item.text);

		interactables.add(item.hitbox);
		FlxMouseEventManager.add(cast item.hitbox, onMouseClick, onMouseUp, onMouseHover, onMouseLeave);
	}

	function onMouseClick(item:InteractHitbox)
	{
		if (!allowInput)
			return;

		if (item.parent.callback != null)
		{
			allowInput = false;
			item.parent.callback();
		}
	}

	function onMouseUp(item:InteractHitbox)
	{
		if (!allowInput)
			return;
	}

	function onMouseHover(item:InteractHitbox)
	{
		if (!allowInput)
			return;

		if (item.parent.animation.curAnim.name != "selected")
		{
			item.parent.playAnim("selected");
			curSelected = item;
		}
	}

	function onMouseLeave(item:InteractHitbox)
	{
		if (!allowInput)
			return;

		if (item.parent.animation.curAnim.name != "idle")
		{
			item.parent.playAnim("idle");
			curSelected = null;
		}
	}
}

class MenuBG extends FlxSprite
{
	public function new(img:String, x:Float, y:Float, scale:Float = 1)
	{
		super(x, y);
		antialiasing = true;

		loadGraphic(Paths.image(img));

		if (scale != 1)
		{
			origin.set(0, 0);
			this.scale.scale(scale); // scale the scale by scale
		}
	}
}

class Interactable extends FlxSprite
{
	public var hitbox:InteractHitbox;
	public var text:FlxSprite;
	public var callback:Void->Void;

	var selectOffset:Array<Int> = [0, 0];

	// sorry to anyone who wants to deal with the parameter mess that i made lmao
	// this was made in a rush but if i were to redo it i would just use an anontype to declare variables
	public function new(img:String, x:Float, y:Float, scale:Float = 1, unselectAnim:String = "", selectAnim:String = "", ?hitbox:InteractHitbox,
			?selectOffset:Array<Int>, loopSelect:Bool = false, ?textImg:String, ?textAnim:String, ?textLoc:Array<Int>, ?textScale:Float = 1)
	{
		super(x, y);
		antialiasing = true;

		frames = Paths.getSparrowAtlas(img);
		animation.addByPrefix("idle", unselectAnim, 24, true);
		animation.addByPrefix("selected", selectAnim, 24, loopSelect);
		animation.play("idle");

		this.hitbox = hitbox;
		hitbox.parent = this;

		if (scale != 1)
		{
			origin.set(0, 0);
			this.scale.scale(scale); // scale the scale by scale
		}

		if (selectOffset != null)
			this.selectOffset = selectOffset;

		if (textLoc != null)
		{
			text = new FlxSprite(textLoc[0], textLoc[1]);
			text.frames = Paths.getSparrowAtlas(textImg);
			text.animation.addByPrefix("anim", textAnim, 24, false);
			text.animation.play("anim");
			text.antialiasing = true;
			text.visible = false;
			text.ID = 420; // debug purposing

			text.origin.set(0, 0);
			text.scale.scale(textScale == 1 ? scale : textScale);
		}
	}

	public function playAnim(name:String)
	{
		animation.play(name, true);
		if (name == "selected")
		{
			offset.set(selectOffset[0], selectOffset[1]);
			if (text != null)
			{
				text.visible = true;
				text.animation.play("anim", true);
			}
		}
		else
		{
			offset.set(0, 0);
			if (text != null)
				text.visible = false;
		}
	}
}

class InteractHitbox extends FlxObject
{
	public var parent:Interactable;
}
