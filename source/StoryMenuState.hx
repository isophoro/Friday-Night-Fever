package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import states.InteractableState;
#if windows
import Discord.DiscordClient;
#end

class StoryMenuState extends InteractableState
{
	public static var weekData(get, never):Array<Array<String>>;

	public static function get_weekData():Array<Array<String>>
	{
		return [
			['Milk-Tea'],
			['Metamorphosis', 'Void', 'Down-bad'],
			['Star-Baby', 'Last-Meow', 'Bazinga', 'Crucify'],
			['Prayer', 'Bad-Nun'],
			['Mako', 'VIM', "Retribution"],
			['Honey', "Bunnii", "Throw-it-back"],
			['Mild', 'Spice', 'Party-Crasher'],
			['Ur-girl', 'Chicken-sandwich', 'Funkin-god'],
			['Hallow', 'Portrait', 'Soul'],
			['C354R', 'Loaded', 'Gears'],
			['Tranquility', 'Princess', 'Banish']
		];
	}

	override function create()
	{
		super.create();

		allowInput = true;
		persistentUpdate = persistentDraw = true;
		FlxG.camera.zoom = 0.91; // i fucked up scaling this stuff so we zooming out
		FlxG.camera.scroll.y = 20;

		PlayState.deaths = 0;

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music == null || FlxG.sound.music != null && !FlxG.sound.music.playing || FlxG.sound.music != null && FlxG.sound.music.volume <= 0.1)
		{
			Main.playFreakyMenu();
		}

		var bg:MenuBG = new MenuBG("story/bg_og", -84, -30, 0.75);
		add(bg);

		// roll swapped the animation names by accident gkldfjklxnvkl mvrme oimvcmcx;vmxcv lmcxklfvdgmdklm gkldfmgklmfsdkgl mksfdg
		var tutorial = new Interactable('story/buildings/tutorial', 567, 109, 0.75, 'tutorialselected', 'tutorialnonselected',
			new InteractHitbox(552, 86, 105, 80), [147, 78], true);

		var week1 = new Interactable('story/buildings/week1', 552, 126, 0.75, 'week1notselected', 'week1selected', new InteractHitbox(552, 166, 125, 168),
			[108, 105], true);
		addInteractable(week1);
		addInteractable(tutorial);

		var week2 = new Interactable('story/buildings/week2', 263, 316, 0.75, 'week2notselected', 'week2selected', new InteractHitbox(263, 316, 223, 246),
			[34, 49], true);
		addInteractable(week2);

		var week2_5 = new Interactable('story/buildings/week2_5', -36, 133, 0.75, 'week2.5notselected', 'week2.5selected',
			new InteractHitbox(-36, 133, 170, 263), [7.5, 0], true);
		addInteractable(week2_5);

		var week3 = new Interactable('story/buildings/week3', 237, 542, 0.75, 'week3notselected', 'week3selected', new InteractHitbox(237, 542, 328, 249),
			[0, 59], true);
		addInteractable(week3);

		var week4 = new Interactable('story/buildings/week4', 664, 563, 0.75, 'week4notselected', 'week4selected', new InteractHitbox(664, 563, 258, 116),
			[24, 71], true);
		addInteractable(week4);

		var week5 = new Interactable('story/buildings/week5', 987, 362, 0.75, 'week5notselected', 'week5selected', new InteractHitbox(987, 362, 188, 169),
			[44, 65], true);
		addInteractable(week5);

		var week6 = new Interactable('story/buildings/week6', 860, 112, 0.75, 'week6notselected', 'week6selected', new InteractHitbox(860, 112, 135, 218),
			[69, 68], true);
		addInteractable(week6);

		add(hand);

		order = [
			tutorial.hitbox,
			week1.hitbox,
			week2.hitbox,
			week2_5.hitbox,
			week3.hitbox,
			week4.hitbox,
			week5.hitbox,
			week6.hitbox
		];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (allowInput && controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}
	}

	override function addInteractable(i:Interactable)
	{
		super.addInteractable(i);
		i.callback = () ->
		{
			openSubState(new states.WeekPreviewSubState(order.indexOf(i.hitbox)));
		}
	}

	override function closeSubState()
	{
		super.closeSubState();

		if (curSelected != null)
		{
			onMouseLeave(curSelected);
			curSelected = null;
		}

		allowInput = true;
	}
}
