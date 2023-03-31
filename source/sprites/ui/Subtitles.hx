package sprites.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.interfaces.IStepReceiver;

typedef SubtitleJSON =
{
	var text:String;
	var startStep:Int;
	var endStep:Int;
}

class Subtitles extends FlxTypedSpriteGroup<FlxSprite> implements IStepReceiver
{
	public var array:Array<SubtitleJSON> = [];

	var textBG:FlxSprite = new FlxSprite().makeGraphic(10, 10, FlxColor.BLACK);
	var text:FlxText = new FlxText();

	public function new(json:Array<SubtitleJSON>, y:Float = 0)
	{
		super(0, y);
		array = json;

		textBG.origin.y = 0;
		add(textBG);
		textBG.alpha = 0;

		text.setFormat('VCR OSD Mono', 28, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
		text.borderSize = 1.4;
		text.antialiasing = true;
		text.alpha = 0;
		add(text);
	}

	override function set_y(y:Float):Float
	{
		textBG.y = text.y = y;
		return this.y = y;
	}

	public function stepHit(curStep:Int)
	{
		if (array[0] != null)
		{
			if (array[0].startStep == curStep)
			{
				text.text = array[0].text;
				text.screenCenter(X);

				textBG.screenCenter(X);
				textBG.scale.set((text.width / textBG.width) * 1.03, text.height / textBG.height);

				FlxTween.tween(textBG, {alpha: 0.6}, 0.32, {type: ONESHOT});
				FlxTween.tween(text, {alpha: 1}, 0.32, {type: ONESHOT});
			}

			if (array[0].endStep == curStep)
			{
				if (array[1] == null || curStep + 6 < array[1].startStep)
					for (i in [text, textBG])
						FlxTween.tween(i, {alpha: 0}, 0.32, {type: ONESHOT});
				array.shift();
			}
		}
	}
}
