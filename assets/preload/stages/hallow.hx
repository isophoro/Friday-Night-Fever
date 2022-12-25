import ("Character");
import("shaders.WiggleEffect");

var painting:FlxSprite;
var paste:Character;
var wiggleEffect:WiggleEffect;

function onCreate()
{
	game.summonPainting(); // preload
	game.defaultCamZoom = 0.6;

	var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('week2bghallow'));
	bg.antialiasing = true;
	add(bg);

	if (getSong("song") != "Hallow")
	{
		painting = new FlxSprite(-200, -100).loadGraphic(Paths.image('week2bghallowpainting'));
		painting.antialiasing = true;
		add(painting);
		setGlobalVar("painting", painting);
		painting.visible = false;

		paste = new Character(625, 66, "gf-paste", false);
	}

	setGlobalVar("changeBG", changeBG);
}

function onBeatHit(curBeat:Int)
{
	if (paste != null)
		paste.dance();
}

function onUpdate(elapsed:Float)
{
	if (wiggleEffect != null)
		wiggleEffect.update(elapsed);
}

function changeBG()
{
	if (painting == null)
		return;

	if (game.curBeat > 0)
	{
		camHUD.flash(FlxColor.WHITE, 0.5);
	}

	painting.visible = true;
	add(paste, getIndexOfMember(gf));
	gf.visible = false;

	if (ClientPrefs.shaders)
	{
		wiggleEffect = new WiggleEffect();
		wiggleEffect.shader.effectType.value = [1]; // non h-scriptphobic version
		wiggleEffect.waveAmplitude = 0.05;
		wiggleEffect.waveFrequency = 3;
		wiggleEffect.waveSpeed = 1;

		painting.shader = wiggleEffect.shader;
	}
}
