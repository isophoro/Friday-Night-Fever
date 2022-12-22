package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.InteractableState;
#if windows
import Discord.DiscordClient;
#end

class MainMenuState extends InteractableState
{
	public static var firstTime:Bool = true;
	public static var alert:FlxText;

	override function create()
	{
		super.create();

		persistentUpdate = persistentDraw = true;

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", null);
		#end

		var tunnelBG:MenuBG = new MenuBG("newMain/subway_bg_2", 0, -12, 0.7);
		add(tunnelBG);

		var train = new Interactable('newMain/trainmenu', 150, 75, 1.32, 'Train notselected', 'Train selected', new InteractHitbox(480, 205, 165, 280),
			[0, 42]);
		train.animation.addByPrefix('come', 'Train come', 24, false);
		addInteractable(train);

		if (firstTime)
		{
			train.visible = false;
			train.animation.finishCallback = function(anim)
			{
				train.animation.play('idle');
				allowInput = true;
				train.animation.finishCallback = null;
			}

			new FlxTimer().start(0.5, (t) ->
			{
				train.animation.play('come');
				train.visible = true;
			});
		}
		else
		{
			allowInput = true;
			train.animation.play('idle');
		}

		train.callback = () ->
		{
			FlxG.switchState(new StoryMenuState());
		}

		var mainBG:MenuBG = new MenuBG("newMain/subway_bg", 0, -12, 0.7);
		add(mainBG);

		var options = new Interactable('newMain/options', 915.5, 580.55, 0.7, 'options notselected', 'options selected',
			new InteractHitbox(915.5, 580.55, 365, 105), [0, 34]);
		options.callback = function()
		{
			FlxTween.tween(FlxG.camera, {y: -60}, 2);
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, () ->
			{
				FlxG.switchState(new options.OptionsState());
			});
		}
		addInteractable(options);

		var credits = new Interactable('newMain/credits', -10, 45, 0.7, 'credits notselected', 'credits selected', new InteractHitbox(40, 175, 225, 525),
			[216, 172], true, "newMain/creditstext", "credits text", [300, 140]);
		addInteractable(credits);

		var freeplay = new Interactable('newMain/freeplay', 1100, 160, 0.7, 'Freeplay not selected', 'Freeplay selected',
			new InteractHitbox(1100, 160, 145, 225), [256, 170]);
		freeplay.callback = FlxG.switchState.bind(new SelectingSongState());
		addInteractable(freeplay);

		var boombox = new Interactable('newMain/boombox', 779, 433, 0.7, 'boombox not selected', 'boombox selected', new InteractHitbox(779, 433, 165, 135),
			[0, 5], true, "newMain/boomboxtext", "boombox text", [639, 520]);
		addInteractable(boombox);

		var costumes = new Interactable('newMain/costumes', 505, 580, 0.7, 'costume notselected', 'costume selected', new InteractHitbox(505, 580, 240, 115),
			[83, 102]);
		addInteractable(costumes);

		var extras = new Interactable('newMain/extra', 839, 210, 0.7, 'extras notselected', 'extras selected', new InteractHitbox(839, 210, 150, 175),
			[258, 258], true, "newMain/extratext", "extra text", [990, 190], 0.23);
		addInteractable(extras);

		var versionShit:FlxText = new FlxText(0, 0, 0, 'Friday Night Fever ${FlxG.stage.application.meta.get("version")}', 12);
		versionShit.setFormat("Plunge", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.setPosition(FlxG.width - versionShit.width - 10, FlxG.height - versionShit.height - 10);
		versionShit.antialiasing = true;
		versionShit.alpha = 0.38;
		add(versionShit);

		add(hand);

		order = [
			credits.hitbox,
			train.hitbox,
			costumes.hitbox,
			boombox.hitbox,
			extras.hitbox,
			options.hitbox,
			freeplay.hitbox
		];

		firstTime = false;
	}
}
