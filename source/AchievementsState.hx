package;

import flixel.tweens.FlxEase;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.tweens.FlxTween;
import openfl.Lib;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;

using StringTools;


class AchievementsState extends MusicBeatState
{

    var achievementsGroup:FlxTypedSpriteGroup<FlxSprite>;
    var unlockedAchievements:Array<String> = [];
    private var achievement:Array<Int> = [];

    var name:FlxText;
    var description:FlxText;
    var icon:FlxSprite;

    public static var overlapping:Int = 0;

    //achievements


    override function create()
    {

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("credits/bg", "preload"));
        bg.antialiasing = true;
        add(bg);

        achievementsGroup = new FlxTypedSpriteGroup<FlxSprite>();
        add(achievementsGroup);

        for (i in 0...Achievements.achievements.length) 
        {
            unlockedAchievements.push(Achievements.achievements[i][0]);
            achievement.push(i);
		}


        //yes i stole some code from indie cross ok i sucked at coding this shit
        for (i in 0...unlockedAchievements.length) 
        {
                name = new FlxText(97, 552.7, 0, "", 40);
                achievementsGroup.add(name);


                icon = new FlxSprite(33.5, 33.5).loadGraphic(Paths.image(Achievements.achievements[achievement[overlapping]][2]));
                icon.updateHitbox();
                icon.scrollFactor.set();
                icon.antialiasing = FlxG.save.data.highquality;
                achievementsGroup.add(icon);

        }

        description = new FlxText(0, FlxG.height * 0.95, 0, "", 24);
        description.alpha = 0.87;
        description.screenCenter(X);
        description.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.GRAY, CENTER, OUTLINE, FlxColor.BLACK);
        description.scrollFactor.set();
        add(description);

        FlxG.mouse.visible = true;

        changeSelection();



        super.create();

    }

    override function update(elapsed:Float)
    {
		if (controls.BACK) 
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

        if(FlxG.mouse.overlaps(achievementsGroup))
        {
            changeSelection();
        }

        if(FlxG.keys.justPressed.U)
        {
            changeSelection(1);
        }

        /*if (Achievements.achievements[achievement[overlapping]][3] && !FlxG.save.data.achievements[overlapping])
		{
			description.text = "?";
		}
		else
		{
			description.text = Achievements.achievements[achievement[overlapping]][1];
		}*/

        super.update(elapsed);

    }

    function changeSelection(change:Int = 0)
    {
        var bullShit:Int = 0;

        overlapping += change;

        if(overlapping < 0)
            overlapping = unlockedAchievements.length - 1;
        if(overlapping >= unlockedAchievements.length)
            overlapping = 0;

        
        if (!FlxG.save.data.achievements[overlapping])
		{
            if(Achievements.achievements[achievement[overlapping]][3] == true)
            {
                description.text = "?";
            }
            else
            {
                description.text = Achievements.achievements[achievement[overlapping]][1];
            }
			
            name.text = Achievements.achievements[achievement[overlapping]][0];
		}
		
        if (FlxG.save.data.achievements[overlapping] == true)
		{
			description.text = Achievements.achievements[achievement[overlapping]][1];
            icon.loadGraphic(Paths.image(Achievements.achievements[achievement[overlapping]][2]));
            name.text = Achievements.achievements[achievement[overlapping]][0];

            trace('i have this one!!!');
		}
        else
        {
            icon.loadGraphic(Paths.image('achievements/locked'));
        }

    }



}

