import flixel.FlxSprite;

var bg:FlxSprite;

function createObject(name:String, x:Float, y:Float, anim:String = null)
{
	var obj:FlxSprite = new FlxSprite(bg.x + (x * bg.scale.x), bg.y + (y * bg.scale.y));
	obj.frames = Paths.getSparrowAtlas("minus/" + name, "week2");
	obj.animation.addByPrefix("i", anim.length > 1 ? anim : name, 24, true);
	obj.animation.play("i");
	obj.origin.set(0, 0);
	obj.scale.set(1.5, 1.5);
	obj.antialiasing = true;
	add(obj);
}

function onCreate()
{
	game.defaultCamZoom = 0.4;

	bg = new FlxSprite(-920, -840).loadGraphic(Paths.image("minus/bg", "week2"));
	bg.origin.set(0, 0);
	bg.scale.set(1.5, 1.5);
	bg.antialiasing = true;
	add(bg);

	createObject("monitors", 118, 578, "screen thing");
	createObject("creatura", 502, 417, "craetura");
	createObject("candles1", 1742, 198, "");
	createObject("candles2", 1512, 702, "");
	createObject("candles3", 691, 636, "");
}
