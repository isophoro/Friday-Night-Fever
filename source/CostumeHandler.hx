package;

import flixel.FlxG;

enum CostumeName
{
    FEVER;
    FEVER_CASUAL;
    FEVER_MINUS;
    FEVER_OG;
    TEASAR;
}

@:enum abstract CostumeVariant(String) from String to String
{
    var DEMON = "-demon";
    var PIXEL = "-pixel";
}

typedef CostumeInfo = {
    displayName:String,
    character:String,
    description:String,
    creator:String,
    ?camOffset:Array<Float>,
    ?characterOffset:Array<Float>
}

class CostumeHandler
{
    public static final costumes:Map<CostumeName, CostumeInfo> = [
        FEVER => {displayName: "Fever", description: "Mayor of Fever Town", character:"bf", creator:"Kip"},
        FEVER_CASUAL => {displayName: "Fever (Casual)", description: "On Hard difficulty, full combo Week 3. (Story Mode)", character:"fever-casual", creator:"Kip"},
        FEVER_MINUS => {displayName: "Fever (Minus)", description: "On Minus difficulty, beat Week 2 and 7. (Story Mode)", character:"fever-minus", creator:"EMG"},
        FEVER_OG => {displayName: "Fever (O.G)", description: "Play a version of Friday Night Fever before v1.4 or beat Weeks 1 through 6.", character:"fever-old", creator:"Kip"},
        TEASAR => {displayName: "Teasar", description: "On Baby difficulty, full combo Milk Tea.", character:"teasar", creator:"Circle"}
    ];

    public static final FEVER_LIST:Array<CostumeName> = [FEVER, FEVER_CASUAL, FEVER_MINUS, FEVER_OG, TEASAR]; // Organized list for costume menu

    public static function checkSave()
    {
        if (FlxG.save.data.costumes == null)
        {
            FlxG.save.data.costumes = [];
            FlxG.save.data.costumes.push(FEVER);
            FlxG.save.data.costume = FEVER;
        }

        if (FlxG.save.data.costume == null)
            FlxG.save.data.costume = FEVER;
    }

    public static function unlock(costume:CostumeName)
    {
        checkSave();
        if (FlxG.save.data.costumes.contains(costume))
        {
            trace(costumes[costume].displayName + " is already unlocked.");
            return;
        }

        FlxG.save.data.costumes.push(costume);
    }

    public static function getFormattedCharacter()
    {
        var variant:String = "";

        variant += switch (PlayState.SONG.song.toLowerCase())
        {
            case 'down-bad' | 'bazinga' | 'crucify' | 'retribution' | 'farmed' | 'throw-it-back' | 'party-crasher' | '': "demon";
            default: "";
        }
    }
}