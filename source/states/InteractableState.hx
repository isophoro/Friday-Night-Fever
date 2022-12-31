package states;

/**
 * [Handles the main logic for the interactable menus such as the Main Menu and Story Mode Menu]
 * @author Rifxii
 */
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.system.FlxSound;

class InteractableState extends MusicBeatState
{
	public var allowInput:Bool = false;
	public var curSelected:InteractHitbox = null;

	public var interactables:FlxTypedGroup<InteractHitbox> = new FlxTypedGroup<InteractHitbox>();
	public var order:Array<InteractHitbox> = [];
	public var hand:FlxSprite;

	override function create()
	{
		super.create();

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
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justMoved)
			hand.setPosition(FlxG.mouse.x, FlxG.mouse.y);

		if (allowInput && controls.LEFT_P)
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
		else if (allowInput && controls.RIGHT_P)
		{
			var index = curSelected == null ? -1 : order.indexOf(curSelected);

			if (curSelected != null)
				onMouseLeave(order[index]);

			index++;
			if (index >= order.length)
				index = 0;

			hand.setPosition(order[index].x + (order[index].width / 2) - (hand.width / 2), order[index].y + (order[index].height / 2) - (hand.height / 2));
			FlxG.stage.application.window.warpMouse(Std.int(hand.x), Std.int(hand.y));
			onMouseHover(order[index]);
		}

		if (FlxG.mouse.pressed || FlxG.keys.anyPressed([ENTER, SPACE]))
		{
			hand.animation.play(curSelected != null ? 'qselect' : 'select');
			hand.offset.y = curSelected != null ? 34 : 8;

			if (curSelected != null && !FlxG.mouse.pressed && FlxG.keys.anyJustPressed([ENTER, SPACE]))
			{
				onMouseClick(order[order.indexOf(curSelected)]);
			}
		}
		else
		{
			hand.animation.play(curSelected != null ? 'qidle' : 'idle');
			hand.offset.y = curSelected != null ? 24 : 0;
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

		if (item.parent.animation.name != 'come' && item.parent.callback != null)
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

		if (item.parent.animation.curAnim.name != "selected" && item.parent.animation.curAnim.name == "idle")
		{
			item.parent.playAnim("selected");
			curSelected = item;

			if (item.parent.sound != null)
				FlxG.sound.play(Paths.sound('menu/${item.parent.sound}-interact'));
		}
	}

	function onMouseLeave(item:InteractHitbox)
	{
		if (item.parent.animation.curAnim.name != "idle" && item.parent.animation.name != 'come')
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
	public var sound:String = "general";

	var selectOffset:Array<Float> = [0, 0];

	// sorry to anyone who wants to deal with the parameter mess that i made lmao
	// this was made in a rush but if i were to redo it i would just use an anontype to declare variables
	public function new(img:String, x:Float, y:Float, scale:Float = 1, unselectAnim:String = "", selectAnim:String = "", ?hitbox:InteractHitbox,
			?selectOffset:Array<Float>, loopSelect:Bool = false, ?textImg:String, ?textAnim:String, ?textLoc:Array<Int>, ?textScale:Float = 1)
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
