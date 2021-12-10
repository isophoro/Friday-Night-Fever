package weeks;

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
            //
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