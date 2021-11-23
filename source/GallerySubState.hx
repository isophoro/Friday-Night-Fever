package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import openfl.display.BitmapData;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class GallerySubState extends MusicBeatSubstate
{
    var bg:FlxSprite;
    var theGoods:Array<Dynamic> = [];
    var image:FlxSprite;

    public function new (img:BitmapData, scale:FlxPoint)
    {
        super();
        theGoods.push(img);
        theGoods.push(scale.x);
        theGoods.push(scale.y);
    }

    override function create()
    {
        super.create();

        bg = new FlxSprite().makeGraphic(1280,720, FlxColor.BLACK);
        bg.alpha = 0;
        add(bg);

        image = new FlxSprite().loadGraphic(theGoods[0]);
        image.scale.set(theGoods[1], theGoods[2]);
        image.visible = false;
        add(image);

        FlxTween.tween(bg, {alpha:0.7}, 0.65, {onComplete: (twn) -> {
            image.screenCenter();
            image.visible = true;
        }});
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        FlxG.mouse.visible = true;

        if (FlxG.mouse.overlaps(image) && FlxG.mouse.pressed)
        {
            image.setPosition(FlxG.mouse.x - (image.width / 2), FlxG.mouse.y - (image.height / 2));

            if (FlxG.mouse.wheel > 0)
            {
                if (image.scale.x < 5)
                {
                    var cool = image.scale.x + (elapsed * 10);
                    image.scale.set(cool, cool);
                }
            }
    
            if (FlxG.mouse.wheel < 0)
            {
                if(image.scale.x > 0.10)
                {
                    var cool = image.scale.x - (elapsed * 10);
                    image.scale.set(cool, cool);
                }
            }
        }

        if (controls.BACK && bg.alpha == 0.7)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            image.visible = false;
            FlxTween.tween(bg, {alpha: 0}, 0.65, {onComplete: (twn) -> {
                close();
            }});
        }
    }
}