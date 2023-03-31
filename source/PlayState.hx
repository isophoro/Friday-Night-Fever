package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import meta.Discord.DiscordClient;
import meta.Ratings.JudgedRatings;
import meta.Song.SwagSong;
import openfl.display.BlendMode;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.system.System;
import scripting.*;
import shaders.*;
import sprites.objects.Note.QueuedNote;

using StringTools;

#if (flixel < "5.0.0")
import flixel.math.FlxPoint;
#else
import flixel.math.FlxPoint.FlxBasePoint as FlxPoint;
#end
#if (sys && !mobile)
import sys.FileSystem;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public static var curStage:String = '';
	public static var endingSong:Bool;

	public var curSong(get, never):String;

	private function get_curSong():String
		return SONG.song;

	private var vocals:FlxSound;

	public var startingSong:Bool = false;
	public var inCutscene:Bool = false;

	public var gfSpeed:Int = 1;

	private var executeModchart = false;

	public static var skipDialogue:Bool = false;

	public var curOpponent:Character; // these two variables are for the "swapping sides" portion
	public var curPlayer:Character; // just use the dad / boyfriend variables so stuff doesnt break

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	private var camPause:FlxCamera;

	public var defaultCamZoom:Float = 1.05;
	public var camZooming:Bool = false;
	public var disableCamera:Bool = false;
	public var disableModCamera:Bool = false; // disables the modchart from messing around with the camera
	public var camFollow:FlxObject = new FlxObject(0, 0, 1, 1);

	public var filters:Array<BitmapFilter> = [];

	public var useDirectionalCamera:Bool = false;
	public var directionalCameraDist:Int = 15;

	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; // we do a little backporting

	public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();

	private var unspawnNotes:Array<QueuedNote> = [];

	public var strumLine:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>(8);
	public var playerStrums:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>(4);
	public var cpuStrums:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>(4);

	public var health(default, set):Float = 1;
	public var combo:Int = 0;

	public var accuracy:Float = 0;

	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	public var totalRatings:JudgedRatings = {
		shits: 0,
		bads: 0,
		goods: 0
	};

	public var misses:Int = 0;

	public static var deaths:Int = 0;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	#end

	// stage sprites
	public var purpleOverlay:FlxSprite;
	public var church:FlxSprite; // week 2.5 / bad nun

	var spookyBG:FlxSprite; // week 2
	var dark:FlxSprite;
	var moreDark:FlxSprite;
	var bgGirls:BackgroundGirls; // week 6

	public var roboStage:LoadedStage;
	public var roboForeground:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	// HEALTH BAR
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var songPosBar:SongPosBar;
	public var scoreTxt:ScoreText;
	public var subtitles:Subtitles;

	public var splashGrp:FlxTypedGroup<NoteSplash> = new FlxTypedGroup<NoteSplash>(4);
	public var ratingsGrp:FlxTypedGroup<ComboRating> = new FlxTypedGroup<ComboRating>(ComboRating.MAX_RENDERED);
	public var numbersGrp:FlxTypedGroup<ComboNumber> = new FlxTypedGroup<ComboNumber>(ComboNumber.MAX_RENDERED);
	public var currentTimingShown:TimingText;

	public var usePixelAssets(default, set):Bool = false;

	function set_usePixelAssets(set:Bool)
	{
		usePixelAssets = set;
		ratingsGrp.forEach(function(obj)
		{
			obj.loadFrames();
		});
		ratingsGrp.maxSize = usePixelAssets ? 1 : ComboRating.MAX_RENDERED;
		numbersGrp.forEach(function(obj)
		{
			obj.loadFrames();
		});
		numbersGrp.maxSize = usePixelAssets ? 3 : ComboNumber.MAX_RENDERED;
		return set;
	}

	var vignette:FlxSprite;

	var meat:Character;

	var songScript:HaxeScript;
	var curSection:Int = 0;

	public var canHey:Bool = true;
	public var gotSmushed:Bool = false; // death stuff

	public function new(clearMemory:Bool = false, ?prevCamFollow:FlxObject)
	{
		super(clearMemory);

		if (prevCamFollow != null)
			camFollow = prevCamFollow;
	}

	override public function create()
	{
		instance = this;
		endingSong = false;
		persistentUpdate = true;
		persistentDraw = true;

		#if cpp
		executeModchart = FlxG.save.data.disableModCharts ? false : FileSystem.exists(Paths.lua(SONG.song.toLowerCase() + "/modchart"));
		#end

		if (!isStoryMode || StoryMenuState.get_weekData()[storyWeek][0].toLowerCase() == SONG.song.toLowerCase())
		{
			Main.clearMemory();
		}

		super.create();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		CoolUtil.fillTypedGroup(ratingsGrp, ComboRating, ComboRating.MAX_RENDERED, camHUD);
		CoolUtil.fillTypedGroup(numbersGrp, ComboNumber, ComboNumber.MAX_RENDERED, camHUD);
		CoolUtil.fillTypedGroup(splashGrp, NoteSplash, NoteSplash.MAX_RENDERED, camHUD);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));
		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));

		#if windows
		// Discord Rich Presence
		storyDifficultyText = Difficulty.data[storyDifficulty].name;

		iconRPC = switch (SONG.player2)
		{
			case 'taki':
				'monster';
			case 'peasus':
				'dad';
			case 'robofvr-final':
				'roboff';
			default:
				SONG.player2.split('-')[0]; // To avoid having duplicate images in Discord assets
		}

		detailsText = isStoryMode ? ("Story Mode: Week " + storyWeek) : "Freeplay";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.getDiscordPreview(),
			"\nAcc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Misses: "
			+ misses, iconRPC);
		#end

		currentTimingShown = new TimingText();
		currentTimingShown.cameras = [camHUD];

		if (ClientPrefs.shaders)
		{
			camGame.setFilters(filters);
			camGame.filtersEnabled = true;
			camHUD.filtersEnabled = true;
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (ClientPrefs.subtitles)
		{
			var subtitleString:String = SONG.song.toLowerCase() + '/subtitles';

			if (CoolUtil.fileExists(Paths.json(subtitleString)))
			{
				subtitles = new Subtitles(FlxG.height * 0.68, haxe.Json.parse(CoolUtil.getFile(Paths.json(subtitleString))));
			}
		}

		gf = new Character(400, 130, SONG.gfVersion == null ? 'gf' : SONG.gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		boyfriend = new Boyfriend(770, SONG.player1 == "bf" ? 400 : 450, SONG.player1);

		var dadCharacter = SONG.player2;
		if (SONG.player2 == "peasus" && Song.isChildCostume)
			dadCharacter = "peakek"; // no weird stuff

		dad = new Character(100, 100, dadCharacter);

		switch (SONG.stage)
		{
			default:
				if (SONG.stage == null)
					curStage = "stage";
				else
					curStage = SONG.stage;

				var stageScript:HaxeScript = new HaxeScript('assets/stages/$curStage.hx', "stage");
				addScript(stageScript);
				stageScript.callFunction("onCreate");
			case 'halloween':
				{
					curStage = 'halloween';
					defaultCamZoom = 0.6;

					spookyBG = new FlxSprite(-200, -100).loadGraphic(Paths.image('spooky', 'week2'));
					spookyBG.antialiasing = true;

					var city:FlxSprite = new FlxSprite(-290, -180).loadGraphic(Paths.image('city', 'week2'));
					city.antialiasing = true;
					city.scrollFactor.set(0.8, 0.8);

					add(city);
					add(spookyBG);
				}
			case 'church':
				{
					curStage = 'church';
					defaultCamZoom = 0.5;

					church = new FlxSprite(-200, -100).loadGraphic(Paths.image('bg_taki'));
					church.antialiasing = true;
					add(church);
				}
			case 'halloween2':
				{
					curStage = 'halloween2';
					defaultCamZoom = 0.6;

					var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('week2bgtaki'));
					bg.antialiasing = true;
					add(bg);
				}
			case 'robocesbg':
				{
					curStage = 'robocesbg';
					roboStage = new LoadedStage();
					add(roboStage);
				}
			case 'school':
				{
					defaultCamZoom = 0.94;
					curStage = 'school';
					usePixelAssets = true;

					var bgSky = new FlxSprite(0, -200).loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.9, 0.9);
					add(bgSky);

					var bgSchool:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.9, 0.9);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(bgSchool.x).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.9, 0.9);
					add(bgStreet);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);

					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();

					if (SONG.song.toLowerCase() != 'space-demons')
					{
						bgGirls = new BackgroundGirls(-1205, -290);
						bgGirls.scrollFactor.set(0.9, 0.9);

						if (SONG.song.toLowerCase() == 'chicken-sandwich')
						{
							bgGirls.getScared();
						}

						bgGirls.setGraphicSize(Std.int(bgGirls.width * 6));
						bgGirls.updateHitbox();
						add(bgGirls);
					}

					var bgFront:FlxSprite = new FlxSprite(bgSchool.x).loadGraphic(Paths.image('weeb/weebfront', 'week6'));
					bgFront.scrollFactor.set(0.9, 0.9);
					add(bgFront);

					var bgOverlay:FlxSprite = new FlxSprite(bgSchool.x).loadGraphic(Paths.image('weeb/weeboverlay', 'week6'));
					bgOverlay.scrollFactor.set(0.9, 0.9);
					add(bgOverlay);

					bgFront.setGraphicSize(widShit);
					bgOverlay.setGraphicSize(widShit);

					bgFront.updateHitbox();
					bgOverlay.updateHitbox();
				}
			case 'schoolEvil':
				{
					curStage = 'schoolEvil';
					usePixelAssets = true;

					var bg:FlxSprite = new FlxSprite(400, 200);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
		}

		if (curStage == "schoolEvil")
			meat = new Character(260, 100.9, 'meat');

		switch (SONG.player2)
		{
			case 'toothpaste':
				dad.scrollFactor.set(0.9, 0.9);
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case "spooky":
				dad.y -= 30;
				dad.x -= 50;
			case "feralspooky":
				dad.y -= 160;
				dad.x -= 50;
			case "feverbob":
				dad.y += 400;
				dad.x += 300;
			case "taki":
				dad.y += 160;
				dad.x += 230;
			case "monster":
				dad.y += 180;
				dad.x += 300;
				if (SONG.song.toLowerCase() == 'prayer' || SONG.song.toLowerCase() == 'bad-nun')
				{
					dad.y = 620;
					dad.x = 388;
				}
			case 'pepper':
				dad.y += 100;
				dad.x -= 100;
				dad.scrollFactor.set(0.9, 0.9);
			case 'peakek':
				dad.y += 60;
				dad.x -= 100;
			case 'peasus':
				dad.y += 60;
				dad.x -= 100;
			case 'mako':
				dad.y += 445;
				dad.x += 25;
			case 'parents-christmas':
				dad.x -= 500;
			case 'bdbfever':
				dad.x += 80;
				dad.y += 560;
				dad.scrollFactor.set(0.9, 0.9);
			case 'mega' | 'mega-angry':
				dad.x += 150;
				dad.y += 320;
				dad.scrollFactor.set(0.9, 0.9);
			case 'flippy':
				dad.y += 300;
				dad.x += 100;
			case 'mako-demon': // 275 350
				dad.y += 250;
				dad.x -= 15;
			case 'mom-car' | 'mom-carnight':
				dad.x -= 30;
				dad.y -= 165;
			case 'yukichi':
				dad.y += 240;
				dad.x -= 130;
				dad.scrollFactor.set(0.9, 0.9);
			case 'robo-cesar':
				dad.x = -365;
				dad.y = 365.3;
				dad.scrollFactor.set(0.9, 0.9);
			case 'scarlet-final':
				dad.x -= 450;
				dad.y -= 500;
				dad.scrollFactor.set(0.9, 0.9);
		}

		curPlayer = boyfriend;
		curOpponent = dad;

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'cave':
				gf.visible = false;

				boyfriend.x = 2535.35;
				boyfriend.y = 1290.3;

				var evilTrail = new CharacterTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);

				dad.x = 1000.3;
				dad.y = 1310;
			case 'fireplace':
				boyfriend.scrollFactor.set(0.9, 0.9);
				boyfriend.x += 300;
				gf.x += 300;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 150;
				gf.x += 180;
				gf.y += 300;
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.scrollFactor.set(0.9, 0.9);
			case 'schoolEvil':
				var evilTrail = new CharacterTrail(dad, null, 4, 24, 0.1, 0.069);
				add(evilTrail);
				boyfriend.x += 290;
				boyfriend.y += 40;
				gf.x += 180;
				gf.y += 300;
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.scrollFactor.set(0.9, 0.9);
			case 'stage':
				boyfriend.x += 200;
				dad.y -= 45;
			case 'halloween':
				boyfriend.x += 500;
				boyfriend.y += 155;
				gf.x += 300;
				gf.y += 80;
				gf.scrollFactor.set(1.0, 1.0);
			case 'church':
				boyfriend.x = 1828;
				boyfriend.y = 1148;
				gf.x = 948;
				gf.y = 722;
				gf.scrollFactor.set(1.0, 1.0);
			case 'train':
				boyfriend.x = 2850;
				boyfriend.y = 380;
				dad.x += 1850;
				dad.y -= 500;
				boyfriend.scrollFactor.set(0.9, 0.9);
			case 'halloween2':
				boyfriend.x = 1086.7;
				boyfriend.y = 604.7;
				gf.x = 524;
				gf.y = 245;
				gf.scrollFactor.set(1.0, 1.0);
			case 'hallow':
				boyfriend.x += 500;
				boyfriend.y += 155;
				gf.x += 300;
				gf.y += 80;
				gf.scrollFactor.set(1.0, 1.0);

				var evilTrail = new CharacterTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
			case 'diner':
				boyfriend.x += 100;
				boyfriend.y += 165;
				boyfriend.scrollFactor.set(0.9, 0.9);
				dad.y += 100;
				gf.x -= 70;
				gf.y += 200;
				gf.scrollFactor.set(0.9, 0.9);
			case 'melonpatch':
				boyfriend.x += 180;
				boyfriend.y -= 45;
				gf.x -= 35;
				dad.x += 15;
			case 'robocesbg':
				boyfriend.x = 1085.2;
				boyfriend.y = 482.3;
				gf.x = 227;
				gf.y = 149;
				dad.x += 100;
				dad.y -= 50;
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.scrollFactor.set(0.9, 0.9);
			case 'alleyway':
				boyfriend.x = 1085.2;
				boyfriend.y = 375;
				gf.x = 327;
				gf.y = 40;
				dad.y += 45;
				dad.x -= 150;
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.scrollFactor.set(0.9, 0.9);
			case 'lab':
				gf.scrollFactor.set(1, 1);
				dad.setPosition(100, -400);
				gf.setPosition(800, 0);
				boyfriend.setPosition(1500, 270);
		}

		if (SONG.song.toLowerCase() == 'bazinga' || SONG.song.toLowerCase() == 'crucify')
		{
			gf.y -= 15;
			gf.x += 180;
			boyfriend.x += 140;
			dad.x += 95;
			dad.y -= 40;
			boyfriend.y -= 35;
		}

		add(gf);

		if (curStage == 'schoolEvil')
		{
			add(meat);
			FlxTween.circularMotion(meat, 300, 200, 50, 0, true, 4, true, {type: LOOPING});
		}
		add(dad);

		add(boyfriend);

		if (roboStage != null)
		{
			add(roboStage.foreground);
			roboStage.switchStage(roboStage.curStage);
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxObject(0, ClientPrefs.downscroll ? FlxG.height - 150 : 50, FlxG.width, 10);
		add(strumLineNotes);

		add(notes);
		add(currentTimingShown);

		inline generateSong();

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;

		healthBarBG = new FlxSprite(0, FlxG.height * (ClientPrefs.downscroll ? 0.1 : 0.9)).makeGraphic(601, 19, FlxColor.BLACK);
		healthBarBG.screenCenter(X);
		healthBarBG.antialiasing = true;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.createFilledBar(FlxColor.fromString('#FF' + curOpponent.iconColor), FlxColor.fromString('#FF' + curPlayer.iconColor));
		healthBar.antialiasing = true;
		add(healthBar);

		scoreTxt = new ScoreText(healthBarBG.y + 35);
		updateScoring();

		FlxG.signals.gameResized.add(onGameResize);

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		add(scoreTxt);

		if (curStage == 'church')
		{
			purpleOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.PURPLE);
			purpleOverlay.alpha = 0.33;
			add(purpleOverlay);
			purpleOverlay.cameras = [camHUD];
			purpleOverlay.scale.set(1.5, 1.5);
			purpleOverlay.scrollFactor.set();

			purpleOverlay.alpha = 0.21;
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];

		if (subtitles != null)
		{
			subtitles.cameras = [camHUD];
			add(subtitles);
		}

		switch (SONG.song.toLowerCase())
		{
			case 'party-crasher':
				dark = new FlxSprite(0, 0).loadGraphic(Paths.image('effectShit/darkShit'));
				dark.cameras = [camHUD];
				add(dark);
				dark.visible = false;
			case 'bazinga' | 'crucify' | 'hallow' | 'hardships' | 'old-hardships' | 'portrait' | 'run':
				moreDark = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
				moreDark.alpha = 0.498;
				moreDark.scale.scale(1.5);
				moreDark.cameras = [camHUD];
				add(moreDark);
			case 'prayer':
				vignette = new FlxSprite().loadGraphic(Paths.image("vignette"));
				vignette.cameras = [camHUD];
				add(vignette);
				vignette.alpha = 0;
		}

		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		startingSong = true;

		var cutscenePath:String = 'assets/data/${SONG.song.toLowerCase()}/cutscene.hx';
		if (Assets.exists(cutscenePath))
		{
			inCutscene = true;
			var cutsceneScript:HaxeScript = new HaxeScript(cutscenePath, "cutscene");
			addScript(cutsceneScript);
			cutsceneScript.callFunction("onCreate");
		}
		else if (isStoryMode && !skipDialogue || curSong == "Shadow" && !skipDialogue)
		{
			switch (curSong.toLowerCase())
			{
				case 'bazinga':
					inCutscene = true;
					var culo:Bool = FlxG.random.bool(1);

					var jumpscare:FlxSprite = new FlxSprite(0, 0);
					jumpscare.frames = Paths.getSparrowAtlas('dialogue_backgrounds/jumpscare' + (culo ? "RARE" : ""));
					jumpscare.animation.addByPrefix('idle', 'jumpscare', 24, false);
					jumpscare.cameras = [camHUD];
					jumpscare.updateHitbox();
					add(jumpscare);

					jumpscare.animation.play('idle');
					FlxG.sound.play(Paths.sound(culo ? 'BOOM' : 'jumpscare', 'shared'));

					camHUD.visible = true;
					new FlxTimer().start(1.4, function(tmr:FlxTimer)
					{
						jumpscare.destroy();
						openDialogue();
					});
				default:
					if (curSong.toLowerCase() == 'chicken-sandwich')
						FlxG.sound.play(Paths.sound('ANGRY'));

					openDialogue();
			}
		}
		else
		{
			startCountdown();
		}

		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		for (i in [false, true]) // call both of these so BF_CAM_POS and DAD_CAM_POS are set
			moveCamera(i);

		songScript = new HaxeScript(null, "modchart");
		addScript(songScript);
		songScript.callFunction("onCreate");
		scripts.callFunction("onCreatePost");

		boyfriend.setPosition(boyfriend.x + boyfriend.positionOffset.x, boyfriend.y + boyfriend.positionOffset.y);

		if (camGame.target != null)
		{
			camGame.focusOn(camFollow.getPosition());
			if (!disableCamera)
			{
				moveCamera(!PlayState.SONG.notes[curSection].mustHitSection);
				camGame.focusOn(camFollow.getPosition());
			}
		}

		System.gc();
		onGameResize(FlxG.stage.window.width, FlxG.stage.window.height);
	}

	function openDialogue(?callback:Void->Void):Void
	{
		var dialoguePath = 'assets/data/${SONG.song.toLowerCase()}/dialogue.xml';
		if (!sys.FileSystem.exists(dialoguePath))
		{
			startCountdown();
			return;
		}

		inCutscene = true;
		camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);

		var doof:DialogueBox = new DialogueBox(dialoguePath);
		doof.cameras = [camHUD];
		doof.finishCallback = () ->
		{
			if (callback == null)
			{
				if (songScript != null && songScript.variables.exists("onDialogueFinish"))
					songScript.callFunction("onDialogueFinish", []);
				else
					startCountdown();
			}
			else
				callback();
		}
		add(doof);
	}

	private var startTimer:FlxTimer;

	#if cpp
	public static var luaModchart:LuaScript = null;
	#end

	public function changeStrums(?pixel:Bool) // stolen from yknow that one thing
	{
		if (pixel)
		{
			strumLineNotes.forEach(function(babyArrow:FlxSprite)
			{
				babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
				babyArrow.animation.add('green', [6]);
				babyArrow.animation.add('red', [7]);
				babyArrow.animation.add('blue', [5]);
				babyArrow.animation.add('purplel', [4]);

				babyArrow.setGraphicSize(Std.int(babyArrow.width * 6));
				babyArrow.updateHitbox();
				babyArrow.antialiasing = false;
				switch (babyArrow.ID)
				{
					case 2:
						babyArrow.animation.add('static', [2]);
						babyArrow.animation.add('pressed', [6, 10], 12, false);
						babyArrow.animation.add('confirm', [14, 18], 12, false);
					case 3:
						babyArrow.animation.add('static', [3]);
						babyArrow.animation.add('pressed', [7, 11], 12, false);
						babyArrow.animation.add('confirm', [15, 19], 24, false);
					case 1:
						babyArrow.animation.add('static', [1]);
						babyArrow.animation.add('pressed', [5, 9], 12, false);
						babyArrow.animation.add('confirm', [13, 17], 24, false);
					case 0:
						babyArrow.animation.add('static', [0]);
						babyArrow.animation.add('pressed', [4, 8], 12, false);
						babyArrow.animation.add('confirm', [12, 16], 24, false);
				}
				babyArrow.animation.play('static');
			});
		}
		else
		{
			strumLineNotes.forEach(function(babyArrow:FlxSprite)
			{
				var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

				babyArrow.frames = Paths.getSparrowAtlas('notes/defaultNotes');
				babyArrow.animation.addByPrefix(dataColor[babyArrow.ID], 'arrow' + dataSuffix[babyArrow.ID]);

				var lowerDir:String = dataSuffix[babyArrow.ID].toLowerCase();

				babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[babyArrow.ID]);
				babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
				babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

				babyArrow.antialiasing = true;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
				babyArrow.updateHitbox();
				babyArrow.animation.play('static');
			});
		}
	}

	function startCountdown():Void
	{
		Conductor.songPosition = -Conductor.crochet * 5;
		startedCountdown = true;
		skipDialogue = true;
		inCutscene = false;

		generateStaticArrows(cpuStrums, FlxG.width * 0.25);
		generateStaticArrows(playerStrums, FlxG.width * 0.75, true);

		#if windows
		if (executeModchart)
		{
			luaModchart = new LuaScript();
			luaModchart.executeState('start', [PlayState.SONG.song]);
		}
		#end

		camHUD.bgColor.alpha = Std.int((ClientPrefs.laneTransparency / 100) * 255);
		if (SONG.song.toLowerCase() == 'dead-mans-melody' || SONG.song.toLowerCase() == 'c354r' || SONG.song.toLowerCase() == "gears")
		{
			return;
		}

		var introAssets:Array<String> = ["3", "2", "1", "go"];
		if (curStage.startsWith("school") || usePixelAssets)
			for (i in 0...introAssets.length)
				introAssets[i] += "-pixel";

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			if (curStage == 'schoolEvil')
			{
				meat.dance();
			}
			gf.dance();
			boyfriend.dance();

			var altSuffix:String = "";

			if (introAssets[0].endsWith("-pixel"))
			{
				altSuffix = "-pixel";
			}
			else
			{
				if (SONG.bpm <= 140)
					altSuffix = '-long';
			}

			FlxG.sound.play(Paths.sound('intro' + (swagCounter == 3 ? 'Go' : '${3 - swagCounter}') + altSuffix), 0.6);
			var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image("countdown/" + introAssets[swagCounter]));

			if (introAssets[0].endsWith("-pixel"))
				sprite.setGraphicSize(Std.int(sprite.width * 4.8));
			else if (camHUD.zoom != 1)
				sprite.scale.set(sprite.scale.x * (1 / camHUD.zoom), sprite.scale.y * (1 / camHUD.zoom));

			sprite.screenCenter();
			sprite.cameras = [camHUD];
			add(sprite);

			FlxTween.tween(sprite, {alpha: 0}, Conductor.crochet / 1000, {
				ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					remove(sprite);
					sprite.destroy();
				}
			});

			System.gc();
			swagCounter++;
		}, 4);
	}

	function endingDialogue()
	{
		disableBeathit = true;
		canPause = false;
		inCutscene = true;
		Conductor.changeBPM(0);
		vocals.stop();
		vocals.volume = 0;
		FlxG.sound.music.stop();

		camPause = new FlxCamera();
		camPause.bgColor.alpha = 0;
		FlxG.cameras.add(camPause, false);

		var dialoguePath = 'assets/data/${SONG.song.toLowerCase()}/dialogue-end.xml';
		var doof:DialogueBox = new DialogueBox(dialoguePath);
		doof.fadeOut = false;
		doof.cameras = [camPause];
		doof.finishCallback = endSong;
		add(doof);
	}

	public function startSong():Void
	{
		startingSong = false;

		if (curSong == 'Loaded')
		{
			var video = new VideoHandler();
			canPause = false;
			inCutscene = true;
			video.playVideo(Paths.video("loaded"));
			video.finishCallback = function()
			{
				canPause = true;
				inCutscene = false;
				trace("VIDEO FINISH!");
				video.finishCallback = null;
				video.stop();
				camGame.fade(FlxColor.BLACK, 0.3, true);
			}
		}

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		var dialoguePath = 'assets/data/${SONG.song.toLowerCase()}/dialogue-end.xml';
		if (isStoryMode && sys.FileSystem.exists(dialoguePath))
		{
			FlxG.sound.music.onComplete = endingDialogue;
		}
		else
		{
			FlxG.sound.music.onComplete = endSong;
		}

		vocals.play();

		if (ClientPrefs.boombox)
		{
			vocals.pitch = FlxG.sound.music.pitch = ClientPrefs.songPitch;
		}

		if (ClientPrefs.songPosition)
		{
			songPosBar = new SongPosBar();
			add(songPosBar);

			songPosBar.cameras = [camHUD];
		}

		scripts.callFunction("onSongStart");

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.getDiscordPreview(),
			"\nAcc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Misses: "
			+ misses, iconRPC);
		#end
	}

	private function generateSong():Void
	{
		Conductor.changeBPM(SONG.bpm);

		vocals = new FlxSound();
		FlxG.sound.list.add(vocals);

		var vocalPath:String = Paths.voices(PlayState.SONG.song);
		if (Assets.exists(vocalPath))
			vocals.loadEmbedded(vocalPath, false);

		for (section in SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] < 0 ? 0 : songNotes[0] + ClientPrefs.offset;
				var gottaHitNote:Bool = songNotes[1] > 3 ? !section.mustHitSection : section.mustHitSection;
				var noteData:Int = ClientPrefs.boombox && ClientPrefs.randomNotes ? FlxG.random.int(0, 3) : Std.int(songNotes[1] % 4);

				// Checks if this note is three milliseconds apart from another note.
				// Does the samething as the usual "dumbass note" stuff but instead of being called on key presses it's only done once.
				if (gottaHitNote)
				{
					var dumbNote:Bool = false;
					for (i in unspawnNotes)
					{
						if (i.mustPress && i.noteData == noteData && Math.abs(i.strumTime - daStrumTime) < 3)
						{
							dumbNote = true;
							break;
						}
					}

					if (dumbNote)
						continue;
				}

				unspawnNotes.push({
					strumTime: daStrumTime,
					noteData: noteData,
					mustPress: gottaHitNote,
					sustainLength: songNotes[2],
					type: songNotes[3]
				});
			}
		}

		unspawnNotes.sort((Obj1:QueuedNote, Obj2:QueuedNote) ->
		{
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
		});
	}

	private function generateStaticArrows(grp:FlxTypedGroup<FlxSprite>, centerPoint:Float, isPlayer:Bool = false):Void
	{
		if (grp.length > 0)
			return;

		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (SONG.noteStyle)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * 6));

					switch (i)
					{
						case 0:
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}
				default:
					if (dad.curCharacter == 'SG' && !isPlayer)
						babyArrow.frames = Paths.getSparrowAtlas('NOTE_sg', 'shadow');
					else if (dad.curCharacter.startsWith('scarlet') && !isPlayer || dad.curCharacter.startsWith('robo') && !isPlayer)
						babyArrow.frames = Paths.getSparrowAtlas('notes/ROBO-NOTE_assets');
					else
						babyArrow.frames = Paths.getSparrowAtlas('notes/defaultNotes');

					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (i)
					{
						case 0:
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.x = centerPoint - ((babyArrow.width + 4) * (4 / 2)) + ((babyArrow.width + 4) * i);

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			babyArrow.animation.play('static');
			babyArrow.animation.finishCallback = (anim) ->
			{
				if (anim == 'confirm')
				{
					babyArrow.animation.play('static');
					babyArrow.centerOffsets();
				}
			}

			grp.add(babyArrow);
			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.getDiscordPreview(),
				"Acc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Misses: "
				+ misses, iconRPC);
			#end

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (camPause != null)
			{
				FlxG.cameras.remove(camPause);
				camPause.destroy();
				openfl.system.System.gc();
			}

			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			CoolUtil.setTweensActive(true);

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;

			paused = false;

			#if windows
			if (startTimer == null || startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.getDiscordPreview(),
					"\nAcc: "
					+ FlxMath.roundDecimal(accuracy, 2)
					+ "% | Misses: "
					+ misses, iconRPC, true, FlxG.sound.music.length
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + '($storyDifficultyText)' + Ratings.getDiscordPreview(), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals()
	{
		if (!vocals.playing && !paused)
			return;

		trace('Resyncing vocals and instrumental tracks. (V: ${Math.abs(vocals.time - Conductor.songPosition)} MS) (I: ${Math.abs(FlxG.sound.music.time - Conductor.songPosition)} MS)');

		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;

	public var canPause:Bool = true;

	var iconHurtTimer:Float = 0;

	public var cameraSpeed:Float = 1.3;

	static public var canPressSpace:Bool = false;

	public var spaceDelay:Float = 0;

	var spaceDelayTime:Float = 1; // a second delay

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Using 180 here since that's the framerate I test with
		FlxG.camera.followLerp = elapsed * cameraSpeed * (180 / FlxG.drawFramerate);
		iconHurtTimer -= elapsed;

		scripts.updateVars();

		#if debug
		if (FlxG.keys.anyJustPressed([TWO, THREE, FOUR]))
		{
			songJump(FlxG.keys.justPressed.TWO ? 3 : FlxG.keys.justPressed.THREE ? 10 : 30);
		}
		#end

		if (ClientPrefs.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		#if windows
		if (executeModchart && luaModchart != null && !startingSong)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			if (!disableModCamera)
			{
				FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
				camHUD.angle = luaModchart.getVar('camHudAngle', 'float');
			}

			var showStrums:Bool = !luaModchart.getVar("showOnlyStrums", 'bool');

			for (i in [healthBar, healthBarBG, iconP1, iconP2, scoreTxt])
			{
				i.visible = showStrums;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				playerStrums.members[i].visible = p2;
			}
		}
		#end

		if (!inCutscene)
		{
			if (FlxG.keys.justPressed.SPACE && canHey)
			{
				if (boyfriend.animation.curAnim.name.startsWith("idle"))
					boyfriend.playAnim('hey');

				if (!gf.animation.paused && gf.animation.curAnim.name.startsWith("dance"))
					gf.playAnim('cheer');

				if (dad.animOffsets.exists("hey"))
					dad.playAnim('hey');
			}

			if (FlxG.keys.justPressed.NINE)
			{
				if (iconP1.curCharacter == 'bf-old')
					iconP1.swapCharacter(boyfriend.curCharacter);
				else
					iconP1.swapCharacter('bf-old');
			}
		}

		scripts.callFunction("onUpdate", [elapsed]);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			CoolUtil.setTweensActive(false);

			// Since there's moments where camHUD is hidden / modified, create a new camera JUST for the pause menu.
			camPause = new FlxCamera();
			camPause.bgColor.alpha = 0;
			FlxG.cameras.add(camPause, false);
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN && SONG.song.toLowerCase() != 'shadow')
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		switch (healthBar.fillDirection)
		{
			default:
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - 26);
			case LEFT_TO_RIGHT:
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01) - 26);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01)) - (iconP2.width - 26);
		}

		if (health >= 1.75 && iconHurtTimer <= 0)
		{
			iconP2.animation.play('hurt');
			iconP1.animation.play('winning');
		}
		else if (health <= 0.65 || iconHurtTimer > 0)
		{
			iconP2.animation.play('winning');
			iconP1.animation.play('hurt');
		}
		else
		{
			iconP2.animation.play('healthy');
			iconP1.animation.play('healthy');
		}

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += (FlxG.elapsed * 1000) * FlxG.sound.music.pitch;

			#if windows
			if (luaModchart != null && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, FlxMath.bound(1 - (elapsed * 3.125), 0, 1));
		}

		if (!inCutscene && ClientPrefs.resetButton && FlxG.keys.justPressed.R)
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.getDiscordPreview(),
				"\nAcc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Misses: "
				+ misses, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var data:QueuedNote = unspawnNotes[0];
				var note = notes.recycle(Note);

				note.create(data.strumTime, data.noteData, null, false, data.type, data.mustPress);
				notes.add(note);

				if (data.sustainLength > 0)
				{
					var susLength:Float = data.sustainLength / Conductor.stepCrochet;
					var prevSus:Note = null;

					for (susNote in 0...Math.floor(susLength))
					{
						var sustainNote:Note = notes.recycle(Note);

						sustainNote.create(data.strumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, data.noteData,
							prevSus == null ? note : prevSus, true, data.type, data.mustPress);

						sustainNote.mustPress = data.mustPress;

						notes.add(sustainNote);

						if (prevSus != null)
							prevSus.nextNote = sustainNote;

						prevSus = sustainNote;
					}
				}

				unspawnNotes.shift();
			}
		}

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.type == 1 && daNote.mustPress && !daNote.animPlayed)
			{
				if (daNote.timeDiff <= 750 * FlxG.sound.music.pitch)
				{
					summonPainting();
					daNote.animPlayed = true;
				}
			}

			// trying to do cool modchart stuff and the kade engine code for this stuff was annoying so i rewrote it
			// like there was no reason to tie the sustain note clipping to be disabled when modifiedByLua is true LMAO
			var strum = strumLineNotes.members[(daNote.mustPress ? 4 : 0) + daNote.noteData];
			if (!daNote.modifiedByLua)
			{
				daNote.x = strum.x;
				if (ClientPrefs.downscroll)
					daNote.y = strum.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed / FlxG.sound.music.pitch, 2);
				else
					daNote.y = strum.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed / FlxG.sound.music.pitch, 2);

				daNote.visible = strum.visible;
				if (!daNote.isSustainNote)
					daNote.angle = strum.angle;
				daNote.alpha = daNote.isSustainNote ? (strum.alpha > 0.6 ? 0.6 : strum.alpha) : strum.alpha;
			}

			if (daNote.isSustainNote)
			{
				if (ClientPrefs.downscroll)
				{
					// Remember = minus makes notes go up, plus makes them go down
					if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
						daNote.y = daNote.prevNote.y - daNote.height;
					else
						daNote.y += daNote.height / 2;

					if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
					{
						// Clip to strumline
						daNote.clipRect = FlxRect.weak(0, daNote.frameHeight - (daNote.frameHeight * 2), daNote.frameWidth * 2,
							(cpuStrums.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y);
					}
				}
				else
				{
					daNote.y -= daNote.height / 2;

					if (daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
					{
						// Clip to strumline
						var swagRect = FlxRect.weak(0, (cpuStrums.members[daNote.noteData].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y,
							daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}
			}

			if (!daNote.mustPress && daNote.wasGoodHit)
			{
				if (SONG.song != 'Milk-Tea' && !disableCamera && !disableModCamera)
					camZooming = true;

				var altAnim:String = "";

				if (SONG.notes[Math.floor(curStep / 16)] != null)
				{
					if (SONG.notes[Math.floor(curStep / 16)].altAnim)
						altAnim = '-alt';
				}

				// Accessing the animation name directly to play it
				if (curSong == 'Princess' && (curBeat == 303 || curBeat == 367) && daNote.noteData == 2)
				{
					curOpponent.holdTimer = 0;
					curOpponent.playAnim('singLaugh', true);
				}
				else
				{
					if (daNote.type != 2)
					{
						curOpponent.holdTimer = 0;
						if (daNote.properties.singAnim != null)
							curOpponent.playAnim(daNote.properties.singAnim, true);
						else
							curOpponent.playAnim('sing' + dataSuffix[daNote.noteData] + altAnim, true);

						if (curOpponent.loopedIdle)
						{
							curOpponent.animation.finishCallback = function(name:String)
							{
								curOpponent.dance();
							};
						}
					}
					scripts.callFunction("onOpponentNoteHit", [daNote]);

					if (curStage == 'schoolEvil')
					{
						meat.playAnim('sing' + dataSuffix[daNote.noteData] + altAnim, true);
					}
				}

				if (storyDifficulty != 0)
				{
					switch (dad.curCharacter)
					{
						case 'robo-cesar':
							if (curSong == 'Loaded')
								if (curBeat >= 400 && curBeat < 432)
									health -= 0.01;
						case 'mom-car':
							health -= 0.01;
						case 'mom-carnight':
							health -= 0.02;
						case 'flippy':
							switch (storyDifficulty)
							{
								default:
									health -= 0.02;
								case 0 | 1: // easy and baby mode
									health -= 0.01;
							}
						case 'monster' | 'taki':
							iconHurtTimer = 0.45;
							var mult = storyDifficulty == 1 ? 0.6 : 1;
							switch (curSong)
							{
								case 'Prayer':
									if (curStep >= 1359 && curStep < 1422) // CHAINSAW
										health -= 0.0215 * mult; else if (curStep < 1681) // NORMAL
										health -= health > 0.165 ? 0.0165 * mult : 0.0065 * mult;
								case 'Crucify':
									health -= (daNote.isSustainNote ? 0.01 : 0.025 * mult);
								case 'Bazinga':
									health -= (daNote.isSustainNote ? 0.01435 : 0.025 * mult);
								default:
									health -= 0.02 * mult;
							}

							gf.playAnim('scared');
						case 'SG':
							if (healthBar.percent > 5)
								health -= (daNote.isSustainNote ? 0.03 : 0.02);
						case 'hallow':
							if (healthBar.percent > 5)
							{
								health -= 0.025;
							}
					}
				}
				else if (storyDifficulty == 0)
				{
					health += 0.03;
				}

				cpuStrums.members[daNote.noteData].animation.play('confirm', true);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
				#end

				if (SONG.needsVoices)
					vocals.volume = 1;

				daNote.kill();
				daNote.exists = false;
			}

			if (daNote.isSustainNote)
				daNote.x += daNote.width / 2 + (usePixelAssets ? 10 : 17);

			if (daNote.mustPress && (daNote.strumTime - Conductor.songPosition) < -166 * FlxG.sound.music.pitch)
			{
				if (daNote.type == 0)
				{
					health -= 0.075;
					vocals.volume = 0;
					noteMiss(daNote.noteData);
				}
				else if (daNote.type == 1)
				{
					health = -1;

					vocals.volume = 0;
				}

				daNote.kill();
				daNote.exists = false;
			}
		});

		cpuStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE && FlxG.sound.music != null && FlxG.sound.music.onComplete != null)
			FlxG.sound.music.onComplete();
		#end

		scripts.callFunction("onPostUpdate", [elapsed]);
	}

	public var DAD_CAM_POS:FlxPoint = new FlxPoint(0, 0);
	public var BF_CAM_POS:FlxPoint = new FlxPoint(0, 0);

	public var DAD_CAM_OFFSET:FlxPoint = new FlxPoint(0, 0);
	public var BF_CAM_OFFSET:FlxPoint = new FlxPoint(0, 0);

	public function moveCamera(isDad:Bool = false)
	{
		if (isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

			switch (dad.curCharacter)
			{
				case 'SG':
					camFollow.y = dad.getMidpoint().y - 300;
					camFollow.x = dad.getMidpoint().x - 220;
				case 'mom' | 'mom-carnight' | 'mom-car':
					camFollow.y = dad.getMidpoint().y + 90;
				case 'mega' | 'mega-angry':
					camFollow.y = dad.getMidpoint().y - 80;
					camFollow.x = dad.getMidpoint().x + 175;
				case 'peakek' | 'peasus':
					camFollow.x = dad.getMidpoint().x - -400;
				case 'spooky' | 'feralspooky':
					camFollow.x = dad.getMidpoint().x + 190;
					camFollow.y = dad.getMidpoint().y - 30;
				case 'taki':
					camFollow.x = dad.getMidpoint().x + 155 + (curStage == "church" ? 175 : 0);
					camFollow.y = dad.getMidpoint().y - 50;
				case 'pepper':
					camFollow.y = dad.getMidpoint().y + 65;
					camFollow.x = dad.getMidpoint().x + 290;
				case 'hallow':
					camFollow.x = dad.getMidpoint().x - -500;
					camFollow.y = dad.getMidpoint().y - -100;
				case 'robo-cesar':
					if (roboStage != null)
					{
						switch (roboStage.curStage)
						{
							default:
								camFollow.y = dad.getMidpoint().y - 130;
								camFollow.x = dad.getMidpoint().x + 475;
							case 'c354r-default':
								camFollow.x = dad.getMidpoint().x + 110;
								camFollow.y = dad.getMidpoint().y - 280;
							case 'tricky':
								camFollow.y = dad.getMidpoint().y - 100;
								camFollow.x = dad.getMidpoint().x + 230;
							case 'default' | 'whitty':
								camFollow.y = dad.getMidpoint().y - 290;
								camFollow.x = dad.getMidpoint().x - -490;
						}
					}
					else
					{
						camFollow.y = dad.getMidpoint().y - 150;
						camFollow.x = dad.getMidpoint().x + 490;
					}
				case 'scarlet-final':
					camFollow.x = dad.getMidpoint().x + 275;
					camFollow.y = dad.getMidpoint().y + 50;
				case 'tea-bat':
					camFollow.x = dad.getMidpoint().x - -600;
					camFollow.y = dad.getMidpoint().y - -150;
				case 'yukichi':
					camFollow.x = dad.getMidpoint().x + 240;
					camFollow.y = dad.getMidpoint().y - 150;
				case 'mako' | 'mako-demon':
					camFollow.x = dad.getMidpoint().x - -350;
					camFollow.y = dad.getMidpoint().y - (dad.curCharacter == "mako" ? 185 : 60);
				case 'bdbfever':
					camFollow.x = dad.getMidpoint().x + 200;
					camFollow.y = dad.getMidpoint().y - 80;
				case 'gf':
					camFollow.y = dad.getMidpoint().y - 50;
				case 'flippy':
					camFollow.x = dad.getMidpoint().x + 90;
					camFollow.y = dad.getMidpoint().y - 40;
				case 'robofvr-final':
					camFollow.x = dad.getMidpoint().x - 450;
					camFollow.y = dad.getMidpoint().y + 150;
				case 'taki-minus':
					camFollow.x = dad.getMidpoint().x + 30;
					camFollow.y = dad.getMidpoint().y - 10;
			}

			camFollow.x += DAD_CAM_OFFSET.x;
			camFollow.y += DAD_CAM_OFFSET.y;
			DAD_CAM_POS.set(camFollow.x, camFollow.y);
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'cave':
					camFollow.x = boyfriend.getMidpoint().x - 350;
					camFollow.y = boyfriend.getMidpoint().y - 265;
				case 'stage':
					camFollow.x = boyfriend.getMidpoint().x - 350;
					camFollow.y -= 100;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 130;
					camFollow.y = boyfriend.getMidpoint().y - 85;
				case 'schoolEvil': // 200 , -100
					camFollow.x = boyfriend.getMidpoint().x - 330;
					camFollow.y = boyfriend.getMidpoint().y - 30;
				case 'halloween' | 'halloween2':
					camFollow.x = boyfriend.getMidpoint().x - 355;
					camFollow.y = boyfriend.getMidpoint().y - 250;
				case 'church':
					camFollow.x = boyfriend.getMidpoint().x - 465;
					camFollow.y = boyfriend.getMidpoint().y - 365;
				case 'hallow':
					camFollow.x = boyfriend.getMidpoint().x - 250;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'diner':
					camFollow.x = boyfriend.getMidpoint().x - 350;
					camFollow.y = boyfriend.getMidpoint().y - 180;

				case 'melonpatch':
					camFollow.x = boyfriend.getMidpoint().x - 380;
					camFollow.y = boyfriend.getMidpoint().y - 150;
				case 'alleyway':
					camFollow.y = boyfriend.getMidpoint().y - 330;
					camFollow.x = boyfriend.getMidpoint().x - 450;
				case 'train':
					camFollow.y = boyfriend.getMidpoint().y - 300;
					camFollow.x = boyfriend.getMidpoint().x - 250;
				case 'robocesbg':
					switch (roboStage.curStage)
					{
						case 'default' | 'whitty':
							camFollow.y = boyfriend.getMidpoint().y - 430;
							camFollow.x = boyfriend.getMidpoint().x - 600;
						case 'limo':
							camFollow.x = boyfriend.getMidpoint().x - 300;
							camFollow.y = boyfriend.getMidpoint().y - 230;
						case 'matt':
							camFollow.x = boyfriend.getMidpoint().x - 650;
							camFollow.y = boyfriend.getMidpoint().y - 330;
						case 'tricky':
							camFollow.x = boyfriend.getMidpoint().x - 320;
							camFollow.y = boyfriend.getMidpoint().y - 300;
						case 'c354r-default':
							camFollow.x = boyfriend.getMidpoint().x - 210;
							camFollow.y = boyfriend.getMidpoint().y - 410;
						default:
							camFollow.x = boyfriend.getMidpoint().x - 490;
							camFollow.y = boyfriend.getMidpoint().y - 280;
					}
				case 'city':
					camFollow.x = boyfriend.getMidpoint().x - 330;
					camFollow.y = boyfriend.getMidpoint().y - 385;
				case 'city-minus':
					camFollow.x = boyfriend.getMidpoint().x - 600;
					camFollow.y = boyfriend.getMidpoint().y - 190;
				case 'lab':
					camFollow.x = (boyfriend.curCharacter == "bf-minus" ? boyfriend.getMidpoint().x - 950 : boyfriend.getMidpoint().x - 650);
					camFollow.y = (boyfriend.curCharacter == "bf-minus" ? boyfriend.getMidpoint().y - 190 : boyfriend.getMidpoint().y - 230);
			}

			camFollow.x += BF_CAM_OFFSET.x + boyfriend.cameraOffset.x;
			camFollow.y += BF_CAM_OFFSET.y + boyfriend.cameraOffset.y;
			BF_CAM_POS.set(camFollow.x, camFollow.y);
		}

		scripts.callFunction("onMoveCamera", [isDad]);
	}

	public function updateScoring(bop:Bool = false)
	{
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);

		scoreTxt.text = Ratings.CalculateRanking(accuracy);

		if (bop)
			scoreTxt.bop();
	}

	function endSong():Void
	{
		skipDialogue = false;

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (!ClientPrefs.botplay)
		{
			if (accuracy <= 41)
				CostumeHandler.unlockCostume(FLU);

			if (misses == 0)
				Highscore.fullCombos.set(SONG.song.toLowerCase(), 0);
		}

		if (isStoryMode)
		{
			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				Main.playFreakyMenu();
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				#if windows
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end

				Highscore.save();

				endingSong = true;

				FlxG.switchState(new StoryMenuState(true));
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty >= 2)
					difficulty = '-hard';

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				deaths = 0;
				FlxG.switchState(new PlayState(curStage != SONG.stage, camFollow));
			}
		}
		else
		{
			Main.playFreakyMenu();
			deaths = 0;
			FlxG.switchState(new FreeplayState(true));
		}
	}

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var wife:Float = Ratings.wife3(noteDiff, Conductor.timeScale);
		var daRating = daNote.rating;

		vocals.volume = 1;
		totalNotesHit += wife;

		switch (daRating)
		{
			case 'shit':
				combo = 0;
				misses++;
				health -= 0.2;
				totalRatings.shits++;
			case 'bad':
				health -= 0.06;
				totalRatings.bads++;
			case 'good':
				totalRatings.goods++;
				health += 0.02;
			case 'sick':
				health += 0.04;

				if (ClientPrefs.notesplash)
				{
					var splash:NoteSplash = splashGrp.recycle();
					splash.splash(playerStrums.members[daNote.noteData].x, playerStrums.members[daNote.noteData].y, daNote.noteData);
					add(splash);
				}
		}

		var forcedCombo = songScript.variables["forceComboPos"] != null
			&& (songScript.variables["forceComboPos"].x != 0 || songScript.variables["forceComboPos"].y != 0);

		var rating:ComboRating = ratingsGrp.recycle(ComboRating);
		rating.create(daRating);
		rating.setPosition((FlxG.width / 2) - (rating.width / 2), (FlxG.height * 0.5) - (rating.height / 2) + 100);

		if (forcedCombo)
		{
			rating.x = songScript.variables["forceComboPos"].x;
			rating.y = songScript.variables["forceComboPos"].y;
		}
		else if (ClientPrefs.ratingX != -1)
			rating.setPosition(ClientPrefs.ratingX, ClientPrefs.ratingY);

		ratingsGrp.add(rating);
		add(rating);

		if (ClientPrefs.showPrecision)
		{
			currentTimingShown.text = (FlxG.save.data.botplay ? 0 : FlxMath.roundDecimal(noteDiff, 2)) + 'ms' + (daNote.type == 1 ? "\n    DODGE!" : "");

			currentTimingShown.setPosition(rating.x + 140, rating.y + 100);
			currentTimingShown.velocity.copyFrom(rating.velocity);
			currentTimingShown.acceleration.y = rating.acceleration.y;

			if (ClientPrefs.ratingX != -1 && !forcedCombo)
				currentTimingShown.setPosition(ClientPrefs.msX, ClientPrefs.msY);

			currentTimingShown.color = switch (daRating)
			{
				case 'shit':
					0xFF6E627B;
				case 'bad':
					0xFF9B55B5;
				case 'good':
					0xFF9B55B5;
				default: // sick
					0xFFEC46B1;
			}
		}

		if (combo != 0 && combo < 10) // Don't show combo stuff if it's broken or lower than 10
			return;

		var seperatedCombo:Array<String> = (combo + "").split('');

		while (seperatedCombo.length < 3)
			seperatedCombo.insert(0, "0");

		for (i in 0...seperatedCombo.length)
		{
			var numScore:ComboNumber = numbersGrp.recycle(ComboNumber);
			numScore.create(seperatedCombo[i]);
			numScore.x = (ClientPrefs.numX != -1 && !forcedCombo ? ClientPrefs.numX : rating.x) + (33 * i) - 8;
			numScore.y = (ClientPrefs.numY != -1 && !forcedCombo ? ClientPrefs.numY : rating.y + 100) + (usePixelAssets ? 30 : 0);

			numbersGrp.add(numScore);
			add(numScore);
		}

		updateScoring();
	}

	private function keyShit():Void // The input system has been (almost) completely rewritten, however logic for sustain notes and botplay still exists here.
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

		// Prevent player input if botplay is on
		if (ClientPrefs.botplay)
		{
			holdArray = [false, false, false, false];
		}

		// HOLDS, check for sustain notes
		if (holdArray.contains(true))
		{
			for (i in 0...holdArray.length)
			{
				if (holdArray[i])
				{
					if (playerStrums.members[i].animation.curAnim.name != 'confirm')
					{
						playerStrums.members[i].animation.play('pressed', true);
					}
				}
			}

			notes.forEachAlive(function(daNote:Note)
			{
				if (holdArray[daNote.noteData] && daNote.mustPress && daNote.isSustainNote && daNote.canBeHit)
					goodNoteHit(daNote);
			});
		}

		if (ClientPrefs.botplay)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && daNote.timeDiff <= 15)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if (curPlayer.holdTimer > (Conductor.stepCrochet * 0.0011) * 5.78)
		{
			if (curPlayer.animation.curAnim.name.startsWith('sing') && !curPlayer.animation.curAnim.name.endsWith('miss'))
			{
				curPlayer.dance();
			}
		}

		if (useDirectionalCamera && PlayState.SONG.notes[curSection] != null)
		{
			var curAnim:String = (cast(PlayState.SONG.notes[curSection].mustHitSection ? curPlayer : curOpponent) : Character).animation.curAnim.name;
			var camPos:FlxPoint = PlayState.SONG.notes[curSection].mustHitSection ? BF_CAM_POS : DAD_CAM_POS;

			camFollow.x = camPos.x + (curAnim == "singLEFT" ? -directionalCameraDist : curAnim == "singRIGHT" ? directionalCameraDist : 0);
			camFollow.y = camPos.y + (curAnim == "singUP" ? -directionalCameraDist : curAnim == "singDOWN" ? directionalCameraDist : 0);
		}

		strumLineNotes.forEach((spr) ->
		{
			spr.centerOffsets();
			spr.centerOrigin();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (combo >= 10)
			gf.playAnim('sad');

		health -= 0.04;
		combo = 0;
		misses++;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.67, 0.75));
		if (curPlayer.animation.curAnim.name != 'dodge' || curPlayer.animation.curAnim.name != 'hey')
		{
			curPlayer.playAnim('sing' + dataSuffix[direction] + 'miss', true);
		}

		#if windows
		if (luaModchart != null)
			luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
		#end

		totalPlayed += 1;
		updateScoring();
	}

	function goodNoteHit(note:Note):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = ClientPrefs.botplay ? "sick" : Ratings.CalculateRating(noteDiff);

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			}
			else
				totalNotesHit += 1;

			var altSuffix:String = '';
			if (songScript.variables.exists("bfAltSuffix"))
			{
				altSuffix = songScript.variables.get("bfAltSuffix");
			}

			if (curPlayer.animation.curAnim.name != 'shoot'
				|| curPlayer.animation.curAnim.name != 'dodge'
				|| curPlayer.animation.curAnim.name != 'hey')
			{
				scripts.callFunction("onPlayerNoteHit", [note]);
				curPlayer.holdTimer = 0;
				if (note.properties.singAnim == null)
					curPlayer.playAnim('sing' + dataSuffix[note.noteData] + altSuffix, true);
				else
					curPlayer.playAnim(note.properties.singAnim, true);
			}

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			playerStrums.members[note.noteData].animation.play('confirm', true);

			note.wasGoodHit = true;
			vocals.volume = 1;

			switch (note.type)
			{
				case 1:
					boyfriend.playAnim('dodge', true);
					health += 0.02;
			}

			note.kill();
			note.exists = false;

			totalPlayed++;
			updateScoring(!note.isSustainNote);
		}
	}

	override function stepHit()
	{
		super.stepHit();

		scripts.callFunction("onStepHit", [curStep]);

		if (subtitles != null)
		{
			subtitles.stepHit(curStep);
		}

		if (curSong == 'Bazinga')
		{
			switch (curStep)
			{
				case 121:
					health += 0.32;
				case 1476 | 1508:
					defaultCamZoom = 0.95;
				case 1500 | 1522:
					defaultCamZoom = 0.6;
				case 1524:
					health += 0.40;
			}
		}

		if (curSong == 'Prayer')
		{
			if (curStep >= 1359 && curStep <= 1424)
			{
				vignette.scale.set(1.1, 1.1);
				if (curStep == 1359)
					FlxTween.tween(vignette, {alpha: 1}, 6.45);
				else if (curStep == 1424)
				{
					FlxTween.cancelTweensOf(vignette);
					FlxTween.tween(vignette, {alpha: 0}, 0.35);
				}
			}
		}

		if (curSong == 'Milk-Tea')
		{
			switch (curStep)
			{
				case 189 | 318 | 444 | 702:
					dad.playAnim('cheer', true);
				case 557:
					boyfriend.playAnim('hey');
				case 835:
					dad.playAnim('cheer', true);
					boyfriend.playAnim('hey');
			}
		}

		if (Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 25 * FlxG.sound.music.pitch
			|| Math.abs(vocals.time - Conductor.songPosition) > 25 * FlxG.sound.music.pitch)
		{
			resyncVocals();
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.getDiscordPreview(),
			"Acc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Misses: "
			+ misses, iconRPC, true, FlxG.sound.music.length
			- Conductor.songPosition);
		#end
	}

	static public var beatSpeed:Int = 4;

	override function beatHit()
	{
		super.beatHit();

		if (curSection != Std.int(curStep / 16))
		{
			curSection = Std.int(curStep / 16);
			if (PlayState.SONG.notes[curSection] != null && !disableCamera)
			{
				moveCamera(!PlayState.SONG.notes[curSection].mustHitSection);
			}
		}

		scripts.callFunction("onBeatHit", [curBeat]);

		switch (curSong.toLowerCase())
		{
			case 'hardships':
				if (curBeat == 158)
					boyfriend.useAlternateIdle = true;
			case 'loaded':
				roboStage.beatHit(curBeat);
			case 'star-baby':
				switch (curBeat)
				{
					case 128:
						defaultCamZoom += 0.17;
						FlxTween.color(spookyBG, 0.45, FlxColor.WHITE, FlxColor.fromString("#828282"));
						FlxTween.color(gf, 0.45, FlxColor.WHITE, FlxColor.fromString("#828282"));
						useDirectionalCamera = true;
					case 192:
						defaultCamZoom -= 0.17;
						FlxTween.color(spookyBG, 0.45, FlxColor.fromString("#828282"), FlxColor.WHITE);
						FlxTween.color(gf, 0.45, FlxColor.fromString("#828282"), FlxColor.WHITE);
						useDirectionalCamera = false;
					default:
						if (curBeat % 2 == 0 && curBeat > 128 && curBeat < 192)
						{
							FlxG.camera.zoom += 0.015;
							camHUD.zoom += 0.03;
						}
				}
			case 'crucify':
				if (curBeat == 160)
				{
					camGame.flash(FlxColor.BLACK, 1.3);
					moreDark.visible = false;
					gf.visible = false;
					camZooming = true;
				}
			case 'bad-nun':
				shaders.BadNun.beatHit(curBeat);
		}

		notes.sort(FlxSort.byY, (ClientPrefs.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].changeBPM)
		{
			Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (!curOpponent.animation.curAnim.name.startsWith('sing'))
		{
			var specialAnims:Array<String> = ['dodge', 'hey', 'shoot', 'phone', 'slam', 'transform', 'bye', 'scream'];
			if (!specialAnims.contains(curOpponent.animation.curAnim.name) || curOpponent.animation.finished)
			{
				curOpponent.dance();
			}
		}

		var iconBop:Float = curBeat % 4 == 0 ? 1.2 : 1.135;

		if (!usePixelAssets)
		{
			iconP1.origin.set(iconP1.width / 2, 0);
			iconP2.origin.set(iconP2.width / 2, 0);
		}
		else
		{
			iconP1.centerOrigin();
			iconP2.centerOrigin();
		}

		iconP1.scale.set(iconBop, iconBop);
		iconP2.scale.set(iconBop, iconBop);

		// icon bop last for half a beat
		FlxTween.tween(iconP1.scale, {x: 1, y: 1}, (Conductor.crochet / 1000) / 2);
		FlxTween.tween(iconP2.scale, {x: 1, y: 1}, (Conductor.crochet / 1000) / 2);

		if (boyfriend.animation.curAnim.name != 'hey' && !gf.animation.curAnim.name.startsWith('sing'))
		{
			if (curBeat % gfSpeed == 0)
			{
				if (gf.animation.curAnim.name != 'scared' || gf.animation.curAnim.name == 'scared' && dad.holdTimer < -0.35)
					gf.dance();
			}
		}

		if (!curPlayer.animation.curAnim.name.startsWith("sing"))
		{
			var specialAnims:Array<String> = ['dodge', 'hey', 'shoot'];
			if (!specialAnims.contains(curPlayer.animation.curAnim.name) || curPlayer.animation.finished)
			{
				curPlayer.dance();
			}
		}

		switch (curStage)
		{
			case 'schoolEvil':
				if (meat != null && !meat.animation.curAnim.name.startsWith("sing"))
					meat.dance();
			case 'school':
				if (SONG.song.toLowerCase() != 'space-demons')
				{
					bgGirls.dance();
				}
		}
	}

	function summonPainting()
	{
		var mechanic = new FlxSprite(1240, 300);
		mechanic.frames = Paths.getSparrowAtlas('mechanicShit/paintingShit');
		mechanic.animation.addByPrefix('idle', 'paintingShit', 30, false);
		mechanic.animation.play('idle');
		mechanic.antialiasing = true;
		add(mechanic);

		mechanic.animation.finishCallback = function(anim)
		{
			if (anim == "idle")
			{
				remove(mechanic, true);
				mechanic.exists = false;
			}
		}
	}

	override function add(object:FlxBasic):FlxBasic
	{
		if (!ClientPrefs.antialiasing && object is FlxSprite)
		{
			cast(object, FlxSprite).antialiasing = false;
		}

		return super.add(object);
	}

	// NEW INPUT SHIT
	var keysHeld:Array<Bool> = [false, false, false, false];

	private function onKeyPress(input:KeyboardEvent)
	{
		if (ClientPrefs.botplay || paused || inCutscene)
			return;

		var key:Int = switch (input.keyCode)
		{
			case 37: 0; // LEFT ARROW KEY
			case 40: 1; // DOWN ARROW KEY
			case 38: 2; // UP ARROW KEY
			case 39: 3; // RIGHT ARROW KEY
			default: ClientPrefs.keybinds.indexOf(FlxKey.toStringMap[input.keyCode]); // NOT AN ARROW KEY
		}

		if (key == -1 || keysHeld[key])
		{
			return;
		}
		else
			keysHeld[key] = true;

		// Temporarily sets songPosition to the song's exact timing. does this do anything? more news at 10.
		var previousTiming:Float = Conductor.songPosition;
		Conductor.songPosition = FlxG.sound.music.time;

		// Checks for most on-time / late note.
		var closestNote:Note = null;
		notes.forEachAlive((note:Note) ->
		{
			if (note.mustPress && note.noteData == key && !note.isSustainNote && note.timeDiff <= 166 * FlxG.sound.music.pitch)
			{
				if (closestNote == null || closestNote != null && note.timeDiff < closestNote.timeDiff)
					closestNote = note;
			}
		});

		// Player hits note
		if (closestNote != null)
		{
			playerStrums.members[key].animation.play('confirm', true);
			goodNoteHit(closestNote);
		}
		else if (!ClientPrefs.ghost)
			noteMiss(key);

		Conductor.songPosition = previousTiming;
	}

	private function onKeyRelease(input:KeyboardEvent)
	{
		if (ClientPrefs.botplay || paused || inCutscene)
			return;

		var key:Int = switch (input.keyCode)
		{
			case 37: 0; // LEFT ARROW
			case 40: 1; // DOWN ARROW
			case 38: 2; // UP ARROW
			case 39: 3; // RIGHT ARROW
			default: ClientPrefs.keybinds.indexOf(FlxKey.toStringMap[input.keyCode]); // NOT AN ARROW KEY
		}

		if (key == -1)
			return;

		keysHeld[key] = false;

		if (playerStrums.members[key].animation.curAnim.name != 'static')
		{
			playerStrums.members[key].animation.play('static');
		}
	}

	private function onGameResize(width:Int = 1280, height:Int = 720)
	{
		scoreTxt.updateAdaptiveScaling();
		if (songPosBar != null)
			songPosBar.updateAdaptiveScaling();
	}

	override function switchTo(_):Bool
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxG.signals.gameResized.remove(onGameResize);

		return true;
	}

	function songJump(seconds:Float)
	{
		var strumTime:Float = Conductor.songPosition + (seconds * 1000);

		if (strumTime > FlxG.sound.music.length)
		{
			endSong();
		}

		var toKill:Array<Note> = [];
		for (i in notes)
		{
			if (strumTime > i.strumTime)
			{
				toKill.push(i);
			}
		}

		var unspawns:Array<QueuedNote> = [];
		for (i in unspawnNotes)
		{
			if (strumTime > i.strumTime)
			{
				unspawns.push(i);
			}
		}

		for (i in unspawns)
			unspawnNotes.remove(i);

		for (i in toKill)
		{
			i.kill();
			if (notes.members.contains(i))
				notes.remove(i, true);
		}

		var stepDiff:Int = Math.floor((strumTime - Conductor.songPosition) / Conductor.stepCrochet);
		for (i in curStep...stepDiff + 1)
		{
			curStep = i;
			stepHit();
		}

		strumTime -= 500; // so we dont skip immediately to a note
		FlxG.sound.music.time = strumTime;
		vocals.time = strumTime;
		Conductor.songPosition = strumTime;
	}

	var parried(default, set):Bool = false;

	function set_parried(p):Bool
	{
		if (p && !parried)
		{
			trace("PARRY ACHIEVEMENT");
			AchievementHandler.unlockTrophy(PERFECT_PARRY);
		}
		return parried = p;
	}

	private function set_health(health:Float):Float
	{
		health = FlxMath.bound(health, 0, 2);

		if (health == 0)
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.getDiscordPreview(),
				"\nAcc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Misses: "
				+ misses, iconRPC);
			#end
		}

		this.health = health;
		return health;
	}
}
