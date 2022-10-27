package sprites;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class PopupState extends MusicBeatSubstate
{
    public var instance:String = '';
    public var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    public var text:FlxText = new FlxText(0, 0, 0, "", 24);

    public function new(instance:String)
    {
        this.instance = instance;
        super();

        if (FlxG.save.data.popups.contains(instance))
        {
            onAccept();
            return;
        }
        else
            FlxG.save.data.popups.push(instance);

        black.alpha = 0;
        black.scrollFactor.set();
        add(black);

        FlxTween.tween(black, {alpha:0.65}, 0.5, {onComplete: (twn) -> {
            add(text);
            
            switch (instance)
            {
                case 'dialogue':
                    text.text = "Hey!\n\n\nInsert pretty cool placeholder text about being able to make dialogue shorter here.\n\n\n\nPress ENTER to proceed\nPress ESCAPE to go to the OPTIONS menu.";
            }
            text.alignment = CENTER;
            text.updateHitbox();
            text.screenCenter();
        }});
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (black.alpha == 0.65)
        {
            if (controls.ACCEPT)
            {
                onAccept();
            }

            if (controls.BACK)
            {
                onBack();
            }
        }
    }

    public function onAccept()
    {
        switch(instance)
        {
            case 'dialogue': FlxG.switchState(new StoryMenuState());
        }
    }

    public function onBack()
    {
        switch(instance)
        {
            case 'dialogue': FlxG.switchState(new options.OptionsState());
        }
    }
}