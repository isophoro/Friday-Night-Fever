package options;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class Checkbox extends FlxSprite
{
    public var followText:FlxSpriteGroup;

    public function new(followText:FlxSpriteGroup)
    {
        super();
        this.followText = followText;

        antialiasing = true;
        frames = Paths.getSparrowAtlas("checkbox");
        animation.addByPrefix("selected", "Check Box Selected Static", 24, true);
        animation.addByPrefix("selecting", "Check Box selecting animation", 24, false);
        animation.addByPrefix("unselected", "Check Box unselected", 24, true);  
        animation.play("unselected");

        animation.finishCallback = (a) -> {
            if (a == "selecting")
            {
                animation.play("selected", true);
                centerOffsets();
                offset.x -= 12;
                offset.y -= 14;
            }
        }    

        scale.set(0.65, 0.65);
        updateHitbox();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (followText != null)
            setPosition(followText.x + followText.width + 20, followText.y + ((followText.height / 2) - this.height / 2));
    }
}