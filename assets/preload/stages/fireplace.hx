import flixel.FlxSprite;
import flixel.tweens.FlxTween;

var bg:FlxSprite;
var fire:FlxSprite;
var portal:FlxSprite;
var hallow:FlxSprite;
var hallowSCARY:FlxSprite;
var fGrp = [];

var furniture = [
	["book", -500, -650],
	["chair", 1720, 110],
	["lester", 450, 900],
	["lamp", 1650, -310],
	["plank0", -700, 750],
	["plank 2", 2030, 1000],
	["plant", -1000, 380],
	["skelly", 1800, 800]
];

function onCreate()
{
	game.defaultCamZoom = 0.76;

	bg = new FlxSprite(-140, -250).loadGraphic(Paths.image("paste/bg"));
	bg.antialiasing = true;
	bg.scale.set(1.25, 1.25);
	add(bg);

	fire = new FlxSprite(530, 50);
	fire.frames = Paths.getSparrowAtlas("paste/fire");
	fire.animation.addByPrefix("fire", "fire", 24, true);
	fire.animation.play("fire");
	fire.antialiasing = true;
	fire.scale.set(1.25, 1.25);
	add(fire);

	portal = new FlxSprite(bg.x - (bg.width * .1), bg.y - (bg.height * .1)).loadGraphic(Paths.image("paste/portal"));
	portal.antialiasing = true;
	portal.scale.set(3.77, 3.77);
	add(portal);
	portal.visible = false;

	hallow = new FlxSprite(portal.x, portal.y).loadGraphic(Paths.image("paste/hallow"));
	hallow.antialiasing = true;
	hallow.scale.set(1.85, 1.85);
	add(hallow);
	hallow.visible = false;

	hallowSCARY = new FlxSprite(portal.x, portal.y).loadGraphic(Paths.image("paste/hallowScary"));
	hallowSCARY.antialiasing = true;
	hallowSCARY.scale.set(1.85, 1.85);
	add(hallowSCARY);
	hallowSCARY.visible = false;

	for (i in 0...furniture.length)
	{
		var f = new FlxSprite(furniture[i][1], furniture[i][2]);
		f.frames = Paths.getSparrowAtlas('paste/furnitures');
		f.animation.addByPrefix("idle", furniture[i][0], 0, true);
		f.animation.play("idle");
		f.scale.set(1.3, 1.3);
		f.antialiasing = true;
		f.visible = false;
		FlxTween.tween(f, {y: f.y - FlxG.random.int(-50, -35)}, 1.9 + FlxG.random.float(-0.6, 0.9), {type: FlxTweenType.PINGPONG, ease: FlxEase.quadInOut});
		fGrp.push(f);
		add(f);
	}

	boyfriend.x -= 90;
	boyfriend.y -= 150;
	gf.y -= 150;

	setGlobalVar("bg", bg);
	setGlobalVar("fire", fire);
	setGlobalVar("changeBG", changeBG);
}

function changeBG()
{
	bg.visible = false;
	fire.visible = false;
	hallow.visible = true;
	hallowSCARY.visible = true;
	hallowSCARY.alpha = 0;
	portal.visible = true;

	for (i in fGrp)
	{
		i.visible = true;
	}
}

function onStepHit(curStep)
{
	if (curStep == 1472)
		FlxTween.tween(hallowSCARY, {alpha: 1}, 70);
}

function onCreatePost()
{
	dad.scrollFactor.set(1, 1);
	boyfriend.scrollFactor.set(1, 1);
	gf.scrollFactor.set(1, 1);
}

function onUpdate(elapsed:Float)
{
	portal.angle += elapsed * 18;
}
