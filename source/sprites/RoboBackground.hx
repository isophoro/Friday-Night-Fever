package sprites;

import flixel.tweens.FlxTween;
import shaders.CRTShader;
import openfl.display.BitmapData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class RoboBackground
{
    public var stages:Map<String, RoboStage> = [];
    public var curStage:String = 'default';
    public var instance:PlayState;

    public var overrideBF:Character = null;
    public var overrideGF:Character = null;
    public var overrideDad:Character = null;

    private var tea:Character;
    private var taki:Character;

    var shader:CRTShader = new CRTShader();

    public function new() 
    {
        instance = PlayState.instance;

        var bg:FlxSprite = new FlxSprite(-1348, -844).loadGraphic(Paths.image('roboCesar'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);

        stages['default'] = new RoboStage([bg], [], [], [], 0.4);
        switchStage('default');

        instance.modchart.addRainCamEffect(shader);

        if (PlayState.SONG.song == 'Loaded')
        {
            taki = new Character(0, 0, "taki-gf");
            // ZARDY STAGE
            var dumboffset:Int = 95;

            dumboffset = 365;
            var offsetY:Int = 200;
            var zardybg:FlxSprite = new FlxSprite(164.4 - dumboffset, 0 - offsetY).loadGraphic(Paths.image('roboStage/zardy_bg'));
            zardybg.antialiasing = true;
            zardybg.scrollFactor.set(0.75, 0.3);

            var zardytown:FlxSprite = new FlxSprite(161.65 - dumboffset, 1.1 - offsetY).loadGraphic(Paths.image('roboStage/zardy_fevertown'));
            zardytown.antialiasing = true;
            zardytown.scrollFactor.set(0.6, 1);

            var zardyforeground:FlxSprite = new FlxSprite(161.65 - dumboffset, 6.15 - offsetY).loadGraphic(Paths.image('roboStage/zardy_foreground'));
            zardyforeground.antialiasing = true;
            zardyforeground.scrollFactor.set(1, 1);

            stages['zardy'] = new RoboStage([zardybg, zardytown, zardyforeground], [],[
                "boyfriend" => [1366.3 - (dumboffset), 525.8 - offsetY], 
                "gf" => [810.9 - (dumboffset * 1.275), 244.4 - offsetY], 
                "dad" => [492.5 - (dumboffset * 1.765) + (150), 410.8 - offsetY - (50)]
            ], [], 0.715);

            // WHITTY STAGE
            var whittyBG:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/alleyway'));
            whittyBG.antialiasing = true;
            whittyBG.scrollFactor.set(0.9, 0.9);
            whittyBG.scale.set(1.25, 1.25);
            stages['whitty'] = new RoboStage([whittyBG], [], [], [], 0.55);

            // matt shit
            var mattbg:FlxSprite = new FlxSprite(-200, -230).loadGraphic(Paths.image('roboStage/matt_bg'));
            mattbg.antialiasing = true;
            mattbg.scrollFactor.set(0.4,0.4);
            mattbg.scale.set(1.05, 1.05);

            var mattfg:FlxSprite = new FlxSprite(mattbg.x, mattbg.y).loadGraphic(Paths.image('roboStage/matt_foreground'));
            mattfg.antialiasing = true;
            mattfg.scrollFactor.set(0.9, 0.9);
            mattfg.scale.set(1.05, 1.05);

            var mattcrowd:FlxSprite = new FlxSprite(mattbg.x - 80, mattbg.y);
            mattcrowd.frames = Paths.getSparrowAtlas('roboStage/matt_crowd');
            mattcrowd.animation.addByPrefix('bop', 'robo crowd hehe', 24, false);
            mattcrowd.antialiasing = true;
            mattcrowd.scrollFactor.set(0.85, 0.85);

            var spotlight:FlxSprite = new FlxSprite(mattbg.x, mattbg.y).loadGraphic(Paths.image('roboStage/matt_spotlight'));
            spotlight.antialiasing = true;
            spotlight.scrollFactor.set(0.73, 0.73);

            var dumboffset:Int = 95;
            stages['matt'] = new RoboStage([mattbg, mattcrowd, mattfg], [spotlight], [
                "boyfriend" => [1350.2 - dumboffset, 482.3 - 150], 
                "gf" => [585 - dumboffset, 149 - 70], 
                "dad" => [60.7 - dumboffset + (100), 365.3 - 150 - (50)] // 100 and 50 are for the new sprites
            ], [], 0.73);

            // week 1
            var bmp:BitmapData = openfl.Assets.getBitmapData(Paths.image('w1city'));

            var bg:FlxSprite = new FlxSprite(-720, -450).loadGraphic(bmp, true, 2560, 1400);
            bg.animation.add('idle', [3], 0);
            bg.animation.play('idle');
            bg.scale.set(0.3, 0.3);
            bg.antialiasing = true;
            bg.scrollFactor.set(0.9, 0.9);

            var w1city = new BeatSprite(bg.x, bg.y).loadGraphic(bmp, true, 2560, 1400);
            w1city.animation.add('idle', [0,1,2], 0);
            w1city.animation.play('idle');
            w1city.scale.set(bg.scale.x, bg.scale.y);
            w1city.antialiasing = true;
            w1city.scrollFactor.set(0.9, 0.9);
            w1city.ID = 42069;

            var stageFront:FlxSprite = new FlxSprite(-730, 530).loadGraphic(Paths.image('stagefront'));
            stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
            stageFront.updateHitbox();
            stageFront.antialiasing = true;
            stageFront.scrollFactor.set(0.9, 0.9);
            stageFront.active = false;

            var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
            stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
            stageCurtains.updateHitbox();
            stageCurtains.antialiasing = true;
            stageCurtains.scrollFactor.set(0.9, 0.9);
            stageCurtains.active = false;

            stages['week1'] = new RoboStage([bg, w1city, stageFront, stageCurtains], [], [
                "boyfriend" => [1070, 360],
                "gf" => [400, 85],
                "dad" => [-50, 200]
            ], [], 0.757);

            // WEEK 5
            var w5bg:FlxSprite = new FlxSprite(-820, -400).loadGraphic(Paths.image('christmas/lastsongyukichi', 'week5'));
            w5bg.antialiasing = true;
            w5bg.scrollFactor.set(0.9, 0.9);
            var bottomBoppers = new Crowd();

            stages['week5'] = new RoboStage([w5bg], [bottomBoppers], [], [], 0.55);

            // WEEK 2.5
            var church = new FlxSprite(-948, -779).loadGraphic(Paths.image('bg_taki'));
            church.antialiasing = true;
            
            stages['church'] = new RoboStage([church], [], [], ["gf" => 1, "dad" => 1, "boyfriend" => 1], 0.55);
        }
    }

    public function switchStage(stage:String)
    {
        trace('Switching stage to $stage');

        if (stages[stage] == null)
            return trace('$stage does not exist');

        var _stage:RoboStage = stages[stage];

        addSprites(_stage.backgroundSprites, instance.roboBackground);
        addSprites(_stage.foregroundSprites, instance.roboForeground);

        for(ch => pos in _stage.positioning)
        {
            if (Reflect.field(instance, ch) != null)
            {
                var character:Character = Reflect.field(instance, ch);
                character.setPosition(pos[0], pos[1]);
                character.scrollFactor.set(_stage.characterScrolling[ch], _stage.characterScrolling[ch]);
            }
        }

        instance.defaultCamZoom = _stage.cameraZoom;

        if (curStage == stage)
            return;

        curStage = stage;
        instance.camGame.flash(FlxColor.WHITE, 0.45);

        instance.camZooming = true;
        instance.disableCamera = false;

        instance.remove(instance.roboForeground);
        instance.add(instance.roboForeground);
    }

    public function addSprites(sprites:Array<FlxSprite>, typedGroup:FlxTypedGroup<FlxSprite>)
    {
        for (spr in typedGroup)
        {
            if (spr != null)
            {
                typedGroup.remove(spr, true);
                spr.kill();
            }
        }

        for (spr in sprites)
        {
            if (!spr.alive)
                spr.revive();
            
            typedGroup.add(spr);
        }
    }

    public function beatHit(curBeat:Int)
    {
        if (PlayState.SONG.song == 'Loaded')
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
            }
        }

        taki.dance();

        for (i in instance.roboBackground.members)
        {
            animCheck(i);

            switch (curStage)
            {
                case 'week1':
                    if (i.ID == 42069 && curBeat % 4 == 0) // this is such a shitty way of doing it
                    {
                        if (i.animation.curAnim.curFrame > 2)
                            i.animation.curAnim.curFrame = 0;
                        else
                            i.animation.curAnim.curFrame++;
                    }
            }
        }

        for (i in instance.roboForeground.members)
        {
            animCheck(i);
        }
    }

    public function replaceGf(gf:String)
    {
        switch (gf)
        {
            case 'taki':
                instance.gf.visible = false;
                instance.remove(instance.boyfriend);
                instance.remove(instance.dad);
                instance.add(taki);
                instance.add(instance.dad);
                instance.add(instance.boyfriend);
                taki.setPosition(instance.gf.x, instance.gf.y - 190);
            default:
                instance.gf.visible = true;

                if (instance.members.contains(taki))
                {
                    instance.remove(taki);
                }
        }
    }

    public function animCheck(i:FlxSprite)
    {
        if (i != null && i.animation.getByName('bop') != null)
        {
            i.animation.play('bop', true);
            return;
        }

        if (Reflect.field(i, 'beatHit') != null)
            Reflect.callMethod(i, Reflect.field(i, 'beatHit'), []);        
    }
}

class RoboStage
{
    public var backgroundSprites:Array<FlxSprite> = [];
    public var foregroundSprites:Array<FlxSprite> = [];

    public var cameraZoom:Float = 0.4;
    public var positioning:Map<String, Array<Float>> = [];
    public var characterScrolling:Map<String, Float> = [];

    private var defPositioning:Map<String, Array<Float>> = [
        "boyfriend" => [1085.2, 482.3],
        "gf" => [245, 149],
        "dad" => [-254.7, 315.3]
    ];

    public function new(backgroundSprites:Array<FlxSprite>, ?foregroundSprites:Array<FlxSprite>, ?positioning:Map<String, Array<Float>>, ?characterScrolling:Map<String, Float>, cameraZoom:Float)
    {
        for (k => v in defPositioning)
        {
            if (!positioning.exists(k))
            {
                positioning[k] = v;
            }

            if (!characterScrolling.exists(k))
            {
                characterScrolling[k] = 0.9;
            }
        }

        this.positioning = positioning;
        this.characterScrolling = characterScrolling;
        this.cameraZoom = cameraZoom;

        this.backgroundSprites = backgroundSprites;
        this.foregroundSprites = foregroundSprites == null ? [] : foregroundSprites;
    }
}

class BeatSprite extends FlxSprite
{
    public var beatHit:Int->Void = function(curBeat:Int){};
}