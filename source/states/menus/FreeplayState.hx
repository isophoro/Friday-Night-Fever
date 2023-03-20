package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

#if windows
import meta.Discord.DiscordClient;
#end

@presence("In the Freeplay Menu.")
class FreeplayState extends MusicBeatState
{
	@:allow(states.FreeplayMenu)
	public static var loading:Bool = false;

	public var selectingFrenzy:Bool = false;

	var allowInput:Bool = true;

	var classic:FlxSprite;
	var frenzy:FlxSprite;

	var peeps:FlxSprite;
	var feva:Character;
	var peppa:Character;
	var hands:FlxSprite;

	var b3:FlxSprite;
	var sb:FlxSprite;
	var rc:FlxSprite;

	var enter:FlxSprite;
	var waitTimer:Float = 0;

	override function create()
	{
		super.create();
		persistentUpdate = true;
		persistentDraw = true;

		PlayState.deaths = 0;

		if (FlxG.sound.music == null || FlxG.sound.music != null && !FlxG.sound.music.playing || FlxG.sound.music != null && FlxG.sound.music.volume < 0.1)
		{
			Main.playFreakyMenu();
		}

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));
		bg.antialiasing = true;
		add(bg);

		peeps = new FlxSprite(19, 65);
		peeps.frames = Paths.getSparrowAtlas('freeplay/peeps');
		peeps.animation.addByPrefix('bop', 'people', 24, false);
		peeps.animation.play("bop");
		peeps.origin.set(0, 0);
		peeps.scale.set(0.67, 0.67);
		peeps.antialiasing = true;
		add(peeps);

		var chairs:FlxSprite = new FlxSprite(319, 134).loadGraphic(Paths.image('freeplay/chairs'));
		chairs.antialiasing = true;
		add(chairs);

		feva = new Character(742, 115, "bf-freeplay", true);
		add(feva);

		peppa = new Character(154, 291, "pepper-freeplay", false);
		add(peppa);

		var table:FlxSprite = new FlxSprite(257, 385).loadGraphic(Paths.image('freeplay/table'));
		table.antialiasing = true;
		add(table);

		hands = new FlxSprite(259, 16);
		hands.frames = Paths.getSparrowAtlas("characters/pepper/hands", "shared");
		hands.animation.addByPrefix("idle", "pepper", 24, false);
		hands.animation.play('idle');
		hands.scale.set(0.67, 0.67);
		hands.antialiasing = true;
		add(hands);

		classic = new FlxSprite(609, 456);
		classic.frames = Paths.getSparrowAtlas("freeplay/classicm");
		classic.animation.addByPrefix("n", "Classicn", 0);
		classic.animation.addByPrefix("s", "Classics", 0);
		classic.animation.play('n');
		classic.scale.set(0.67, 0.67);
		classic.antialiasing = true;
		add(classic);

		frenzy = new FlxSprite(374, 456);
		frenzy.frames = Paths.getSparrowAtlas("freeplay/frenzym");
		frenzy.animation.addByPrefix("n", "Frenzyn", 0);
		frenzy.animation.addByPrefix("s", "Frenzys", 0);
		frenzy.animation.play('n');
		frenzy.scale.set(0.67, 0.67);
		frenzy.antialiasing = true;
		add(frenzy);

		changeSelection(true);
	}

	override function add(obj:flixel.FlxBasic)
	{
		if (Reflect.field(obj, "scrollFactor") != null)
			cast(obj, FlxSprite).scrollFactor.set(0, 0);

		return super.add(obj);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		Conductor.songPosition = FlxG.sound.music.time;

		if (!allowInput)
			return;

		if (controls.LEFT_P || controls.RIGHT_P)
		{
			changeSelection();
			waitTimer = 0;
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			allowInput = false;
			waitTimer = 0;
			openSubState(new FreeplayMenu(selectingFrenzy));
		}

		if (waitTimer >= 20 && allowInput)
		{
			FreeplayMenu.loadSong(selectingFrenzy ? "Mechanical" : "Erm", 2);
		}
		else if (allowInput)
			waitTimer += elapsed;
	}

	override function closeSubState()
	{
		if (!loading && !allowInput)
		{
			allowInput = true;
		}
		else if (loading)
		{
			loading = false;

			if (PlayState.SONG.song.toLowerCase() == "mechanical" || PlayState.SONG.song.toLowerCase() == "erm")
			{
				LoadingState.loadAndSwitchState(new PlayState(true));
				return;
			}

			FlxG.camera.scroll.set(0, 0);
			enter = new FlxSprite(0, 290);
			enter.frames = Paths.getSparrowAtlas("freeplay/freeplayenter");
			enter.animation.addByPrefix("cover", "cover", 24, false);
			enter.animation.play("cover");
			enter.animation.pause();
			enter.antialiasing = true;
			enter.scale.set(0.67, 0.67);
			add(enter);
			enter.screenCenter(X);

			for (i in members)
			{
				if (Reflect.field(i, "scrollFactor") != null)
					cast(i, FlxSprite).scrollFactor.set(1, 1);
			}

			enter.alpha = 0;
			enter.y -= 60;
			FlxTween.tween(enter, {y: enter.y + 60, alpha: 1}, 0.4, {
				onComplete: (t) ->
				{
					enter.animation.resume();
					new FlxTimer().start(0.9, (t) ->
					{
						FlxTween.tween(FlxG.camera, {"scroll.y": 175, zoom: 12}, 0.6, {ease: FlxEase.cubeInOut});
					});
					enter.animation.finishCallback = (a) ->
					{
						LoadingState.loadAndSwitchState(new PlayState(true));
					}
				}
			});
		}

		super.closeSubState();
	}

	function changeSelection(mute:Bool = false)
	{
		selectingFrenzy = !selectingFrenzy;

		frenzy.animation.play(selectingFrenzy ? "s" : "n");
		classic.animation.play(selectingFrenzy ? "n" : "s");

		if (!mute)
			FlxG.sound.play(Paths.sound("menu/general-interact"));
	}

	override function beatHit()
	{
		peeps.animation.play("bop");
		hands.animation.play("idle");
		peppa.dance();
		feva.dance();
	}
}
