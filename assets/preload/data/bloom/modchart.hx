var BLACK_BAR_HEIGHT:Int = 115;
var spr:FlxSprite;
var spr2:FlxSprite;

function onCreate()
{
    spr = new FlxSprite(0, 0).makeGraphic(1280, BLACK_BAR_HEIGHT, FlxColor.BLACK);
    add(spr, 0, camHUD);
    spr.visible = false;

    spr2 = new FlxSprite(0, FlxG.height - BLACK_BAR_HEIGHT).makeGraphic(1280, BLACK_BAR_HEIGHT, FlxColor.BLACK);
    add(spr2, 0, camHUD);
    spr2.visible = false;
}

function onMoveCamera(isDad:Bool)
{
    dad.visible = true;
    if (curBeat >= 192 && curBeat < 256)
    {
        if (isDad)
        {
            snapCamera(DAD_CAM_POS);
        }
        else
        {
            snapCamera(new FlxPoint(BF_CAM_POS.x + 70, BF_CAM_POS.y + 165));
            dad.visible = false;
        }
    }
}

function onBeatHit(curBeat:Int)
{
    if (curBeat >= 64 && curBeat < 128)
        camGame.zoom += 0.04;
    else if (curBeat % 4 == 0)
        camGame.zoom += 0.012;

    if (curBeat == 192)
    {
        spr.visible = true;
        spr2.visible = true;
        game.defaultCamZoom += 0.25;
        camGame.zoom = FlxG.state.defaultCamZoom;

        snapCamera(DAD_CAM_POS);

        for (i in 0...4)
            strumLineNotes[i].alpha = 0.43;
    }
    else if (curBeat == 256)
    {
        FlxTween.tween(spr, {y: -BLACK_BAR_HEIGHT}, 0.24);
        FlxTween.tween(spr2, {y: FlxG.height}, 0.24);
        game.defaultCamZoom -= 0.25;

        for (i in 0...4)
            strumLineNotes[i].alpha = 1;
    }
}