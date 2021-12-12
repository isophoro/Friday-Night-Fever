package weeks;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;

class RoboStage extends FlxTypedSpriteGroup<FlxSprite>
{
    public var stages:Map<String, CoolStage> = [];

    public function new(x:Float, y:Float)
    {
        super(x,y);

        var bg:FlxSprite = new FlxSprite(-1348, -844).loadGraphic(Paths.image('roboCesar'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        stages['default'] = new CoolStage([bg], [
            "boyfriend" => [1085.2, 482.3],
            "gf" => [227, 149],
            "dad" => [-354.7, 365.3]
        ], 0.4);

        if (PlayState.SONG.song == 'Loaded')
        {
            // whitty shit
            var whittyBG:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/alleyway'));
            whittyBG.antialiasing = true;
            whittyBG.scrollFactor.set(0.9, 0.9);
            whittyBG.scale.set(1.25, 1.25);
            stages['whitty'] = new CoolStage([whittyBG], [], 0.55);
        }

        switchStage('default');
    }

    public function switchStage(stage:String)
    {
        for (i in members)
        {
            remove(i);
        }

        for (i in stages[stage].sprites)
        {
            add(i);
        }

        for (i in stages[stage].positoning.keys())
        {
            Reflect.setField(Reflect.field(PlayState, i), "x", stages[stage].positoning[i][0]);
            Reflect.setField(Reflect.field(PlayState, i), "y", stages[stage].positoning[i][1]);
        }

        PlayState.instance.defaultCamZoom = stages[stage].camZoom;
    }

    public function beatHit(curBeat:Int)
    {
        switch (curBeat)
        {
            case 128:
                PlayState.instance.camGame.flash(FlxColor.WHITE, 0.45);
                switchStage('whitty');
                PlayState.instance.camZooming = true;
        }
    }
}

class CoolStage
{
    public var sprites:Array<FlxSprite> = [];
    public var camZoom:Float = 0.4;
    public var positoning:Map<String, Array<Float>> = [];

    public function new(sprs:Array<FlxSprite>, ?positoning:Map<String, Array<Float>>, camZoom:Float)
    {
        sprites = sprs;
        this.positoning = positoning;
        this.camZoom = camZoom;
    }
}