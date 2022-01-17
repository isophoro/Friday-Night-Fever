package sprites;

import openfl.display.BitmapData;
import flixel.FlxG;
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

            /*
            // mako shit
            var makobg:FlxSprite = new FlxSprite(-215, -90).loadGraphic(Paths.image('philly/sky', 'week3'));
            makobg.scrollFactor.set(0.1, 0.1);
            makobg.scale.set(1.25, 1.25);

            var makobg2:FlxSprite = new FlxSprite(makobg.x, makobg.y).loadGraphic(Paths.image('philly/bg', 'week3'));
            makobg2.scale = makobg.scale;

            stages['mako'] = new CoolStage([makobg, makobg2], null, ["boyfriend" => [940.2, 482.3], "gf" => [175, 149], "dad" => [-324.7, 365.3]], 0.67);
            */

            // matt shit
            var mattbg:FlxSprite = new FlxSprite(-370, -230).loadGraphic(Paths.image('roboStage/matt_bg'));
            mattbg.antialiasing = true;
            mattbg.scrollFactor.set(0.9, 0.9);
            mattbg.scale.set(1.05, 1.05);

            var mattfg:FlxSprite = new FlxSprite(mattbg.x, mattbg.y).loadGraphic(Paths.image('roboStage/matt_foreground'));
            mattfg.antialiasing = true;
            mattfg.scrollFactor.set(0.9, 0.9);
            mattfg.scale.set(1.05, 1.05);

            var mattcrowd:FlxSprite = new FlxSprite(mattbg.x - 50, mattbg.y);
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
                "dad" => [60.7 - dumboffset + (100), 365.3 - 150 - (50)] // 100 and 50 are for the new sprites
            ], 0.7);

            //zardy shit
            dumboffset = 365;
            var offsetY:Int = 200;
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
                    "dad" => [492.5 - (dumboffset * 1.765) + (100), 410.8 - offsetY - (50)]
                ], 0.715);

            // week 1
            var w1bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
            w1bg.antialiasing = true;

            var w1Front:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
            w1Front.antialiasing = true;
            w1Front.scale.set(1.35, 1.35);

            var w1Curtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
            w1Curtains.antialiasing = true;
            w1Curtains.scale.set(1.05, 1.05);

            stages['week1'] = new CoolStage([w1bg, w1Front, w1Curtains], null, [], 0.74, ["gf" => 1, "boyfriend" => 1, "dad" => 1]);

            // church
            var church:FlxSprite = new FlxSprite(-948, -779).loadGraphic(Paths.image('bg_taki'));
            church.antialiasing = true;

            stages['church'] = new CoolStage([church], null, [], 0.55, ["gf" => 1, "boyfriend" => 1, "dad" => 1]);

            // week 5
            var w5bg:FlxSprite = new FlxSprite(-706, -371).loadGraphic(Paths.image('christmas/first2songs', 'week5'));
            w5bg.antialiasing = true;
            w5bg.scrollFactor.set(0.9, 0.9);

            var crowd = new Crowd();
            crowd.setPosition(-519, 819);

            stages['week5'] = new CoolStage([w5bg], [crowd], [], 0.55, ["gf" => 1, "boyfriend" => 1, "dad" => 1]);
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

        for (ch => pos in stages[stage].positoning)
        {
            Reflect.setField(Reflect.field(instance, ch), "x", pos[0]);
            Reflect.setField(Reflect.field(instance, ch), "y", pos[1]);
        }

        for (ch => sc in stages[stage].scrolling)
        {
            // do not trust me near a computer ever again
            if (Reflect.field(instance, ch) != null)
                Reflect.callMethod(Reflect.field(Reflect.field(instance, ch), "scrollFactor"), Reflect.field(Reflect.field(Reflect.field(instance, ch), "scrollFactor"), "set"), [sc,sc]);
        }

        instance.defaultCamZoom = stages[stage].camZoom;

        if (curStage == stage) return;

        curStage = stage;
        instance.camGame.flash(FlxColor.WHITE, 0.45);
        instance.camZooming = true;
        instance.disableCamera = false;
    }

    public function beatHit(curBeat:Int)
    {
        switch (curBeat)
        {
            case 32:
                switchStage('zardy');
            case 128:
                switchStage('whitty');
            case 160 | 336 | 592:
                switchStage('default');
            case 224 | 560:
                switchStage('week1');
            case 256 | 432:
                switchStage('week5');
            case 400:
                switchStage('church');
            case 496:
                switchStage('matt');
                instance.disableCamera = true;
                instance.camFollow.setPosition(instance.gf.getGraphicMidpoint().x - 100, instance.gf.getGraphicMidpoint().y - 130);
                instance.camGame.focusOn(new FlxPoint(instance.camFollow.x, instance.camFollow.y));
                //instance.camGame.setPosition(instance.camFollow.x, instance.camFollow.y);
        }

        for (i in members)
        {
            if (i != null && i.animation.getByName('bop') != null)
                i.animation.play('bop', true);
        }

        for (i in instance.roboForeground)
        {
            if (i != null && i.animation.getByName('bop') != null)
                i.animation.play('bop', true);

            if (Reflect.field(i, 'beatHit') != null)
                Reflect.callMethod(i, Reflect.field(i, 'beatHit'), []);
        }
    }
}

class CoolStage
{
    public var sprites:Array<FlxSprite> = [];
    public var fgSprites:Array<FlxSprite> = [];

    public var camZoom:Float = 0.4;
    public var positoning:Map<String, Array<Float>> = [];
    public var gfScroll:Float = 0.9;
    public var scrolling:Map<String, Float> = [];

    public function new(sprs:Array<FlxSprite>, ?fgSprites:Array<FlxSprite>, ?positoning:Map<String, Array<Float>>, camZoom:Float, ?scrolls:Map<String, Float>)
    {
        sprites = sprs;
        this.positoning = positoning;

        if (scrolls != null)
            this.scrolling = scrolls;

        var coolmap:Map<String, Array<Float>> = [
            "boyfriend" => [1085.2, 482.3],
            "gf" => [245, 149],
            "dad" => [-354.7 + 100, 365.3 - 50]
        ];

        for (k => v in coolmap)
        {
            if (!this.positoning.exists(k))
            {
                this.positoning.set(k, v);
            }
        }

        for (k in coolmap.keys())
        {
            if (!scrolling.exists(k))
            {
                scrolling.set(k, 0.9);
            }
        }

        this.camZoom = camZoom;
        this.fgSprites = fgSprites == null ? [] : fgSprites;
    }
}