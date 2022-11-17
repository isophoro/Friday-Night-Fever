import("Character");

// this truly was a friday night fever

var feverFalling:Character;
var roboFalling:Character;
var roboFallingCool:Character;

var feverTunnel:Character;
var roboTunnel:Character;

function onCreate()
{
    feverTunnel = new Character(boyfriend.x, boyfriend.y, "bf-mad-glow", true);
    feverTunnel.scrollFactor.copyFrom(boyfriend.scrollFactor);
    add(feverTunnel);
    feverTunnel.visible = false;

    roboTunnel = new Character(dad.x, dad.y, "robo-final-glow", false);
    roboTunnel.scrollFactor.copyFrom(dad.scrollFactor);
    add(roboTunnel);
    roboTunnel.visible = false;

    feverFalling = new Character(boyfriend.x, boyfriend.y + 145, "fever-fall", true);
    add(feverFalling);
    feverFalling.visible = false;

    roboFalling = new Character(boyfriend.x - 1100, boyfriend.y - 175, "robo-fall", false);
    add(roboFalling);
    roboFalling.visible = false;

    roboFallingCool = new Character(boyfriend.x - 1100, boyfriend.y - 175, "robo-fall-cool", false);
    add(roboFallingCool);
    roboFallingCool.visible = false;
}

function onUpdate(elapsed:Float)
{
    if (curBeat >= 463 && curBeat < 496)
    {
        roboFallingCool.visible = roboFallingCool.animation.curAnim.name != "idle";
        roboFalling.visible = !roboFallingCool.visible;
    }
    else if (curBeat == 496)
    {
        roboFalling.visible = true;
        roboFallingCool.visible = false;
    }
}

function onPostUpdate(elapsed:Float)
{
    if (scoreTxt.alpha == 0.7)
        scoreTxt.scale.set(1,1);
}

var introBumps:Array<Int> = [40, 50, 57, 59, 60, 61, 62, 63];

function onStepHit(curStep:Int)
{
    if (introBumps.contains(curStep))
    {
        camGame.zoom += 0.02;
    }
}

function onBeatHit(curBeat:Int)
{
    switch(curBeat)
    {
        case 1:
            camGame.zoom += 0.02;
        case 4:
            camGame.zoom += 0.02;
        case 8:
            camGame.zoom += 0.02;
        case 272:
            roboTunnel.visible = true;
            dad.visible = false;

            feverTunnel.visible = true;
            boyfriend.visible = false;

            game.curPlayer = feverTunnel;
            game.curOpponent = roboTunnel;
        case 432:
            camGame.flash(FlxColor.WHITE, 0.45);
            forceComboPos = new FlxPoint(FlxG.width * (FlxG.save.data.downscroll ? 0.78 : 0.05), 30);

            var yAdd:Int = FlxG.save.data.downscroll ? -200 : 200;
            for (i in [iconP1, iconP2, healthBar, healthBarBG])
            {
                FlxTween.tween(i, {y: i.y + yAdd, alpha: 0}, 0.4, {ease: FlxEase.quartInOut, onComplete: function (t){
                    if (i == healthBarBG)
                        FlxTween.tween(scoreTxt, {y: scoreTxt.y + (FlxG.save.data.downscroll ? yAdd / 3.3 : 0), alpha: 0.7}, 0.4);
                }});
            }

            for (i in [dad, boyfriend, roboTunnel, feverTunnel])
                i.visible = false;

            game.disableCamera = true;
            snapCamera(new FlxPoint(BF_CAM_POS.x - 240, BF_CAM_POS.y + 370));
            game.curPlayer = feverFalling;
            game.curOpponent = roboFalling;
            roboFalling.visible = true;
            feverFalling.visible = true;
            game.defaultCamZoom += 0.635;
            camGame.zoom = game.defaultCamZoom + 0.15;
            bfAltSuffix = '-cool';

            for (i in 0...4)
                strumLineNotes[i].visible = false;
        case 464:
            game.curOpponent = roboFallingCool;
        case 496:
            game.curOpponent = roboFalling;
        case 495:
            bfAltSuffix = '';
    }

    if (curBeat >= 80 && curBeat < 432 && curBeat % 4 == 0)
    {
        camGame.zoom += 0.005;
    }


    if (curBeat >= 464 && curBeat < 496)
    {
        dad.playAnim("idle");
    }
}