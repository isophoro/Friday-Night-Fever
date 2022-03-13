package;

import flixel.tweens.FlxEase;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.tweens.FlxTween;
import openfl.Lib;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKey;

using StringTools;

class Recap extends MusicBeatState
{
    public var dialogue:Array<String> = [];

    override function create()
    {
        super.create();

        var dialogueString:String = 'recap';
        dialogue = CoolUtil.coolTextFile(Paths.txt(dialogueString));

        var doof:DialogueBox = new DialogueBox(false, dialogue);
        doof.finishThing = () -> {
            LoadingState.loadAndSwitchState(new PlayState());
        }

        recappslsss(doof);
    }

    function recappslsss(?dialogueBox:DialogueBox):Void 
    {
        add(dialogueBox);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}

