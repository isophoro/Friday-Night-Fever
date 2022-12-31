import flixel.FlxSprite;
import flixel.tweens.FlxTween;

var bg:FlxSprite;
var fire:FlxSprite;
var portal:FlxSprite;
var hallow:FlxSprite;
var hallowSCARY:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = 0.76;

	bg = new FlxSprite(-140, -250).loadGraphic(Paths.image("paste/bg"));
	bg.antialiasing = true;
	bg.scale.scale(1.25);
	add(bg);

	fire = new FlxSprite(530, 50);
	fire.frames = Paths.getSparrowAtlas("paste/fire");
	fire.animation.addByPrefix("fire", "fire", 24, true);
	fire.animation.play("fire");
	fire.antialiasing = true;
	fire.scale.scale(1.25);
	add(fire);

	portal = new FlxSprite(bg.x - (bg.width * .1), bg.y - (bg.height * .1)).loadGraphic(Paths.image("paste/portal"));
	portal.antialiasing = true;
	portal.scale.scale(1.45);
	add(portal);
	portal.visible = false;

	hallow = new FlxSprite(portal.x, portal.y).loadGraphic(Paths.image("paste/hallow"));
	hallow.antialiasing = true;
	hallow.scale.scale(1.85);
	add(hallow);
	hallow.visible = false;

	hallowSCARY = new FlxSprite(portal.x, portal.y).loadGraphic(Paths.image("paste/hallowScary"));
	hallowSCARY.antialiasing = true;
	hallowSCARY.scale.scale(1.85);
	add(hallowSCARY);
	hallowSCARY.visible = false;

	portal.scale.scale(2.6);

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
}

function onStepHit(curStep)
{
	if (curStep == 708)
		FlxTween.tween(hallowSCARY, {alpha: 1}, 100);
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
