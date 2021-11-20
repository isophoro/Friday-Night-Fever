package;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;

enum Subtitle
{
    START(step:Int, text:String);
    END(step:Int);
}

typedef SubtitleJSON = {
    var text:String;
    var startStep:Int;
    var endStep:Int;
}

class Subtitles extends FlxText
{
    public var array:Array<Subtitle> = [];

    public function new(Y:Float, json:Array<SubtitleJSON>)
    {
        super(0,Y, flixel.FlxG.width * 0.8);
        setFormat('Plunge', 28, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        borderSize = 1.4;

        for(i in json)
        {
            array.push(START(i.startStep, i.text));
            array.push(END(i.endStep));
        }
    }

    public function stepHit(curStep:Int)
    {
        if (array[0] != null)
        {
            // this is so messy i aint gonna even lie
            switch(array[0])
            {
                case START(step, string):
                    if(curStep != step)
                        return;
    
                    trace('Subtitle Starting : $string (Step $step)');
                    text = string;
    
                    alpha = 0;
                    FlxTween.tween(this, {alpha: 1}, 0.32, { type: ONESHOT });
                    
                    screenCenter(X);
                    array.shift();
                case END(step):
                    if(curStep != step)
                        return;
    
                    trace('Subtitle Ending (Step $step)');
    
                    if(array[1] != null)
                    {
                        switch(array[1])
                        {
                            case START(_step, str):
                                if (curStep + 6 < _step)
                                    FlxTween.tween(this, {alpha: 0}, 0.32, { type: ONESHOT });
                            case END(_step): 
                                trace('unexpected end step >:((( (at $_step)');
                                array.shift();
                        }
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