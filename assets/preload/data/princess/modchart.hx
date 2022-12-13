import("AlphabetQuick");
import("flixel.math.FlxMath");

var hudAngle:Float = 0;

function onCreate()
{
    game.executeModchart = false;

    // preload alphabet shit for later
    var alphabet:AlphabetQuick = new AlphabetQuick(0,0, "friday night fever frenzy just a week away!", {bold: true});
    add(alphabet);
    remove(alphabet);
}

function onUpdate(elapsed:Float)
{
    camHUD.angle = FlxMath.lerp(hudAngle, camHUD.angle, FlxMath.bound(1 - (elapsed * 25.125), 0, 1));
}

var bopTiming:Array<Array<Float>> = [
    // [curStep >=, curStep <, angle]
    [0, 128, 0.45],
    [128, 256, 1.35],
    [320, 384, 1.35],
    [384, 417, 0.45],
    [417, 449, 1.35],
    [480, 512, 0.45],
    [641, 768, 0.45],
    [832, 897, 1.35],
    [1024, 1152, 0.45],
    [1152, 1212, 1.35],
    [1221, 1281, 1.35],
    [1313, 1344, 1.35],
    [1376, 1408, 1.35],
    [1408, 1468, 0.45],
    [1473, 1500, 0.45],
    [1505, 1522, 0.45]
];

function onStepHit(curStep:Int)
{
    switch (curStep)
    {
        case 112:
            game.defaultCamZoom += 0.0565;
        case 117:
            game.defaultCamZoom += 0.03;
        case 121:
            game.defaultCamZoom += 0.03;
        case 125:
            game.defaultCamZoom += 0.1;
        case 1212:
            createText("ha", 0.67);
        case 1214:
            createText("ha!", 0.75);
        case 1536:
            for (i in strumLineNotes)
                i.visible = false;
        case 1568:
            for (i in [healthBar, healthBarBG, scoreTxt, iconP1, iconP2])
                i.visible = false;
    }

    if (curStep >= 1524 && curStep < 1532 || curStep >= 1212 && curStep < 1214 || curStep >= 1468 && curStep < 1470)
    {
        game.disableModCamera = true;
        game.camZooming = false;
        camGame.zoom = 0.6;
    }

    if (curStep >= 1532 && curStep < 1536 || curStep >= 1214 && curStep < 1216 || curStep >= 1470 && curStep < 1472)
    {
        game.disableModCamera = false;
        game.camZooming = true;
        camGame.zoom = 0.65;
    }    

    if (curStep % 4 == 0)
    {
        while (bopTiming[0] != null && curStep >= bopTiming[0][1])
        {
            bopTiming.shift();
            if (bopTiming[0] != null)
            {
                if (bopTiming[0][1] + 1 > curStep)
                {
                    hudAngle = 0;
                }

                if (bopTiming[0][2] < 1 || hudAngle == 0)
                {
                    for (i in 0...8)
                    {
                        FlxTween.tween(strumLineNotes[i], {x: defaultStrumPos[i].x}, 0.3);
                    }
                }
            }
        }

        if (bopTiming[0] != null)
        {
            var timing:Array<Int> = bopTiming[0];
            if (curStep >= timing[0] && curStep < timing[1])
            {
                hudAngle = curStep % 8 == 0 ? timing[2] : timing[2] * -1;
                if (timing[2] > 1)
                {
                    for (i in 0...8)
                    {
                        strumLineNotes[i].x = defaultStrumPos[i].x + (curStep % 8 == 0 ? 7 : -7);
                    }
                }
            }
        }
    }
}

function onBeatHit(curBeat:Int)
{
    if (curBeat % 4 == 0)
    {
        if (curStep < 128)
        {
            camHUD.zoom += 0.01;
        }
        else
        {
            camHUD.zoom += 0.02;
        }
    }
}

function createText(text:String, size:Float)
{
    var ha:AlphabetQuick = new AlphabetQuick(dad.x + 320, dad.y, text, {bold:true, size: size});
    ha.acceleration.y = FlxG.random.int(200, 300);
    ha.velocity.y -= FlxG.random.int(140, 160);
    ha.velocity.x = FlxG.random.float(-5, 5);
    add(ha);

    FlxTween.tween(ha, {alpha: 0}, 0.5, {onComplete: function (t){
        remove(ha);
    }});
}