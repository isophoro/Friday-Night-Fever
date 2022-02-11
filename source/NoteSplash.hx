package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
    public function new(X:Float, Y:Float, direction:Int)
    {
        super(X,Y);
        scale.set(1.08, 1.08);
        antialiasing = true;
        alpha = 0.69;

        frames = Paths.getSparrowAtlas('notesplash');
        animation.addByPrefix('idle', 'notesplash', 36, false);

        updateHitbox();
        if(direction == 0 || direction == 3)
            offset.set(0.291 * width, 0.315 * height);
        else
            offset.set(0.33 * width, 0.315 * height);

        animation.play('idle');

        animation.finishCallback = function(t){
			kill();
		}
    }
}