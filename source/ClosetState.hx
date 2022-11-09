/*package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.addons.text.FlxTypeText;
import Character.Costume;
import Character.CostumeName;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import sys.thread.Thread;

class ClosetState extends MusicBeatState
{
    public static var isFever:Bool = true;

    var CharacterList(get, never):Array<CostumeName>;

    function get_CharacterList():Array<CostumeName>
        return isFever ? Costume.PlayerList : Costume.GFList;

    var character:Character;
    var cam:FlxCamera = new FlxCamera();
    var camHUD:FlxCamera = new FlxCamera();

    var curSelected:Int = 0;
    var lock:FlxSprite;

    var loadingGrp:FlxGroup = new FlxGroup();
    var loadedCharacters:Array<Character> = [];
    var loadingProgress:FlxBar;
    var _loadingProgress:Int = 0;

    var creditsText:FlxText = new FlxText(0, FlxG.height * 0.9, 0, "", 18);
    var unlockTextBG:FlxSprite = new FlxSprite().makeGraphic(150, 150, FlxColor.BLACK);
    var nameTextBG:FlxSprite = new FlxSprite().makeGraphic(150, 150, FlxColor.BLACK);

    var nameText:FlxText = new FlxText(0, FlxG.height * 0.83, 0, "", 30);
    var unlockText:FlxTypeText = new FlxTypeText(0, FlxG.height * 0.9, 0, "", 18);

    override function create()
    {
        super.create();
        FlxG.cameras.reset(cam);
        camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);
        FlxCamera.defaultCameras = [cam];

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('locker'));
        bg.antialiasing = true;
        bg.alpha = 0.7;
        bg.screenCenter();
        add(bg);

        unlockTextBG.cameras = [camHUD];
        unlockTextBG.screenCenter(X);
        unlockTextBG.y = unlockText.y;
        unlockTextBG.alpha = 0.65;
        unlockTextBG.origin.y = 0;
        add(unlockTextBG);

        unlockText.cameras = [camHUD];
        add(unlockText);

        nameTextBG.screenCenter(X);
        nameTextBG.y = nameText.y;
        nameTextBG.alpha = 0.65;
        nameTextBG.origin.y = 0;
        nameTextBG.cameras = [camHUD];
        add(nameTextBG);

        nameText.cameras = [camHUD];
        nameText.font = Paths.font("vcr.ttf");
        add(nameText);

        lock = new FlxSprite().loadGraphic(Paths.image('lock'));
        lock.cameras = [camHUD];
        lock.screenCenter();
        add(lock);
        lock.visible = false;

        add(loadingGrp);
        var blackScreen = new FlxSprite(1920, 1080).makeGraphic(1920, 1080, FlxColor.BLACK);
        blackScreen.screenCenter();
        loadingGrp.add(blackScreen);

        loadingProgress = new FlxBar(0, FlxG.height * 0.83, HORIZONTAL_INSIDE_OUT, 800, 15, this, '_loadingProgress', 0, 100);
        loadingProgress.createFilledBar(FlxColor.GRAY, FlxColor.GREEN, false);
        loadingGrp.add(loadingProgress);
        loadingGrp.cameras = [camHUD];
        loadingProgress.screenCenter(X);

        var text:FlxText = new FlxText(0, loadingProgress.y - 70, 0, "Preparing Closet... (0%)", 18);
        text.alignment = CENTER;
        loadingGrp.add(text);
        text.screenCenter(X);

        creditsText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        creditsText.cameras = [camHUD];
        add(creditsText);

        new FlxTimer().start(0.25, (t) -> {
            Thread.create(() -> {
                for (i in CharacterList)
                {
                    var char = new Character(150, 150, (isFever ? 'bf' : 'gf') + (Costume.ref[i].character.length == 0 ? '' : '-${Costume.ref[i].character}'), isFever);
                    add(char);
                    remove(char);
                    loadedCharacters.push(char);

                    if (!FlxG.save.data.unlockedCostumes.contains(i))
                        char.color = FlxColor.BLACK;
                    
                    _loadingProgress = Math.ceil((loadedCharacters.length / CharacterList.length) * 100);
                    text.text = 'Preparing Closet... ($_loadingProgress%)';

                    if (i == CharacterList[CharacterList.length - 1])
                    {
                        remove(loadingGrp);
                        FlxG.camera.flash(FlxColor.BLACK, 0.69);
                        FlxG.camera.zoom = 0.75;
                        changeSelection();
                    }
                }
            });
        });
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        Conductor.songPosition = FlxG.sound.music.time;

        unlockTextBG.scale.x = (unlockText.width / unlockTextBG.width) * 1.055;
        unlockTextBG.scale.y = (unlockText.height / unlockTextBG.height) * 1.055;
        nameTextBG.scale.x = (nameText.width / nameTextBG.width) * 1.055;
        nameTextBG.scale.y = (nameText.height / nameTextBG.height) * 1.055;

        if (_loadingProgress >= 100)
        {
            unlockText.screenCenter(X);
            if (controls.LEFT_P)
            {
                changeSelection(-1);
            }
            else if (controls.RIGHT_P)
            {
                changeSelection(1);
            }

            if (controls.ACCEPT)
            {
                if (!lock.visible && CharacterList[curSelected] != FlxG.save.data.currentCostume)
                {
                    FlxG.sound.play(Paths.sound('confirmMenu'));
                    FlxG.save.data.currentCostume = CharacterList[curSelected];
                    character.playAnim('hey', true);
                    updateName();
                }
            }
            else if (controls.BACK)
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.switchState(new MainMenuState());
            }
        }
    }

    override function beatHit()
    {
        if (character != null && (character.animation.finished || character.animation.curAnim.name == 'idle'))
            character.dance();
    }
    
    function changeSelection(change:Int = 0)
    {
        if (character != null)
        {
            character.playAnim('idle', true, false, character.animation.getByName('idle').frames.length - 1);
            remove(character);
        }

        if (change != 0)
            FlxG.sound.play(Paths.sound('scrollMenu'));

        curSelected += change;

        if (curSelected >= CharacterList.length)
            curSelected = 0;
        else if (curSelected < 0)
            curSelected = CharacterList.length - 1;

        character = loadedCharacters[curSelected];
        add(character);

        character.setPosition(450 + Costume.ref[CharacterList[curSelected]].offsetPos.x, 240 + Costume.ref[CharacterList[curSelected]].offsetPos.y);

        FlxTween.cancelTweensOf(creditsText);
        creditsText.alpha = 0;
        creditsText.y = FlxG.height * 1.05;
        FlxTween.tween(creditsText, {alpha: 1, y: FlxG.height * 0.95}, 0.55, {ease: FlxEase.smootherStepInOut, onComplete: (t) -> {
            FlxTween.tween(creditsText, {y: FlxG.height * 1.1}, 0.55, { startDelay: 2.85 });
        }});
        creditsText.text = Costume.ref[CharacterList[curSelected]].credits;
        creditsText.screenCenter(X);

        // less frequent crashing??? crashing still occurs but doing the text seperately seems to cause it to crash less
        var text = Costume.ref[CharacterList[curSelected]].requirements;
        unlockText.resetText(text);
        unlockText.start(0.015, true);

        updateName();

        lock.visible = !FlxG.save.data.unlockedCostumes.contains(CharacterList[curSelected]);
    }

    var equip:Array<FlxTextFormatMarkerPair> = [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN, true), "%")];

    function updateName()
    {
        nameText.text = '< ${Costume.ref[CharacterList[curSelected]].displayName}' + (FlxG.save.data.currentCostume == CharacterList[curSelected] ? ' %[EQUIPPED]%' : '') + ' >';
        nameText.applyMarkup(nameText.text, equip);
        nameText.screenCenter(X);
    }
}