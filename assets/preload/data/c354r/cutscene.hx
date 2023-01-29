import PlayState;
import flixel.FlxG;
import flixel.util.FlxTimer;

function image(img:String)
{
	return Paths.image("roboStage/C354R/" + img, 'shared');
}

var robo:FlxSprite;
var fever:FlxSprite;
var tea:FlxSprite;
var zombie:FlxSprite;

function onCreate()
{
	if (PlayState.deaths > 0 || game.skipDialogue || !PlayState.isStoryMode)
	{
		onCreatePost = null;
		snapCamera(BF_CAM_POS);
		getGlobalVar("zombie").visible = false;
		game.startCountdown();
		return;
	}
	game.disableCamera = true;

	camGame.zoom += 0.12;
	camGame.flash(FlxColor.BLACK, 1.3);

	dad.visible = false;
	boyfriend.visible = false;
	gf.visible = false;

	tea = new FlxSprite(gf.x - 120, gf.y - 34);
	tea.frames = Paths.getSparrowAtlas("roboStage/C354R/tea_anim");
	tea.animation.addByPrefix("anim", "tea_anim", 24, false);
	tea.animation.play("anim");
	tea.animation.pause();
	tea.scrollFactor.set(1, 1);
	tea.antialiasing = true;
	add(tea);

	tea.animation.finishCallback = function(a)
	{
		tea.visible = false;
		gf.visible = true;
	}

	robo = new FlxSprite(dad.x - 90, dad.y - 371);
	robo.frames = Paths.getSparrowAtlas("roboStage/C354R/robo_anim");
	robo.animation.addByPrefix("anim", "robo animation", 24, false);
	robo.animation.play("anim");
	robo.animation.pause();
	robo.scrollFactor.set(1, 1);
	robo.antialiasing = true;
	add(robo);

	robo.animation.finishCallback = function(a)
	{
		robo.visible = false;
		dad.visible = true;
		camHUD.visible = true;
		game.camZooming = false;
		FlxTween.tween(camGame, {zoom: game.defaultCamZoom}, 0.6);
		game.disableCamera = false;
		camFollow.setPosition(BF_CAM_POS.x, BF_CAM_POS.y);
	}

	fever = new FlxSprite(boyfriend.x - 63, boyfriend.y - 96);
	fever.frames = Paths.getSparrowAtlas("roboStage/C354R/fever_anim");
	fever.animation.addByPrefix("anim", "fever_anim", 24, false);
	fever.animation.play("anim");
	fever.animation.pause();
	fever.scrollFactor.set(1, 1);
	fever.antialiasing = true;
	add(fever);

	fever.animation.finishCallback = function(a)
	{
		fever.visible = false;
		boyfriend.visible = true;
	}

	for (i in [fever, tea, robo])
		i.color = 0xFFC681C6;

	game.openDialogue(function()
	{
		camHUD.visible = false;
		fever.animation.resume();
		robo.animation.resume();
		tea.animation.resume();
		new FlxTimer().start(0.08, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound('robertCutscene'));
		});
	});
}

function onCreatePost()
{
	remove(tea);
	add(tea, getIndexOfMember(gf));

	remove(fever);
	add(fever, getIndexOfMember(boyfriend));

	game.disableCamera = true;
	snapCamera(DAD_CAM_POS);
	zombie = getGlobalVar("zombie");
}

function onUpdate(elapsed:Float)
{
	if (robo.animation.curAnim.curFrame >= 53 && zombie.animation.curAnim.name != "EXPLODE")
	{
		zombie.animation.play("EXPLODE");
		zombie.offset.x += 293;
		zombie.offset.y += 246;

		zombie.animation.finishCallback = function(a)
		{
			zombie.animation.finishCallback = null;
			new FlxTimer().start(1.45, function(t)
			{
				game.startCountdown();
			});
		}
	}

	if (zombie.animation.curAnim.name == "EXPLODE" && zombie.animation.curAnim.curFrame >= 14)
	{
		zombie.color = FlxColor.WHITE;
	}
}
