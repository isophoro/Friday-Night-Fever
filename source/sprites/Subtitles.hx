package sprites;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;

typedef SubtitleJSON = {
    var text:String;
    var startStep:Int;
    var endStep:Int;
}

class Subtitles extends FlxText
{
    public var array:Array<SubtitleJSON> = [];

    public function new(Y:Float, json:Array<SubtitleJSON>)
    {
        super(0,Y, flixel.FlxG.width * 0.8);
        array = json;
        setFormat('Plunge', 28, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        borderSize = 1.4;
        antialiasing = true;
    }

    public function stepHit(curStep:Int)
    {
        if (array[0] != null)
        {
            if (array[0].startStep == curStep)
            {
                text = array[0].text;
                screenCenter(X);

                alpha = 0;
                FlxTween.tween(this, {alpha: 1}, 0.32, { type: ONESHOT });
            }
            else if (array[0].endStep == curStep)
            {
                if(array[1] != null)
                {
                    if (curStep + 6 < array[1].startStep)
                        FlxTween.tween(this, {alpha: 0}, 0.32, { type: ONESHOT });
                }
                else
                {
                    FlxTween.tween(this, {alpha: 0}, 0.32, { type: ONESHOT });
                }
                array.shift();
            }
        }
    }
}