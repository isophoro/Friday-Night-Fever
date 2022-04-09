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

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class Recap extends MusicBeatState
{
    public var dialogue:Array<String> = [];
    public static var inRecap:Bool = false;

    override function create()
    {
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Week 7 RECAP", null);
		#end


        super.create();

        inRecap = true;
        var dialogueString:String = 'recap';
        dialogue = CoolUtil.coolTextFile(Paths.txt(dialogueString));

        var doof:DialogueBox = new DialogueBox(false, dialogue);
        doof.finishThing = () -> {
            inRecap = false;
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

