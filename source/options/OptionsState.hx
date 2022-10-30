package options;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxDirection;
import flixel.effects.FlxFlicker;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
using StringTools;

class OptionsState extends MusicBeatState
{
    var items:FlxTypedGroup<AlphabetQuick> = new FlxTypedGroup<AlphabetQuick>();
    var checkboxes:FlxTypedGroup<Checkbox> = new FlxTypedGroup<Checkbox>();

    var categories:Array<OptionCategory> = [
        {"name":"Controls", options:[
            new Option("Left", "", "leftBind", KEYBIND),
            new Option("Down", "", "downBind", KEYBIND),
            new Option("Up", "", "upBind", KEYBIND),
            new Option("Right", "", "rightBind", KEYBIND),
            new Option("Reset", "", "killBind", KEYBIND),
            new Option("Enable Reset Keybind", "When enabled, pressing the RESET keybind will automatically cause a game over.", "resetButton", BOOL)
        ]},
        {"name":"Gameplay", options: [
            new Option("Downscroll", "When enabled, notes will scroll from the top of the screen to the bottom.", "downscroll", BOOL),
            new Option("Offset", "In milliseconds, how long a note should be offset from it's initial timing.", "offset", INT, {range:[-250, 250], suffix:"ms"}),
            new Option("Ghost Tapping", "When enabled, misinputs will no longer cause misses.", "ghost", BOOL),
            new Option("Play with Modcharts", "When enabled, modcharts will be automatically forced on for every song.", "modcharts", BOOL),
            new Option("Botplay", "When enabled, player input will be locked and songs will automatically play themselves.", "botplay", BOOL)
        ]},
        {"name":"Visuals", options:[
            new Option("Show Note Splashes", "When enabled, \"Sick\" ratings will causes the corresponding arrow to sparkle.", "notesplash", BOOL),
            new Option("Show Subtitles", "When enabled, songs containing lyrics display subtitles on screen.", "subtitles", BOOL),
            new Option("Show Song Position", "When enabled, the time duration of the current song will always display.", "songPosition", BOOL),
        ]},
        {"name":"Performance", options: [
            new Option("FPS Cap ", "Caps your framerate.", "fpsCap", INT, {range:[60, 240], increaseInterval: 20}),
            new Option("Show FPS Counter", "When enabled, a FPS and Memory counter will be shown in the top left.", "fps", BOOL, {callback: () -> { (cast (openfl.Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps); }}),
            new Option("Anti Aliasing", "When disabled, forces all sprites to not have anti-aliasing. (In-Game Only)", "antialiasing", BOOL),
            new Option("Use Shaders", "When disabled, shaders will not be used and causes certain songs to lose special effects.", "shaders", BOOL),
            new Option("Play Intro on Startup", "When disabled, the intro played on startup will no longer be played.", "animeIntro", BOOL)
        ]}
    ];

    var curCategory:Int = 0;
    var inCategory:Bool = false;
    var curSelected:Int = 0;
    var awaitingInput:Bool = false;

    var bg:FlxSprite;
    var descText:FlxText;
    var descBox:FlxSprite;

    override function create()
    {
        super.create();
        
        // preload checkbox
        var checkbox:Checkbox = new Checkbox(null);
        add(checkbox);
        remove(checkbox);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = true;
        bg.color = 0x49337C;
		add(bg);

        add(items);
        add(checkboxes);

        descBox = new FlxSprite(0, FlxG.height * 0.9).makeGraphic(10, 10, FlxColor.BLACK);
        descBox.alpha = 0.6;
        descBox.origin.y = 0;
        add(descBox);

        descText = new FlxText(0, FlxG.height * 0.9, 0, "", 24);
        descText.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, CENTER);
        add(descText);

        resetItems();
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        // ONLY USED FOR SETTING KEYBINDS, PUT EVERYTHING REQUIRING INPUT AFTER THIS
        if (awaitingInput)
        {
            if (controls.BACK)
            {
                awaitingInput = false;
                FlxFlicker.stopFlickering(items.members[curSelected]);
                items.members[curSelected].text = categories[curCategory].options[curSelected].getDisplay();
            }
            else if (FlxG.keys.justPressed.ANY)
            {
                var key = FlxG.keys.getIsDown()[0].ID.toString();
                if (["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "LEFT", "DOWN", "UP", "RIGHT"].contains(key))
                    return;

                for (i in 0...categories[curCategory].options.length)
                {
                    var opt = categories[curCategory].options[i];
                    if (Reflect.field(FlxG.save.data, opt.saveVariable) == key && i != curSelected)
                    {
                        updateDescription("Conflicting Keybind: " + opt.display + " has been swapped to " + Reflect.field(FlxG.save.data, categories[curCategory].options[curSelected].saveVariable));
                        Reflect.setField(FlxG.save.data, opt.saveVariable, Reflect.field(FlxG.save.data, categories[curCategory].options[curSelected].saveVariable));
                        items.members[i].text = opt.getDisplay();
                        break;
                    }
                }

                Reflect.setField(FlxG.save.data, categories[curCategory].options[curSelected].saveVariable, key);
                items.members[curSelected].text = categories[curCategory].options[curSelected].getDisplay();
                FlxFlicker.stopFlickering(items.members[curSelected]);
                awaitingInput = false;
                controls.loadKeyBinds();
            }

            return;
        }
        //////////////////////////////////////////////////////////////////////////////

        if (controls.UP_P)
            changeSelection(-1);
        else if (controls.DOWN_P)
            changeSelection(1);

        if (inCategory && (controls.LEFT_P || controls.RIGHT_P))
        {
            if (categories[curCategory].options[curSelected].onDirectionalInput(controls.LEFT_P ? LEFT : RIGHT))
            {
                items.members[curSelected].text = categories[curCategory].options[curSelected].getDisplay();
            }
        }

        if (controls.ACCEPT)
        {
            if (!inCategory)
            {
                curCategory = curSelected;
                curSelected = 0;
                inCategory = true;
                resetItems();
            }
            else
            {
                selectOption();
            }
        }
        else if (controls.BACK)
        {
            if (inCategory)
            {
                inCategory = false;
                curSelected = 0;
                resetItems();
            }
            else
            {
                FlxG.save.flush();
                FlxG.switchState(new MainMenuState());
            }
        }
    }

    function updateDescription(?forcedDescription:String)
    {
        var forceDesc:Bool = forcedDescription != null;
        if (!inCategory && !forceDesc || categories[curCategory].options[curSelected].description.length <= 0 && !forceDesc)
        {
            descText.visible = descBox.visible = false;
            return;
        }

        var str:String = forceDesc ? forcedDescription : categories[curCategory].options[curSelected].description;
        descText.visible = descBox.visible = true;
        descText.text = str;
        descText.screenCenter(X);
        descBox.screenCenter(X);
        descBox.scale.set((descText.width / descBox.width) * 1.03, descText.height / descBox.height);
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        curSelected += change;

        if (curSelected >= items.length)
            curSelected = 0;
        else if (curSelected < 0)
            curSelected = items.length - 1;

        var bullShit:Int = 0;
        for (item in items.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if (item.targetY == 0)
            {
                item.alpha = 1;
            }
        }

        updateDescription();
    }

    // Only called when in a category and you press enter / the accept button
    function selectOption()
    {
        switch (categories[curCategory].options[curSelected].type)
        {
            case BOOL:
                for (i in checkboxes.members)
                {
                    if (i.ID == curSelected && !i.animation.curAnim.name.contains("selecting"))
                    {
                        categories[curCategory].options[curSelected].onPress();
    
                        if (i.animation.curAnim.name == "selected")
                        {
                            FlxG.sound.play(Paths.sound('cancelMenu'));
                            i.animation.play("unselected", true);
                            i.centerOffsets();
                            i.centerOrigin();
                        }
                        else
                        {
                            FlxG.sound.play(Paths.sound('confirmMenu'));
                            i.animation.play("selecting", true);
                            // offsets are so cringe
                            i.offset.x  += 14;
                            i.offset.y += 65;                    
                        }
                    }
                }
            case KEYBIND:
                awaitingInput = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                FlxFlicker.flicker(items.members[curSelected], 0, 0.06, true);
                items.members[curSelected].text = "Awaiting input...";
            default:
                // do nothing
        }
    }

    function resetItems()
    {
        // kill all members of both groups
        for (c in [items, checkboxes])
        {
            for (i in (cast c : FlxTypedGroup<flixel.FlxBasic>).members)
            {
                (cast i : flixel.FlxBasic).kill();
            }

            (cast c : FlxTypedGroup<flixel.FlxBasic>).clear();
        }

        var array:Array<Dynamic> = inCategory ? categories[curCategory].options : categories;
        for (i in 0...array.length)
        {
            var display = inCategory ? categories[curCategory].options[i].getDisplay() : categories[i].name;
            var text:AlphabetQuick = new AlphabetQuick(60,0, display, {bold:true, size:0.78, spacing:4, menuItem: true, dontBoldNumbers: true});

            if (inCategory)
            {
                switch (categories[curCategory].options[i].type)
                {
                    case BOOL:
                        var checkbox:Checkbox = new Checkbox(text);
                        checkbox.setPosition(text.x + text.width + 20, text.y + ((text.height / 2) - checkbox.height / 2));
                        if (Reflect.field(FlxG.save.data, categories[curCategory].options[i].saveVariable) == true)
                        {
                            checkbox.animation.play("selected", true);
                            checkbox.centerOffsets();
                            checkbox.offset.x -= 12;
                            checkbox.offset.y -= 15;
                        }
                        checkbox.ID = i;
                        checkboxes.add(checkbox);
                    default:
                }
            }

            text.ID = i;
            text.targetY = i;
            items.add(text);
        }

        changeSelection();
    }
}

typedef OptionCategory = {
    name:String,
    options:Array<Option>
}

enum OptionType
{
    BOOL;
    INT;
    STATE;
    KEYBIND;
}

class Option
{
    /**
     * @param display What text is visibly displayed on the options menu
     * @param description What text is shown on the bottom of the options menu
     * @param saveVariable What the internal variable stored inside of the FlxSave should be named
     * @param type Sets what base to use for the option from the OptionType enum.
     * @param values An object containing specific data for the specified OptionType (Ex: With a state OptionType you would have an object like {state: new FlxState()} )
     */

    public function new(display:String = "No Option Name", ?description:String, saveVariable:String = "temp_option", type:OptionType = BOOL, ?values:Dynamic) 
    {
        this.display = display;
        this.saveVariable = saveVariable;
        this.type = type;
        this.description = description;

        if (values != null)
        {
            switch (type)
            {
                case STATE:
                    if (values.state != null)
                    {
                        state = values.state;
                    }
                case INT:
                    if (values.increaseInterval != null)
                    {
                        increaseInterval = values.increaseInterval;
                    }

                    if (values.range != null)
                    {
                        range = values.range;
                    }

                    if (values.suffix != null)
                    {
                        suffix = values.suffix;
                    }
                case BOOL:
                    if (values.callback != null)
                    {
                        callback = values.callback;
                    }
                default:
                    // do nothing
            }
        }
    }

    // return true if something changes so the text updates
    public function onDirectionalInput(direction:FlxDirection):Bool
    {
        switch (type)
        {
            case INT:
                var newValue:Int = cast FlxMath.bound(Reflect.getProperty(FlxG.save.data, saveVariable) + (direction == LEFT ? -increaseInterval : increaseInterval), range[0], range[1]);
                Reflect.setProperty(FlxG.save.data, saveVariable, newValue);
                trace("Changing " + saveVariable + " to " + newValue);
                return true;
            default:
                return false;
                // do nothing
        }
    }

    public function onPress()
    {
        switch (type)
        {
            case BOOL:
                trace("Changing " + saveVariable + " to " + !Reflect.getProperty(FlxG.save.data, saveVariable));
                Reflect.setProperty(FlxG.save.data, saveVariable, !Reflect.getProperty(FlxG.save.data, saveVariable));
            case STATE:
                FlxG.switchState(Type.createInstance(state, [0]));
            default:
                // do nothing
        }

        if (callback != null)
            callback();
    }

    public function getDisplay():String
    {
        switch (type)
        {
            case INT:
                return display + " < " + Reflect.field(FlxG.save.data, saveVariable) + suffix + " >";
            case KEYBIND:
                return display + ": " + Reflect.field(FlxG.save.data, saveVariable);
            default:
                return display;
        }
    }

    public var display:String = "";
    public var description:String = "";
    public var saveVariable:String = "";
    public var suffix:String = "";
    public var type:OptionType = BOOL;
    public var callback:Void->Void;

    public var state:Class<flixel.FlxState>;

    public var range:Array<Float> = [0, 100];
    public var increaseInterval:Int = 1;
}