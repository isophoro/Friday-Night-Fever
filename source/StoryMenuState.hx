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
	public static var minusWeekData(get, never):Map<Int, Array<String>>;
	public static var isFrenzy:Bool = false;

	public static function get_weekData():Array<Array<String>>
	{
		return [
			['Milk-Tea'],
			['Peastep', 'Eros', 'Down-Horrendous'],
			['Star-Baby', 'Last-Meow', 'Bazinga', 'Crucify'],
			['Prayer', 'Bad-Nun'],
			['Mako', 'VIM', "Retribution"],
			['Honey', "Bunnii", "Throw-It-Back"],
			['Mild', 'Spice', 'Party-Crasher'],
			['Ur-Girl', 'Chicken-Sandwich', 'Funkin-God'],
			['Hallow', 'Eclipse', 'SOUL', 'Dead-Mans-Melody'],
			['C354R', 'Loaded', 'Gears'],
			['Tranquility', 'Princess', 'Crack', 'Bloom'],
			['DUI', 'Cosmic-Swing', 'Cell-From-Hell', 'W00F']
		];
	}

	public static function get_minusWeekData():Map<Int, Array<String>>
	{
		return [2 => ["Feel-The-Rage"], 9 => ["Grando"]];
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

		if (!isFrenzy)
			loadClassic();
		else
			loadFrenzy();

		add(hand);
	}

	function loadFrenzy()
	{
		var bg:MenuBG = new MenuBG("story/bg_frenzy", -84, -30, 1);
		add(bg);

		var hallow = new Interactable('story/buildings/weekhallow', -71, 280, 0.75, 'week ?nselected', 'week ?selected',
			new InteractHitbox(40, 357, 479, 363), [0, 24], true);

		var robo = new Interactable('story/buildings/week7', 538, -2, 0.75, 'week 7nselected', 'week 7selected', new InteractHitbox(538, -2, 161, 524),
			[148, 0], true);

		var scarlet = new Interactable('story/buildings/week8', 768, 292, 0.75, 'week 8nselected', 'week 8selected', new InteractHitbox(768, 292, 486, 524),
			[0, 76], true);

		var roll = new Interactable('story/buildings/weekroll', 620, 575, 0.75, 'week arnselected', 'week arselected', new InteractHitbox(631, 582, 149, 134),
			[64, 116], true);

		addInteractable(robo);
		addInteractable(hallow);
		addInteractable(scarlet);
		addInteractable(roll);

		var frontBG:MenuBG = new MenuBG("story/bg_frenzy_front", -84, -30, 1);
		add(frontBG);

		order = [hallow.hitbox, robo.hitbox, scarlet.hitbox, roll.hitbox];
	}

	function loadClassic()
	{
		var bg:MenuBG = new MenuBG("story/bg_og", -84, -30, 1);
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
			FlxG.switchState(new states.BrochureMenu());
		}
	}

	override function addInteractable(i:Interactable)
	{
		super.addInteractable(i);
		i.callback = () ->
		{
			openSubState(new states.WeekPreviewSubState((isFrenzy ? 8 : 0) + order.indexOf(i.hitbox)));
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

	override function onMouseHover(item:InteractHitbox)
	{
		super.onMouseHover(item);

		if (curSelected != null)
		{
			FlxG.sound.play(Paths.sound("hover"), 0.7);
		}
	}
}
