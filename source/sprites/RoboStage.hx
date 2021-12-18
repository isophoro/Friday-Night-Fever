package sprites;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;

class RoboStage extends FlxTypedSpriteGroup<FlxSprite>
{
    public var stages:Map<String, CoolStage> = [];
    public var curStage:String = 'default';
    private var instance:PlayState;

    public function new(x:Float, y:Float)
    {
        super(x,y);
        instance = PlayState.instance;

        var bg:FlxSprite = new FlxSprite(-1348, -844).loadGraphic(Paths.image('roboCesar'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        stages['default'] = new CoolStage([bg], null, [], 0.4);

        if (PlayState.SONG.song == 'Loaded')
        {
            // whitty shit
            var whittyBG:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/alleyway'));
            whittyBG.antialiasing = true;
            whittyBG.scrollFactor.set(0.9, 0.9);
            whittyBG.scale.set(1.25, 1.25);
            stages['whitty'] = new CoolStage([whittyBG], null, [], 0.55);

            // mako shit
            var makobg:FlxSprite = new FlxSprite(-215, -90).loadGraphic(Paths.image('philly/sky', 'week3'));
            makobg.scrollFactor.set(0.1, 0.1);
            makobg.scale.set(1.25, 1.25);

            var makobg2:FlxSprite = new FlxSprite(makobg.x, makobg.y).loadGraphic(Paths.image('philly/bg', 'week3'));
            makobg2.scale = makobg.scale;

            stages['mako'] = new CoolStage([makobg, makobg2], null, ["boyfriend" => [940.2, 482.3], "gf" => [175, 149], "dad" => [-324.7, 365.3]], 0.67);

            // matt shit
            var mattbg:FlxSprite = new FlxSprite(-348, -230).loadGraphic(Paths.image('roboStage/matt_bg'));
            mattbg.antialiasing = true;
            mattbg.scrollFactor.set(0.9, 0.9);
            mattbg.scale.set(1.05, 1.05);

            var mattfg:FlxSprite = new FlxSprite(mattbg.x, mattbg.y).loadGraphic(Paths.image('roboStage/matt_foreground'));
            mattfg.antialiasing = true;
            mattfg.scrollFactor.set(0.9, 0.9);
            mattfg.scale.set(1.05, 1.05);

            var mattcrowd:FlxSprite = new FlxSprite(mattbg.x, mattbg.y);
            mattcrowd.frames = Paths.getSparrowAtlas('roboStage/matt_crowd');
            mattcrowd.animation.addByPrefix('bop', 'robo crowd hehe', 24, false);
            mattcrowd.antialiasing = true;
            mattcrowd.scrollFactor.set(0.43, 0.43);

            var spotlight:FlxSprite = new FlxSprite(mattbg.x, mattbg.y).loadGraphic(Paths.image('roboStage/matt_spotlight'));
            spotlight.antialiasing = true;
            spotlight.scrollFactor.set(0.73, 0.73);

            var dumboffset:Int = 95;
            stages['matt'] = new CoolStage([mattbg, mattcrowd, mattfg], [spotlight], [
                "boyfriend" => [940.2 - dumboffset, 482.3 - 150], 
                "gf" => [415 - dumboffset, 149 - 70], 
                "dad" => [60.7 - dumboffset, 365.3 - 150]
            ], 0.7);

            //zardy shit
            dumboffset = 350;
            var offsetY:Int = 150;
            var zardybg:FlxSprite = new FlxSprite(164.4 - dumboffset, 0 - offsetY).loadGraphic(Paths.image('roboStage/zardy_bg'));
            zardybg.antialiasing = true;
            zardybg.scrollFactor.set(0.9, 0.9);

            var zardytown:FlxSprite = new FlxSprite(161.65 - dumboffset, 1.1 - offsetY).loadGraphic(Paths.image('roboStage/zardy_fevertown'));
            zardytown.antialiasing = true;
            zardytown.scrollFactor.set(0.8, 0.8);

            var zardyforeground:FlxSprite = new FlxSprite(161.65 - dumboffset, 6.15 - offsetY).loadGraphic(Paths.image('roboStage/zardy_foreground'));
            zardyforeground.antialiasing = true;
            zardyforeground.scrollFactor.set(0.9, 0.9);

            stages['zardy'] = new CoolStage([zardybg, zardytown, zardyforeground], null, 
                [
                    "boyfriend" => [1366.3 - (dumboffset), 525.8 - offsetY], 
                    "gf" => [810.9 - (dumboffset * 1.275), 244.4 - offsetY], 
                    "dad" => [492.5 - (dumboffset * 1.765), 430.8 - offsetY]
                ], 0.715);

        }

        switchStage('default');
    }

    public function switchStage(stage:String)
    {
        for (i in members)
        {
            if (i != null)
                remove(i);
            else
                trace('null object????');
        }

        for (i in instance.roboForeground.members)
        {
            if (i == null) continue;

            i.kill();
           instance.roboForeground.remove(i);
        }

        for (i in stages[stage].sprites)
        {
            add(i);
        }

        for (i in stages[stage].fgSprites)
        {
            instance.roboForeground.add(i);
        }

        for (i in stages[stage].positoning.keys())
        {
            Reflect.setField(Reflect.field(PlayState, i), "x", stages[stage].positoning[i][0]);
            Reflect.setField(Reflect.field(PlayState, i), "y", stages[stage].positoning[i][1]);
        }

        instance.defaultCamZoom = stages[stage].camZoom;

        if (curStage == stage) return;

        curStage = stage;
        instance.camGame.flash(FlxColor.WHITE, 0.45);
    }

    public function beatHit(curBeat:Int)
    {
        switch (curBeat)
        {
            case 32:
                instance.camZooming = true;
                instance.disableCamera = true;
                switchStage('zardy');
                instance.camFollow.setPosition(PlayState.gf.getGraphicMidpoint().x + 30, PlayState.gf.getGraphicMidpoint().y - 45);
            case 128:
                instance.camZooming = true;
                instance.disableCamera = false;
                switchStage('whitty');
            case 496:
                instance.camZooming = true;
                instance.disableCamera = true;
                instance.camFollow.setPosition(PlayState.gf.getGraphicMidpoint().x + 30, PlayState.gf.getGraphicMidpoint().y - 130);
                switchStage('matt');
        }

        for (i in members)
        {
            if (i != null && i.animation.getByName('bop') != null)
                i.animation.play('bop', true);
        }
    }
}

class CoolStage
{
    public var sprites:Array<FlxSprite> = [];
    public var fgSprites:Array<FlxSprite> = [];

    public var camZoom:Float = 0.4;
    public var positoning:Map<String, Array<Float>> = [];

    public function new(sprs:Array<FlxSprite>, ?fgSprites:Array<FlxSprite>, ?positoning:Map<String, Array<Float>>, camZoom:Float)
    {
        sprites = sprs;
        this.positoning = positoning;

        var coolmap:Map<String, Array<Float>> = [
            "boyfriend" => [1085.2, 482.3],
            "gf" => [245, 149],
            "dad" => [-354.7, 365.3]
        ];

        for (k => v in coolmap)
        {
            if (!this.positoning.exists(k))
            {
                this.positoning.set(k, v);
            }
        }

        this.camZoom = camZoom;
        this.fgSprites = fgSprites == null ? [] : fgSprites;
    }
}