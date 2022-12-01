package;

import GameScript.ScriptGroup;
import Note.QueuedNote;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
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
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.system.System;
import shaders.*;
import shaders.Shaders.VCRDistortionEffect;
import shaders.WiggleEffect.WiggleEffectType;
import sprites.*;

using StringTools;

#if (sys && !mobile)
import Discord.DiscordClient;
import sys.FileSystem;
#end

class PlayState extends MusicBeatState
{
	public static var SONG:SwagSong;
	public static var instance:PlayState = null;

	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var campaignScore:Int = 0;

	public static var curStage:String = '';

	public static var minus:Bool = false;
	public static var endingSong:Bool;

	private var curSong:String = "";
	private var vocals:FlxSound;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	var inCutscene:Bool = false;

	public var gfSpeed:Int = 1;

	private var executeModchart = false;

	public var beatClass:Class<Dynamic> = null;

	public static var skipDialogue:Bool = false;

	public static var opponent:Bool = true; // decides if the player should play as fever or the opponent

	var curBoyfriend:String = SONG.player1; // not to be confused with curPlayer, this overrides what character BF is

	public var curOpponent:Character; // these two variables are for the "swapping sides" portion
	public var curPlayer:Character; // just use the dad / boyfriend variables so stuff doesnt break

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	private var yukichi_pixel:Character;
	var tea_pixel:Character;
	var fever_pixel:Character;

	var characterTrail:CharacterTrail;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var defaultCamZoom:Float = 1.05;
	public var camZooming:Bool = false;
	public var disableCamera:Bool = false;
	public var disableHUD:Bool = false;
	public var disableModCamera:Bool = false; // disables the modchart from messing around with the camera
	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var filters:Array<BitmapFilter> = [];

	var camfilters:Array<BitmapFilter> = [];

	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; // we do a little backporting

	public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();

	private var unspawnNotes:Array<QueuedNote> = [];

	public var strumLine:FlxSprite;
	public var lanes:FlxTypedGroup<FlxSprite>;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	var songScore:Int = 0;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;

	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	// party crasher shit
	public var modchart:ModChart;

	var tvshit:VCRDistortionEffect;

	public var font:Bool = false;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var dialogue:Array<String> = [];

	// stage sprites
	var w1city:FlxSprite; // week 1
	var spookyBG:FlxSprite; // week 2

	public var church:FlxSprite; // week 2.5 / bad nun

	var painting:FlxSprite; // portrait / soul
	var limo:FlxSprite; // week 4
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var bottomBoppers:Crowd; // week 5
	var bgGirls:BackgroundGirls; // week 6

	public var roboStage:RoboBackground;
	public var roboBackground:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public var roboForeground:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var whittyBG:FlxSprite; // princess week
	var princessBG:FlxSprite;
	var princessFloor:FlxSprite;
	var princessCrystals:FlxSprite;

	public var scoreTxt:FlxText;
	public var subtitles:Subtitles;

	private var botPlayState:FlxText; // BotPlay text
	var currentTimingShown:FlxText;
	var songName:FlxText;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?

	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	var songPositionBar:Float = 0;

	public var purpleOverlay:FlxSprite;

	var dark:FlxSprite;
	var moreDark:FlxSprite;
	var blackScreen:FlxSprite;
	var takiBGSprites:Array<FlxSprite> = [];

	public static var deaths:Int = 0;

	public static var hallowDeaths:Int = 0;
	public static var hallowNoteDeaths:Int = 0;

	public static var easierMode:Bool = false;

	public static var diedtoHallowNote:Bool = false;

	public static function setModCamera(bool:Bool)
	{
		if (FlxG.save.data.disableModCamera)
			instance.disableModCamera = true;
		else
			instance.disableModCamera = bool;
	}

	public static var daPixelZoom:Float = 6;

	public var usePixelAssets:Bool = false;

	var fevercamX:Int = 0;
	var fevercamY:Int = 0;

	var scoreBop:FlxTween;
	var disableScoreBop:Bool = false;
	var wiggleEffect:WiggleEffect;
	var vignette:FlxSprite;

	var diner:FlxSprite;
	var pixelDiner:FlxSprite;

	var meat:Character;

	public static var unlocked:FlxText;

	var curBFY:Float = 0;

	// finale stage
	var buildings1:FlxBackdrop;
	var buildings2:FlxBackdrop;
	var buildings3:FlxBackdrop;
	var sky:FlxSprite;
	var train:FlxSprite;

	var scripts:ScriptGroup = new ScriptGroup();
	var songScript:GameScript;
	var curSection:Int = 0;

	override public function create()
	{
		instance = this;

		for (i in ['sicks', 'bads', 'goods', 'shits', 'misses'])
			Reflect.setField(PlayState, i, 0);

		if (!isStoryMode || StoryMenuState.get_weekData()[storyWeek][0].toLowerCase() == SONG.song.toLowerCase())
		{
			Main.clearMemory();
		}

		super.create();

		// Preload
		add(new NoteSplash(0, 0, 0));

		endingSong = false;

		opponent = FlxG.save.data.opponent;
		setModCamera(false);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));
		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));

		// partycrasher shit//
		modchart = new ModChart(this);
		// partycrasher shit//

		if (ClientPrefs.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		#if windows
		executeModchart = FlxG.save.data.disableModCharts ? false : FileSystem.exists(Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.capitalizeFirstLetters(CoolUtil.difficultyArray[storyDifficulty]);

		switch (SONG.player2)
		{
			case 'taki':
				iconRPC = 'monster';
			case 'peasus':
				iconRPC = 'dad';
			case 'robofvr-final':
				iconRPC = 'roboff';
			default:
				iconRPC = SONG.player2.split('-')[0]; // To avoid having duplicate images in Discord assets
		}
		detailsPausedText = "Paused - " + detailsText; // String for when the game is paused

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = isStoryMode ? ("Story Mode: Week " + storyWeek) : "Freeplay";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ if (SONG.song == "Tranquility" || SONG.song == "Princess" || SONG.song == "Banish") "im not leaking" else SONG.song + " ("
				+ storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		currentTimingShown = new FlxText(0, 0, 0, "");
		currentTimingShown.setFormat(null, 18, FlxColor.CYAN, LEFT, OUTLINE, FlxColor.BLACK);

		currentTimingShown.cameras = [camHUD];

		if (FlxG.save.data.shaders)
		{
			camGame.setFilters(filters);
			camGame.filtersEnabled = true;
			camHUD.setFilters(camfilters);
			camHUD.filtersEnabled = true;
		}

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('Milk-Tea');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		// dialogue shit, it does the dialogue = txt file shit for u
		var dialogueString:String = SONG.song.toLowerCase() + '/dia';

		if (Assets.exists(Paths.txt(dialogueString)))
		{
			dialogue = CoolUtil.coolTextFile(Paths.txt(dialogueString));
		}

		if (ClientPrefs.subtitles)
		{
			var subtitleString:String = SONG.song.toLowerCase() + '/subtitles';

			if (CoolUtil.fileExists(Paths.json(subtitleString)))
			{
				subtitles = new Subtitles(FlxG.height * 0.68, haxe.Json.parse(CoolUtil.getFile(Paths.json(subtitleString))));
			}
		}

		switch (SONG.song.toLowerCase())
		{
			case 'mako' | 'vim':
				curBoyfriend = 'bf-casual';
			case 'retribution' | 'farmed':
				curBoyfriend = 'bf-casualdemon';
			case 'honey' | 'bunnii':
				curBoyfriend = 'bf-car';
			case 'throw-it-back':
				curBoyfriend = 'bf-carnight';
			case 'gears':
				curBoyfriend = 'bf-mad';
		}

		gf = new Character(400, 130, SONG.gfVersion == null ? 'gf' : SONG.gfVersion);
		boyfriend = new Boyfriend(770, 450, curBoyfriend);
		dad = new Character(100, 100, SONG.player2);

		switch (SONG.stage)
		{
			case 'city':
				curStage = SONG.stage;
				var stageScript:GameScript = new GameScript('assets/stages/$curStage.hx');
				scripts.add(stageScript);
				stageScript.callFunction("onCreate");
			case 'fireplace':
				curStage = 'fireplace';
				// defaultCamZoom = 0.76;

				var bg = new FlxSprite().loadGraphic(Paths.image('pasteBG'));
				bg.scale.set(1.5, 1.5);
				bg.scrollFactor.set(0.9, 0.9);
				bg.antialiasing = true;
				add(bg);

				blackScreen = new FlxSprite(-600, -600);
				blackScreen.makeGraphic(1280 * 2, 720 * 2, FlxColor.BLACK);
				blackScreen.scrollFactor.set(0.9, 0.9);
				add(blackScreen);

				if (deaths <= 0)
				{
					camHUD.flash(FlxColor.BLACK, 15);
					defaultCamZoom = 1.2;
				}
				else
				{
					defaultCamZoom = 0.76;
				}

			case 'finale':
				{
					curStage = 'finale';
					defaultCamZoom = 0.3;

					sky = new FlxSprite(0, -1000).loadGraphic(Paths.image('roboStage/sky'));
					sky.antialiasing = true;
					sky.scrollFactor.set(0.9, 0.9);
					sky.setGraphicSize(Std.int(sky.width * 1.75));
					sky.updateHitbox();
					add(sky);

					buildings1 = new FlxBackdrop(Paths.image('roboStage/buildings_3'), 0, 0, true, false);
					buildings1.antialiasing = true;
					buildings1.scrollFactor.set(0.9, 0.9);
					buildings1.setGraphicSize(Std.int(buildings1.width * 1.75));
					buildings1.updateHitbox();
					buildings1.y -= 800;
					buildings1.x -= 600;
					add(buildings1);

					buildings2 = new FlxBackdrop(Paths.image('roboStage/buildings_2'), 0, 0, true, false);
					buildings2.antialiasing = true;
					buildings2.scrollFactor.set(0.9, 0.9);
					buildings2.setGraphicSize(Std.int(buildings2.width * 1.75));
					buildings2.updateHitbox();
					buildings2.y -= 1500;
					buildings2.x -= 600;
					add(buildings2);

					buildings3 = new FlxBackdrop(Paths.image('roboStage/buildings_1'), 0, 0, true, false);
					buildings3.antialiasing = true;
					buildings3.scrollFactor.set(0.9, 0.9);
					buildings3.setGraphicSize(Std.int(buildings3.width * 1.75));
					buildings3.updateHitbox();
					buildings3.y -= 2500;
					buildings3.x -= 600;
					add(buildings3);

					train = new FlxSprite(0, 666);
					train.frames = Paths.getSparrowAtlas('roboStage/train');
					train.animation.addByPrefix('drive', "all train", 24, false);
					train.animation.play('drive');
					train.antialiasing = true;
					train.scrollFactor.set(0.9, 0.9);
					train.setGraphicSize(Std.int(train.width * 1.75));
					train.updateHitbox();
					add(train);

					if (FlxG.save.data.shaders)
					{
						filters.push(ShadersHandler.bloom);
						camGame.filtersEnabled = true;
					}
				}
			case 'halloween':
				{
					curStage = 'spooky';
					defaultCamZoom = 0.6;

					spookyBG = new FlxSprite(-200, -100).loadGraphic(Paths.image('spooky', 'week2'));
					spookyBG.antialiasing = true;

					var city:FlxSprite = new FlxSprite(-290, -180).loadGraphic(Paths.image('city', 'week2'));
					city.antialiasing = true;
					city.scrollFactor.set(0.8, 0.8);

					add(city);
					add(spookyBG);
				}
			case 'hallowhalloween':
				{
					summonPainting(); // Preload painting
					curStage = 'spookyHALLOW';
					defaultCamZoom = 0.6;

					var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('week2bghallow'));
					bg.antialiasing = true;
					add(bg);

					painting = new FlxSprite(-200, -100).loadGraphic(Paths.image('week2bghallowpainting'));
					painting.antialiasing = true;
					add(painting);
					painting.visible = false;
					if (SONG.song.toLowerCase() == 'soul')
					{
						painting.visible = true;

						if (FlxG.save.data.shaders)
						{
							camfilters.push(ShadersHandler.chromaticAberration);
							ShadersHandler.setChrome(FlxG.random.int(2, 2) / 1000);

							camHUD.filtersEnabled = true;
							camGame.filtersEnabled = true;
						}
					}
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
					curStage = 'spookyBOO';
					defaultCamZoom = 0.6;

					var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('week2bgtaki'));
					if (curSong == 'Hallow' || curSong == 'Portrait')
					{
						var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('week2bghallow'));
					}

					bg.antialiasing = true;
					add(bg);

					if (SONG.song == 'Crucify')
					{
						var sky:FlxSprite = new FlxSprite(bg.x + 165, bg.y + 90).loadGraphic(Paths.image('takiSky', 'week2'));
						sky.antialiasing = true;
						add(sky);
						sky.visible = false;
						takiBGSprites.push(sky);

						var islands:FlxSprite = new FlxSprite(sky.x, sky.y).loadGraphic(Paths.image('takiIslands', 'week2'));
						islands.antialiasing = true;
						add(islands);
						islands.visible = false;
						takiBGSprites.push(islands);

						var main:FlxSprite = new FlxSprite(sky.x, sky.y).loadGraphic(Paths.image('takiMain', 'week2'));
						main.antialiasing = true;
						add(main);
						main.visible = false;
						takiBGSprites.push(main);

						for (i in takiBGSprites)
							i.scale.set(1.145, 1.145);
						FlxTween.tween(islands, {y: islands.y - 50}, 2.85, {type: PINGPONG});
					}
				}
			case 'week3stage':
				{
					curStage = 'week3stage';
					defaultCamZoom = 0.9;

					var bg:FlxSprite = new FlxSprite(-90, -20).loadGraphic(Paths.image(SONG.song == "Retribution" ? 'skyMoon' : 'sky', 'week3'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.7, 0.7);
					add(bg);

					var outerBuilding:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('mako_buildings_2', 'week3'));
					outerBuilding.antialiasing = true;
					outerBuilding.scrollFactor.set(0.46, 0.7);
					add(outerBuilding);

					var innerBuilding:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('mako_buildings', 'week3'));
					innerBuilding.scrollFactor.set(0.7, 0.8);
					innerBuilding.antialiasing = true;
					add(innerBuilding);

					var ground:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('mako_ground', 'week3'));
					ground.antialiasing = true;
					add(ground);
				}
			case 'limo' | 'limonight':
				{
					curStage = SONG.stage;
					var prefix:String = curStage == 'limonight' ? 'limoNight' : 'limo';
					defaultCamZoom = 0.855;

					var skyBG:FlxSprite = new FlxSprite(-200, -145).loadGraphic(Paths.image('$prefix/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.25, 0);
					skyBG.antialiasing = true;
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('$prefix/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgLimo.antialiasing = true;
					add(bgLimo);

					if (FlxG.save.data.distractions)
					{
						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						add(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - (prefix.contains('Night') ? 440 : 620));
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
						}
					}

					limo = new FlxSprite(-120, 550);
					limo.frames = Paths.getSparrowAtlas('$prefix/limoDrive', 'week4');
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('$prefix/fastCarLol', 'week4'));
					fastCar.antialiasing = true;
				}
			case 'ripdiner':
				{
					curStage = 'ripdiner';
					defaultCamZoom = 0.5;

					diner = new FlxSprite(-820, -200).loadGraphic(Paths.image('christmas/lastsongyukichi', 'week5'));
					diner.antialiasing = true;
					diner.scrollFactor.set(0.9, 0.9);
					add(diner);

					pixelDiner = new FlxSprite(-820, -200).loadGraphic(Paths.image('christmas/Week5YukichiBGPIXEL', 'week5'));
					pixelDiner.antialiasing = true;
					pixelDiner.scrollFactor.set(0.9, 0.9);
					add(pixelDiner);
					var widShit = Std.int(pixelDiner.width * 6);
					pixelDiner.setGraphicSize(widShit);
					pixelDiner.updateHitbox();
					pixelDiner.visible = false;
				}
			case 'robocesbg':
				{
					curStage = 'robocesbg';
					add(roboBackground);
					roboStage = new RoboBackground();
				}
			case 'school':
				{
					curStage = 'school';
					usePixelAssets = true;

					var bgSky = new FlxSprite(0, -200).loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.9, 0.9);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.9, 0.9);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
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
						bgGirls = new BackgroundGirls(-100, 190);
						bgGirls.scrollFactor.set(0.9, 0.9);

						if (SONG.song.toLowerCase() == 'chicken-sandwich')
						{
							if (FlxG.save.data.distractions)
							{
								bgGirls.getScared();
							}
						}

						bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
						bgGirls.updateHitbox();
						if (FlxG.save.data.distractions)
						{
							add(bgGirls);
						}
					}

					var bgFront:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebfront', 'week6'));
					bgFront.scrollFactor.set(0.9, 0.9);
					add(bgFront);

					var bgOverlay:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weeboverlay', 'week6'));
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

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
			case 'week5':
				{
					defaultCamZoom = 0.6;
					curStage = 'week5';
					var bg:FlxSprite = new FlxSprite(-820, -200).loadGraphic(Paths.image('christmas/first2songs', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					add(bg);
				}
			case 'week5othercrowd':
				{
					defaultCamZoom = 0.6;
					curStage = 'week5othercrowd';
					var bg:FlxSprite = new FlxSprite(-820, -200).loadGraphic(Paths.image('christmas/first2songs', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					add(bg);
				}
			case 'princess':
				defaultCamZoom = 0.7;
				curStage = 'princess';

				whittyBG = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/alleywaybroken'));
				whittyBG.antialiasing = true;
				whittyBG.scrollFactor.set(0.9, 0.9);
				whittyBG.scale.set(1.25, 1.25);
				add(whittyBG);

				if (SONG.song.toLowerCase() == 'princess')
				{
					princessBG = new FlxSprite(-446, -611).loadGraphic(Paths.image('roboStage/princessBG'));
					princessBG.antialiasing = true;
					princessBG.scrollFactor.set(0.75, 0.8);
					princessBG.scale.set(1.25, 1.25);
					add(princessBG);
					princessBG.visible = false;

					princessFloor = new FlxSprite(-446, -611).loadGraphic(Paths.image('roboStage/princessFloor'));
					princessFloor.antialiasing = true;
					princessFloor.scrollFactor.set(0.9, 0.9);
					princessFloor.scale.set(1.25, 1.25);
					add(princessFloor);
					princessFloor.visible = false;

					princessCrystals = new FlxSprite(-446, -591).loadGraphic(Paths.image('roboStage/princessCrystals'));
					princessCrystals.antialiasing = true;
					princessCrystals.scrollFactor.set(0.9, 0.9);
					princessCrystals.scale.set(1.25, 1.25);
					add(princessCrystals);
					princessCrystals.visible = false;
					FlxTween.tween(princessCrystals, {y: princessCrystals.y - 70}, 3.4, {type: PINGPONG});
				}
			default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bmp:BitmapData = openfl.Assets.getBitmapData(Paths.image('w1city'));

					var bg:FlxSprite = new FlxSprite(-720, -450).loadGraphic(bmp, true, 2560, 1400);
					bg.animation.add('idle', [3], 0);
					bg.animation.play('idle');
					bg.scale.set(0.3, 0.3);
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					add(bg);

					w1city = new FlxSprite(bg.x, bg.y).loadGraphic(bmp, true, 2560, 1400);
					w1city.animation.add('idle', [0, 1, 2], 0);
					w1city.animation.play('idle');
					w1city.scale.set(bg.scale.x, bg.scale.y);
					w1city.antialiasing = true;
					w1city.scrollFactor.set(0.9, 0.9);
					add(w1city);

					var stageFront:FlxSprite = new FlxSprite(-730, 530).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500,
						-300).loadGraphic(Paths.image(SONG.song == 'Down-Bad' ? 'stagecurtainsDOWNBAD' : 'stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(0.9, 0.9);
					add(stageCurtains);
				}
		}

		gf.scrollFactor.set(0.95, 0.95);

		if (curStage == "schoolEvil")
			meat = new Character(260, 100.9, 'meat');

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
		if (dad.curCharacter == 'pepper')
		{
			defaultCamZoom = 0.8;
		}

		switch (SONG.player2)
		{
			case 'toothpaste':
				dad.scrollFactor.set(0.9, 0.9);
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case "spooky":
				dad.y -= 30;
				// dad.y += 150;
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
				dad.y += 150;
				dad.x -= 100;
				dad.scrollFactor.set(0.9, 0.9);
			case 'peakek':
				dad.y += 60;
				dad.x -= 100;
				camPos.x += 400;
			case 'peasus':
				dad.y += 60;
				dad.x -= 100;
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 20;
				dad.x -= 200;
			case 'parents-christmas':
				dad.x -= 500;
			case 'bdbfever':
				dad.x += 80;
				dad.y += 560;
				dad.scrollFactor.set(0.9, 0.9);
			case 'senpai':
				dad.x += 150;
				dad.y += 320;
				dad.scrollFactor.set(0.9, 0.9);
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 350;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'flippy':
				dad.y += 200;
				dad.x += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'makocorrupt':
				dad.y -= 100;
				dad.x -= 290;
			case 'mom-car' | 'mom-carnight':
				dad.x -= 30;
				dad.y -= 165;
			case 'yukichi':
				dad.y += 350;
				dad.x -= 130;
				dad.scrollFactor.set(0.9, 0.9);
			case 'robo-cesar':
				dad.x = -354.7;
				dad.y = 365.3;
				dad.scrollFactor.set(0.9, 0.9);
		}

		curPlayer = opponent ? dad : boyfriend;
		curOpponent = opponent ? boyfriend : dad;

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'fireplace':
				boyfriend.scrollFactor.set(0.9, 0.9);
				boyfriend.x += 300;
				gf.x += 300;

			case 'limo' | 'limonight':
				boyfriend.y -= 300;
				boyfriend.x += 260;
				gf.y += 20;
				gf.x -= 30;
				if (FlxG.save.data.distractions)
				{
					resetFastCar();
					add(fastCar);
				}
			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 150;
				gf.x += 180;
				gf.y += 300;
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.scrollFactor.set(0.9, 0.9);
			case 'schoolEvil':
				if (FlxG.save.data.distractions)
				{
					var evilTrail = new CharacterTrail(dad, null, 4, 24, 0.1, 0.069);
					add(evilTrail);
				}
				boyfriend.x += 290;
				boyfriend.y += 40;
				gf.x += 180;
				gf.y += 300;
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.scrollFactor.set(0.9, 0.9);
			case 'stage':
				boyfriend.x += 200;
				dad.y -= 45;
			case 'spooky':
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
			case 'finale':
				boyfriend.x = 2850;
				boyfriend.y = 380;
				dad.x += 1850;
				dad.y -= 500;
				boyfriend.scrollFactor.set(0.9, 0.9);
			case 'spookyBOO':
				boyfriend.x = 1086.7;
				boyfriend.y = 604.7;
				gf.x = 524;
				gf.y = 245;
				gf.scrollFactor.set(1.0, 1.0);
				if (FlxG.save.data.distractions && !minus && SONG.song != 'Crucify')
				{
					characterTrail = new CharacterTrail(dad, null, 15, 8, 0.3, 0.069);
					add(characterTrail);
				}
			case 'spookyHALLOW':
				boyfriend.x += 500;
				boyfriend.y += 155;
				gf.x += 300;
				gf.y += 80;
				gf.scrollFactor.set(1.0, 1.0);

				if (FlxG.save.data.distractions)
				{
					var evilTrail = new CharacterTrail(dad, null, 4, 24, 0.3, 0.069);
					add(evilTrail);
				}
			case 'week5' | 'week5othercrowd':
				boyfriend.x += 100;
				boyfriend.y += 165;
				boyfriend.scrollFactor.set(0.9, 0.9);
				dad.y += 100;
				gf.x -= 70;
				gf.y += 200;
				gf.scrollFactor.set(0.9, 0.9);
			case 'ripdiner':
				boyfriend.x += 100;
				boyfriend.y += 165;
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.x -= 70;
				gf.y += 200;
				gf.scrollFactor.set(0.9, 0.9);
			case 'week3stage':
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
			case 'princess':
				boyfriend.x = 1085.2;
				boyfriend.y = 375;
				gf.x = 327;
				gf.y = 40;
				dad.y += 45;
				dad.x -= 150;
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.scrollFactor.set(0.9, 0.9);
		}

		if (SONG.song.toLowerCase() == 'bazinga' || SONG.song.toLowerCase() == 'crucify')
		{
			gf.y -= 15;
			gf.x += 180;
			boyfriend.x += 140;
			if (!minus)
			{
				dad.x += 95;
				dad.y -= 40;
				boyfriend.y -= 35;
			}
			else
			{
				dad.y -= 350;
				dad.x -= 105;
			}
		}

		add(gf);
		if (curStage == 'finale')
			gf.visible = false;

		// Shitty layering but whatev it works LOL
		if (limo != null)
			add(limo);

		if (curStage == 'schoolEvil')
		{
			add(meat);
			FlxTween.circularMotion(meat, 300, 200, 50, 0, true, 4, true, {type: LOOPING});
		}
		add(dad);

		add(boyfriend);
		curBFY = boyfriend.y;

		trace(boyfriend.y);
		trace('curbfy position is ' + curBFY);

		boyfriend.setPosition(boyfriend.x, boyfriend.y);

		if (roboStage != null)
		{
			add(roboForeground);
			roboStage.switchStage(roboStage.curStage);
		}

		if (curStage.startsWith('week5') || curStage == 'ripdiner')
		{
			// no pixel yukichi atm
			tea_pixel = new Character(0, 0, "tea-pixel");
			fever_pixel = new Character(0, 0, "bf-pixeldemon", true);
			tea_pixel.scrollFactor.set(0.9, 0.9);
			fever_pixel.scrollFactor.set(0.9, 0.9);
			tea_pixel.setPosition(gf.x + 460, gf.y + 265);
			fever_pixel.setPosition(boyfriend.x + 190, boyfriend.y + 50);

			add(tea_pixel);
			add(fever_pixel);
			fever_pixel.visible = false;
			tea_pixel.visible = false;

			bottomBoppers = new Crowd();
			add(bottomBoppers);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (ClientPrefs.downscroll)
			strumLine.y = FlxG.height - 150;

		lanes = new FlxTypedGroup<FlxSprite>();
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(lanes);
		add(strumLineNotes);

		if (playerStrums != null)
		{
			playerStrums.clear();
		}

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camPos.set(instance.dad.getGraphicMidpoint().x, instance.dad.getGraphicMidpoint().y + 130);
		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));

		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (ClientPrefs.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = true;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, opponent ? LEFT_TO_RIGHT : RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8),
			Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromString('#FF' + curOpponent.iconColor), FlxColor.fromString('#FF' + curPlayer.iconColor));
		healthBar.antialiasing = true;
		// healthBar
		add(healthBar);

		healthBar.scale.x = 1.04;
		healthBarBG.scale.x = 1.04;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 35, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), #if !mobile 18 #else 24 #end, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		updateScoring();

		scoreTxt.borderSize = 1.25;
		FlxG.signals.gameResized.add(onGameResize);

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		add(scoreTxt);

		if (FlxG.save.data.botplay)
		{
			botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (ClientPrefs.downscroll ? 60 : -60), 0, "BOTPLAY", 20);
			botPlayState.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botPlayState.cameras = [camHUD];
			FlxTween.tween(botPlayState, {alpha: 0}, 1, {type: PINGPONG});
			add(botPlayState);
		}

		unlocked = new FlxText(scoreTxt.x, healthBarBG.y + 100, 0, "", 20);
		unlocked.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		unlocked.scrollFactor.set();
		add(unlocked);
		unlocked.alpha = 0;
		unlocked.cameras = [camHUD];
		if (!ClientPrefs.downscroll)
			healthBarBG.y - 100;

		if (curSong.toLowerCase() == 'tranquility' || curStage == 'church')
		{
			purpleOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.PURPLE);
			purpleOverlay.alpha = 0.33;
			add(purpleOverlay);
			purpleOverlay.cameras = [camHUD];
			purpleOverlay.scale.set(1.5, 1.5);
			purpleOverlay.scrollFactor.set();

			blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackScreen.alpha = 0;
			blackScreen.scrollFactor.set();
			blackScreen.scale.set(5, 5);
			add(blackScreen);

			if (curSong.toLowerCase() == 'tranquility')
			{
				new FlxTimer().start(1.35, (t) ->
				{
					FlxTween.tween(purpleOverlay, {alpha: FlxG.random.float(0.235, 0.425)}, 1.15);
				}, 0);

				if (FlxG.save.data.shaders)
				{
					wiggleEffect = new WiggleEffect();
					wiggleEffect.effectType = WiggleEffectType.DREAMY;
					wiggleEffect.waveAmplitude = 0.0055;
					wiggleEffect.waveFrequency = 7;
					wiggleEffect.waveSpeed = 1.15;

					for (i in [iconP1, iconP2, scoreTxt, currentTimingShown, whittyBG])
						i.shader = wiggleEffect.shader;
				}
			}
			else
				purpleOverlay.alpha = 0.21;
		}

		lanes.cameras = [camHUD];
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

				tvshit = new VCRDistortionEffect();

				tvshit.setDistortion(false);
				tvshit.setVignetteMoving(true);
				tvshit.setVignette(true);
				tvshit.setScanlines(false);
				tvshit.setGlitchModifier(.2);
			case 'bazinga' | 'crucify' | 'hallow' | 'hardships' | 'portrait' | 'run':
				moreDark = new FlxSprite(0, 0).loadGraphic(Paths.image('effectShit/evenMOREdarkShit'));
				moreDark.cameras = [camHUD];
				add(moreDark);
			case 'prayer':
				vignette = new FlxSprite().loadGraphic(Paths.image("vignette"));
				vignette.cameras = [camHUD];
				add(vignette);
				vignette.alpha = 0;
			case 'bad-nun':
				beatClass = shaders.BadNun;
		}

		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		startingSong = true;

		var cutscenePath:String = 'assets/data/${SONG.song.toLowerCase()}/cutscene.hx';
		if (Assets.exists(cutscenePath))
		{
			inCutscene = true;
			var cutsceneScript:GameScript = new GameScript(cutscenePath);
			scripts.add(cutsceneScript);
			cutsceneScript.callFunction("onCreate");
		}
		else if (isStoryMode && dialogue.length > 0 && !skipDialogue)
		{
			switch (curSong.toLowerCase())
			{
				case 'bazinga':
					jumpscare(doof);
				default:
					if (curSong.toLowerCase() == 'chicken-sandwich')
						FlxG.sound.play(Paths.sound('ANGRY'));

					openDialogue(doof);
			}
		}
		else
		{
			startCountdown();
		}

		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		onGameResize(FlxG.stage.window.width, FlxG.stage.window.height);

		for (i in [false, true]) // call both of these so BF_CAM_POS and DAD_CAM_POS are set
			moveCamera(i);

		moveCamera(!PlayState.SONG.notes[curSection].mustHitSection);

		songScript = new GameScript();
		songScript.callFunction("onCreate");

		scripts.callFunction("onCreatePost");
		scripts.add(songScript);

		System.gc();
	}

	function jumpscare(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var culo:Bool = FlxG.random.bool(1);

		var jumpscare:FlxSprite = new FlxSprite(0, 0);
		jumpscare.frames = Paths.getSparrowAtlas('dialogue/jumpscare' + (culo ? "RARE" : ""));
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
			add(dialogueBox);
		});
	}

	function openDialogue(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		add(dialogueBox);
	}

	var startTimer:FlxTimer;

	#if windows
	public static var luaModchart:ModchartState = null;
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
				var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

				babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
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
		startedCountdown = true;
		skipDialogue = true;
		inCutscene = false;

		generateStaticArrows(cpuStrums, FlxG.width * 0.25);
		generateStaticArrows(playerStrums, FlxG.width * 0.75);

		#if windows
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [PlayState.SONG.song]);
		}
		#end

		Conductor.songPosition = -Conductor.crochet * 5;

		if (SONG.song.toLowerCase() == 'dead-mans-melody')
		{
			return;
		}

		var introAssets:Map<String, Array<String>> = [
			'default' => ['ready', "set", "go", "shared", ""],
			'school' => [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel',
				'week6',
				"-pixel"
			],
			'schoolEvil' => [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel',
				'week6',
				"-pixel"
			],
		];

		var introAlts:Array<String> = introAssets.get('default');
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

			if (introAssets.exists(curStage))
			{
				introAlts = introAssets[curStage];
				altSuffix = introAlts[4];
			}
			else
			{
				if (SONG.bpm <= 140)
					altSuffix = '-long';
			}

			FlxG.sound.play(Paths.sound('intro' + (swagCounter == 3 ? 'Go' : '${3 - swagCounter}') + altSuffix), 0.6);
			if (swagCounter > 0)
			{
				var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[swagCounter - 1], introAlts[3]));
				sprite.updateHitbox();

				if (curStage.startsWith('school'))
					sprite.setGraphicSize(Std.int(sprite.width * daPixelZoom));
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
			}

			#if cpp
			System.gc();
			cpp.vm.Gc.run(true);
			#end

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

		var peSUS:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/endDia')));
		peSUS.scrollFactor.set();
		peSUS.finishThing = endSong;
		peSUS.cameras = [camHUD];
		add(peSUS);
	}

	function startSong():Void
	{
		startingSong = false;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		if (isStoryMode && Assets.exists(Paths.txt(SONG.song.toLowerCase() + '/endDia')))
		{
			FlxG.sound.music.onComplete = endingDialogue;
		}
		else
		{
			FlxG.sound.music.onComplete = endSong;
		}

		vocals.play();

		songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
		if (ClientPrefs.downscroll)
			songPosBG.y = FlxG.height * 0.9 + 45;
		songPosBG.screenCenter(X);
		songPosBG.scale.set(0.8, 0.8);

		songName = new FlxText(0, songPosBG.y + (songPosBG.height / 2), 0, '', 16);
		songName.text = CoolUtil.capitalizeFirstLetters(StringTools.replace(SONG.song, '-', ' ')) + ' - ${Song.getArtist(curSong)}';
		songName.y -= songName.height / 2;

		songName.antialiasing = true;
		songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.borderSize = 1.25;
		songName.screenCenter(X);

		if (ClientPrefs.songPosition)
		{
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, FlxG.sound.music.length
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.createFilledBar(0xFF662C77, 0xFFC353E3);
			songPosBar.scale.set(songPosBG.scale.x, songPosBG.scale.y);
			add(songPosBar);

			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
		else
		{
			add(songName);
			songName.cameras = [camHUD];

			songName.size = 20;
			songName.alpha = 0;
			FlxTween.tween(songName, {alpha: 1}, 0.7, {
				onComplete: (twn) ->
				{
					new FlxTimer().start(5.8, (t) ->
					{
						FlxTween.tween(songName, {alpha: 0}, 0.7);
					});
				}
			});
		}

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ if (curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish") "im not leaking" else SONG.song + " (" + storyDifficultyText
				+ ") " + Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private function generateSong(dataPath:String):Void
	{
		Conductor.changeBPM(SONG.bpm);
		curSong = SONG.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song), false);
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		add(notes);
		add(currentTimingShown);

		for (section in SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] < 0 ? 0 : songNotes[0] + ClientPrefs.offset;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var noteType:Int = songNotes[3];
				var gottaHitNote:Bool = songNotes[1] > 3 ? !section.mustHitSection : section.mustHitSection;

				unspawnNotes.push({
					strumTime: daStrumTime,
					noteData: daNoteData,
					mustPress: gottaHitNote,
					sustainLength: songNotes[2],
					type: noteType
				});
			}
		}

		unspawnNotes.sort((Obj1:QueuedNote, Obj2:QueuedNote) ->
		{
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
		});

		generatedMusic = true;
	}

	private function generateStaticArrows(grp:FlxTypedGroup<FlxSprite>, centerPoint:Float):Void
	{
		var square:FlxSprite = new FlxSprite();
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

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));

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
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
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

		if (centerPoint < 1280 / 2)
		{
			square.makeGraphic(Std.int(strumLineNotes.members[0].x + (Note.swagWidth * 3.2)), 720, FlxColor.BLACK);
			square.setPosition(strumLineNotes.members[0].x, 0);
		}
		else
		{
			square.loadGraphicFromSprite(lanes.members[0]);
			square.setPosition(playerStrums.members[0].x, 0);
		}

		square.alpha = FlxG.save.data.laneTransparency * 0.01;
		lanes.add(square);
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
				+ if (curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish") "im not leaking" else SONG.song + " (" + storyDifficultyText
					+ ") " + Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
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
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			@:privateAccess
			for (i in FlxTween.globalManager._tweens)
			{
				i.active = true;
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;

			paused = false;

			#if windows
			if (startTimer == null || startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ if (curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish") "im not leaking" else SONG.song + " ("
						+ storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ FlxMath.roundDecimal(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					FlxG.sound.music.length
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText,
					if (curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish") "im not leaking" else SONG.song + " ("
						+ storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),
					iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (!vocals.playing && !paused)
			return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ if (curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish") "im not leaking" else SONG.song + " (" + storyDifficultyText
				+ ") " + Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var hurtTimer:Float = 0;

	override public function update(elapsed:Float)
	{
		scripts.updateVars();

		if (FlxG.keys.justPressed.T && SONG.song.toLowerCase() == 'party-crasher')
		{
			setSongTime(18613); // SKI P THE FUCKING PARYCRASHER INTRO I HATE IT
		}

		if (curStage == 'finale')
		{
			sky.x -= 0.05;
			buildings3.x -= 0.6 * Conductor.crochet / 50;
			buildings2.x -= 0.7 * Conductor.crochet / 50;
			buildings1.x -= 0.8 * Conductor.crochet / 50;
			ShadersHandler.setBloom(daVal);
		}

		if (FlxG.keys.justPressed.U)
		{
			Achievements.getAchievement(15);
		}

		#if debug
		if (FlxG.keys.anyJustPressed([TWO, THREE, FOUR]))
		{
			songJump(FlxG.keys.justPressed.TWO ? 3 : FlxG.keys.justPressed.THREE ? 10 : 30);
		}
		#end

		if (mashPity > 0)
		{
			mashPity -= elapsed;
		}

		if (easierMode == true)
		{
			health += 0.0001;
		}

		hurtTimer -= elapsed;

		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
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

			if (!opponent)
			{
				var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
				var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

				for (i in 0...4)
				{
					strumLineNotes.members[i].visible = p1;
					if (i <= playerStrums.length)
						playerStrums.members[i].visible = p2;
				}
			}
		}
		#end

		if (!inCutscene)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (boyfriend.animation.curAnim.name.startsWith("idle"))
					boyfriend.playAnim('hey');

				if (!gf.animation.paused && gf.animation.curAnim.name.startsWith("dance"))
					gf.playAnim('cheer');
			}

			if (FlxG.keys.justPressed.NINE)
			{
				if (iconP1.curCharacter == 'bf-old')
					iconP1.swapCharacter(boyfriend.curCharacter);
				else
					iconP1.swapCharacter('bf-old');
			}
		}

		if (FlxG.save.data.shaders)
		{
			if (wiggleEffect != null)
			{
				wiggleEffect.update(elapsed);
			}

			if (tvshit != null)
			{
				tvshit.update(elapsed);
			}
		}

		super.update(elapsed);
		scripts.callFunction("onUpdate", [elapsed]);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			@:privateAccess
			for (i in FlxTween.globalManager._tweens)
			{
				i.active = false;
			}

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
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

		if (health > 2)
			health = 2;

		if (health < 0 && opponent)
			health = 0;

		if (health >= 1.75 && hurtTimer <= 0)
		{
			iconP2.animation.play(opponent ? 'winning' : 'hurt');
			iconP1.animation.play(opponent ? 'hurt' : 'winning');
		}
		else if (health <= 0.65 || hurtTimer > 0)
		{
			iconP2.animation.play(opponent ? 'hurt' : 'winning');
			iconP1.animation.play(opponent ? 'winning' : 'hurt');
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
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

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

		if (health <= 0 && !opponent)
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
				+ if (curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish") "im not leaking" else SONG.song + " (" + storyDifficultyText
					+ ") " + Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}

		if (ClientPrefs.resetButton && FlxG.keys.justPressed.R)
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
				+ if (curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish") "im not leaking" else SONG.song + " (" + storyDifficultyText
					+ ") " + Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var data:QueuedNote = unspawnNotes[0];
				var note = notes.recycle(Note);
				note.create(data.strumTime, data.noteData, null, false, data.type);
				note.mustPress = data.mustPress;
				notes.add(note);

				if (data.sustainLength > 0)
				{
					var susLength:Float = data.sustainLength / Conductor.stepCrochet;
					var prevSus:Note = null;

					for (susNote in 0...Math.floor(susLength))
					{
						var sustainNote:Note = notes.recycle(Note);
						sustainNote.create(data.strumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, data.noteData,
							prevSus == null ? note : prevSus, true);
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

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.type == 1
					&& !daNote.animPlayed
					&& Conductor.songPosition >= daNote.strumTime - 750
					&& (opponent ? !daNote.mustPress : daNote.mustPress))
				{
					summonPainting();
					daNote.animPlayed = true;
				}

				// trying to do cool modchart stuff and the kade engine code for this stuff was annoying so i rewrote it
				// like there was no reason to tie the sustain note clipping to be disabled when modifiedByLua is true LMAO
				var strum = strumLineNotes.members[(daNote.mustPress ? 4 : 0) + daNote.noteData];
				if (!daNote.modifiedByLua)
				{
					daNote.x = strum.x;
					if (ClientPrefs.downscroll)
						daNote.y = strum.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
					else
						daNote.y = strum.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

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
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							daNote.clipRect = FlxRect.weak(0, daNote.frameHeight - (daNote.frameHeight * 2), daNote.frameWidth * 2,
								(cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y);
						}
					}
					else
					{
						daNote.y -= daNote.height / 2;

						if (daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect = FlxRect.weak(0,
								(cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y,
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
						if (!opponent && SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					curOpponent.holdTimer = 0;
					// Accessing the animation name directly to play it
					if (curSong == 'Princess' && (curBeat == 303 || curBeat == 367) && daNote.noteData == 2)
					{
						curOpponent.playAnim('singLaugh', true);
					}
					else
					{
						curOpponent.playAnim('sing' + dataSuffix[daNote.noteData] + altAnim, true);
						if (curStage == 'schoolEvil')
						{
							meat.playAnim('sing' + dataSuffix[daNote.noteData] + altAnim, true);
						}
					}

					if (!opponent)
					{
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
									hurtTimer = 0.45;
									switch (curSong)
									{
										case 'Prayer':
											if (curStep >= 1359 && curStep < 1422) health -= 0.025; else if (curStep < 1681)
												health -= health > 0.2 ? 0.02 : 0.0065;
										case 'Crucify':
											health -= (daNote.isSustainNote ? 0.01 : 0.03);
										case 'Bazinga':
											health -= (daNote.isSustainNote ? 0.01435 : 0.025);
										default:
											health -= 0.02;
									}
									if (!minus)
										gf.playAnim('scared');
								case 'hallow':
									if (healthBar.percent > 5)
									{
										health -= 0.05;
									}
							}
						}
						else if (storyDifficulty == 0)
						{
							health += 0.03;
						}
						else
						{
							health -= 0.04;
						}
					}
					else
						health -= 0.04;

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

				if (daNote.mustPress && (daNote.strumTime - Conductor.songPosition) < -166)
				{
					if (daNote.type == 0)
					{
						health -= 0.075;
						vocals.volume = 0;
						noteMiss(daNote.noteData);
					}
					else if (daNote.type == 1 && !opponent)
					{
						health = -1;

						diedtoHallowNote = true;

						vocals.volume = 0;
					}

					daNote.kill();
					daNote.exists = false;
				}
			});
		}

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
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		scripts.callFunction("onPostUpdate", [elapsed]);
	}

	public var DAD_CAM_POS:FlxPoint = new FlxPoint(0, 0);
	public var BF_CAM_POS:FlxPoint = new FlxPoint(0, 0);

	public function moveCamera(isDad:Bool = false)
	{
		if (isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

			switch (dad.curCharacter)
			{
				case 'mom' | 'mom-carnight' | 'mom-car':
					camFollow.y = dad.getMidpoint().y + 90;
				case 'senpai' | 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 130;
					camFollow.x = dad.getMidpoint().x + 175;
				case 'peakek' | 'peasus':
					camFollow.x = dad.getMidpoint().x - -400;
				case 'spooky' | 'feralspooky':
					camFollow.x = dad.getMidpoint().x + 190;
					camFollow.y = dad.getMidpoint().y - 30;
				case 'taki':
					camFollow.x = dad.getMidpoint().x + 155;
					camFollow.y = minus ? dad.getMidpoint().y + 150 : dad.getMidpoint().y - 50;
				case 'monster':
					if (SONG.song.toLowerCase() == 'prayer')
					{
						camFollow.x = dad.getMidpoint().x - -560;
						camFollow.y = dad.getMidpoint().y - -100;
					}
					else
					{
						camFollow.x = dad.getMidpoint().x - -400;
						camFollow.y = dad.getMidpoint().y - -100;
					}
				case 'pepper':
					camFollow.y = dad.getMidpoint().y += 65;
					camFollow.x = dad.getMidpoint().x += 40;
					defaultCamZoom = 0.8;
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
							case 'limo':
								camFollow.x = dad.getMidpoint().x + 300;
								camFollow.y = dad.getMidpoint().y;
							case 'default' | 'whitty':
								camFollow.y = dad.getMidpoint().y - 290;
								camFollow.x = dad.getMidpoint().x - -490;
						}
					}
					else
					{
						camFollow.y = dad.getMidpoint().y - 150;
						camFollow.x = dad.getMidpoint().x - -600;
					}
				case 'tea-bat':
					camFollow.x = dad.getMidpoint().x - -600;
					camFollow.y = dad.getMidpoint().y - -150;
				case 'yukichi':
					camFollow.x = dad.getMidpoint().x - -423;
					camFollow.y = dad.getMidpoint().y - 280;
				case 'pico' | 'makocorrupt':
					camFollow.x = dad.getMidpoint().x - -350;
					camFollow.y = dad.getMidpoint().y - 60;
				case 'bdbfever':
					camFollow.x = dad.getMidpoint().x + 200;
					camFollow.y = dad.getMidpoint().y - 80;
				case 'gf':
					camFollow.y = dad.getMidpoint().y - 50;
				case 'flippy':
					camFollow.x = dad.getMidpoint().x + 90;
					camFollow.y = dad.getMidpoint().y + 40;
				case 'robofvr-final':
					camFollow.x = dad.getMidpoint().x + 350;
					camFollow.y = dad.getMidpoint().y + 150;
			}

			DAD_CAM_POS.set(camFollow.x, camFollow.y);
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (boyfriend.curCharacter)
			{
				case 'bf':
					if (curStage == 'week5' || curStage == 'week5othercrowd')
						defaultCamZoom = 0.6;
			}

			switch (curStage)
			{
				case 'stage':
					camFollow.x = boyfriend.getMidpoint().x - 350;
					camFollow.y -= 100;
				case 'limo' | 'limonight':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 330;
					camFollow.y = boyfriend.getMidpoint().y - 15;
				case 'spooky' | 'spookyBOO':
					camFollow.x = boyfriend.getMidpoint().x - 355;
					camFollow.y = boyfriend.getMidpoint().y - 250;
				case 'church':
					camFollow.x = boyfriend.getMidpoint().x - 465;
					camFollow.y = boyfriend.getMidpoint().y - 365;
				case 'spookyHALLOW':
					camFollow.x = boyfriend.getMidpoint().x - 250;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'week5' | 'ripdiner' | 'week5othercrowd':
					camFollow.x = boyfriend.getMidpoint().x - 350;
					camFollow.y = boyfriend.getMidpoint().y - 340;

				case 'week3stage':
					camFollow.x = boyfriend.getMidpoint().x - 380;
				case 'princess':
					camFollow.y = boyfriend.getMidpoint().y - 330;
					camFollow.x = boyfriend.getMidpoint().x - 450;
				case 'finale':
					camFollow.y = boyfriend.getMidpoint().y - 500;
					camFollow.x = boyfriend.getMidpoint().x - 800;
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
					camFollow.x = boyfriend.getMidpoint().x - 180;
					camFollow.y = boyfriend.getMidpoint().y - 320;
			}

			BF_CAM_POS.set(camFollow.x, camFollow.y);
		}

		scripts.callFunction("onMoveCamera", [isDad]);
	}

	function updateScoring(bop:Bool = false)
	{
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScore, accuracy);
		scoreTxt.screenCenter(X);

		if (bop)
		{
			if (disableScoreBop)
				return;

			if (scoreBop != null)
				scoreBop.cancel();

			scoreTxt.scale.set(scoreTxt.scale.x < 0.9 ? 0.875 : 1.05, scoreTxt.scale.y < 0.9 ? 0.875 : 1.05);
			scoreBop = FlxTween.tween(scoreTxt.scale, {x: scoreTxt.scale.x < 0.9 ? 0.8 : 1, y: scoreTxt.scale.y < 0.9 ? 0.8 : 1}, 0.24, {
				onComplete: (twn) ->
				{
					scoreBop = null;
				}
			});
		}
	}

	function endSong():Void
	{
		skipDialogue = false;

		if (ClientPrefs.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

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
		if (SONG.validScore)
		{
			if (!ClientPrefs.botplay && misses == 0 && !Highscore.fullCombos.exists(SONG.song))
				Highscore.fullCombos.set(SONG.song, 0);

			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
		}

		if (isStoryMode)
		{
			campaignScore += Math.round(songScore);

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

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();

				endingSong = true;

				if (storyWeek != StoryMenuState.weekData.length - 1)
				{
					Main.playFreakyMenu();
					FlxG.switchState(new StoryMenuState());
				}
				else
				{
					for (week in 1...StoryMenuState.weekData.length)
					{
						var break_MainLoop:Bool = false;
						for (difficulty in 0...3)
						{
							if (Highscore.getWeekScore(week, difficulty) > 0)
								break;

							if (difficulty == 2) // if this loop never breaks
								break_MainLoop = true;
						}

						if (break_MainLoop)
						{
							Main.playFreakyMenu();
							FlxG.switchState(new StoryMenuState());
							break;
						}

						if (week == StoryMenuState.weekData.length - 1)
						{
							FlxG.switchState(new CreditsState());
						}
					}
				}
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0 || storyDifficulty == 1)
					difficulty = '-easy';

				if (storyDifficulty == 3 || storyDifficulty == 4)
					difficulty = '-hard';

				trace('LOADING NEXT SONG: ' + PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			Main.playFreakyMenu();
			FlxG.switchState(new FreeplayState());
		}
	}

	public var curComboSprites:Array<FlxSprite> = [];

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var wife:Float = Ratings.wife3(noteDiff, Conductor.timeScale);
		var assetLib:String = usePixelAssets ? 'week6' : 'shared';

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		var daRating = daNote.rating;

		vocals.volume = 1;
		totalNotesHit += wife;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				FlxG.save.data.misses++;
				health -= 0.2;
				shits++;
			case 'bad':
				score = 0;
				health -= 0.06;
				bads++;
			case 'good':
				score = 200;
				goods++;
				if (health < 2)
					health += 0.02;
			case 'sick':
				if (health < 2)
					health += 0.04;
				sicks++;

				if (ClientPrefs.notesplash)
				{
					var splash:NoteSplash = new NoteSplash(playerStrums.members[daNote.noteData].x, playerStrums.members[daNote.noteData].y, daNote.noteData);
					splash.cameras = [camHUD];
					add(splash);
				}
		}

		songScore += score;

		if (daRating != 'miss') // wtf
		{
			var pixelShitPart1:String = usePixelAssets ? 'weeb/pixelUI/' : '';
			var pixelShitPart2:String = usePixelAssets ? '-pixel' : '';

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2, assetLib));
			rating.setPosition((FlxG.width * 0.55) - 125, (FlxG.height * 0.5) - (rating.height / 2) - 50);
			rating.velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 175));
			rating.acceleration.y = 550;
			curComboSprites.push(rating);

			if (!disableHUD)
			{
				if (songScript.variables.exists("forceComboPos")
					&& (songScript.variables["forceComboPos"].x != 0 || songScript.variables["forceComboPos"].y != 0))
				{
					rating.x = songScript.variables["forceComboPos"].x;
					rating.y = songScript.variables["forceComboPos"].y;
				}
				else if (ClientPrefs.changedHit)
				{
					rating.x = ClientPrefs.changedHitX;
					rating.y = ClientPrefs.changedHitY;
				}
			}
			else
			{
				rating.x = cpuStrums.members[cpuStrums.length - 1].x + cpuStrums.members[cpuStrums.length - 1].width;
				rating.y = cpuStrums.members[cpuStrums.length - 1].y;
				rating.alpha = 0.6;
			}

			if (usePixelAssets)
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
			}

			rating.updateHitbox();
			rating.cameras = [camHUD];
			add(rating);

			FlxTween.cancelTweensOf(currentTimingShown);
			currentTimingShown.text = (FlxG.save.data.botplay ? 0 : FlxMath.roundDecimal(noteDiff, 2)) + 'ms';
			currentTimingShown.setPosition(rating.x + 140, rating.y + 100);
			currentTimingShown.velocity.set(FlxG.random.int(1, 10), -150);
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.alpha = 1;

			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = 0xFFC4012D;
				case 'good':
					currentTimingShown.color = 0xFFE398DD;
				case 'sick':
					currentTimingShown.color = 0xFF7A55BB;
			}

			if (combo >= 10 || combo == 0)
			{
				var seperatedScore:Array<String> = (combo + "").split('');

				if (seperatedScore.length == 2)
					seperatedScore.insert(0, "0");

				var daLoop:Int = 0;
				for (i in seperatedScore)
				{
					var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2, assetLib));
					numScore.x = rating.x + (43 * daLoop) - 50;
					numScore.y = rating.y + 100 + (usePixelAssets ? 30 : 0);
					numScore.cameras = [camHUD];
					numScore.alpha = rating.alpha;

					if (usePixelAssets)
					{
						numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
					}
					else
					{
						numScore.antialiasing = true;
						numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					}

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);

					add(numScore);

					if (curSong.toLowerCase() == 'tranquility')
						numScore.shader = wiggleEffect.shader;

					FlxTween.tween(numScore, {alpha: 0}, 0.5, {
						onComplete: function(tween:FlxTween)
						{
							numScore.kill();
							curComboSprites.remove(numScore);
							numScore.exists = false;
						},
						startDelay: 0.3
					});

					daLoop++;
					curComboSprites.push(numScore);
				}
			}

			FlxTween.tween(currentTimingShown, {alpha: 0}, 0.45, {startDelay: 0.27});

			FlxTween.tween(rating, {alpha: 0}, 0.45, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
					curComboSprites.remove(rating);
					rating.exists = false;
				},
				startDelay: 0.27
			});
		}

		updateScoring();
	}

	private function keyShit():Void // The input system has been (almost) completely rewritten, however logic for sustain notes and botplay still exists here.
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		// Prevent player input if botplay is on
		if (FlxG.save.data.botplay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
		}

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic)
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

		if (FlxG.save.data.botplay)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && daNote.strumTime - Conductor.songPosition <= 40)
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
				fevercamX = 0;
				fevercamY = 0;
			}
		}

		strumLineNotes.forEach((spr) ->
		{
			spr.centerOffsets();
			spr.centerOrigin();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!opponent && combo >= 10)
			gf.playAnim('sad');

		health -= 0.04;
		songScore -= 10;
		combo = 0;
		misses++;
		FlxG.save.data.misses++;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		if (boyfriend.animation.curAnim.name != 'shoot')
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

	var etternaModeScore:Int = 0;

	function goodNoteHit(note:Note):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = FlxG.save.data.botplay ? "sick" : Ratings.CalculateRating(noteDiff);

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

			if (boyfriend.animation.curAnim.name != 'shoot')
			{
				curPlayer.holdTimer = 0;
				curPlayer.playAnim('sing' + dataSuffix[note.noteData] + altSuffix, true);
			}

			switch (note.noteData)
			{
				case 3:
					fevercamX = 25;
					fevercamY = 0;
				case 2:
					fevercamY = -25;
					fevercamX = 0;
				case 1:
					fevercamY = 25;
					fevercamX = 0;
				case 0:
					fevercamX = -25;
					fevercamY = 0;
			}

			if (opponent && (dad.curCharacter == 'taki' || dad.curCharacter == 'monster'))
			{
				gf.playAnim('scared');
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

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var daVal:Float = 0.3;
	var emitt:FlxTypedGroup<FlxEmitter>;
	var emitter:FlxEmitter;

	override function stepHit()
	{
		super.stepHit();

		scripts.callFunction("onStepHit", [curStep]);

		if (subtitles != null)
		{
			subtitles.stepHit(curStep);
		}

		if (curSong == "Gears-------------fr") // making this stuff not get called for rn as it overlaps with the falling part and breaks stuff
		{
			switch (curStep)
			{
				case 1728:
					defaultCamZoom = 0.5;
					camHUD.flash(FlxColor.WHITE, 1);
					daVal = 0.4;
				case 1984:
					defaultCamZoom = 0.4;
					FlxTween.tween(this, {daVal: 0.7}, 1);

					emitt = new FlxTypedGroup<FlxEmitter>();
					add(emitt);
					for (i in 0...3)
					{
						emitter = new FlxEmitter(FlxG.width * 1.85 / 2 - 2500, 1300);
						emitter.scale.set(0.9, 0.9, 2, 2, 0.9, 0.9, 1, 1);
						emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
						emitter.width = FlxG.width * 10;
						emitter.alpha.set(1, 1, 1, 0);
						emitter.lifespan.set(5, 10);
						emitter.launchMode = FlxEmitterMode.SQUARE;
						emitter.velocity.set(-50, -150, 50, -750, -100, 0, 100, -100);
						emitter.loadParticles(Paths.image('roboStage/part'), 500, 16, true);
						emitter.start(false, FlxG.random.float(0.2, 0.3), 10000000);
						emitt.add(emitter);
					}
				case 2240:
					defaultCamZoom = 0.3;
					FlxTween.tween(this, {daVal: 0.3}, 1);
					remove(emitt);
				case 2496:
					defaultCamZoom = 0.4;
					FlxTween.tween(this, {daVal: 0.6}, 0.5);
				case 2754:
					defaultCamZoom = 0.3;
					camHUD.flash(FlxColor.WHITE, 1);
					daVal = 0.3;
			}
		}

		if (curSong == 'Bazinga')
		{
			switch (curStep)
			{
				case 121:
					health += 0.32;
				case 1476 | 1508:
					if (!minus)
						characterTrail.visible = false;
					defaultCamZoom = 0.95;
				case 1500 | 1522:
					if (curStep == 1522 && !minus)
						characterTrail.visible = true;
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

		if (SONG.song.toLowerCase() == 'princess')
		{
			switch (curStep)
			{
				case 128:
					camHUD.flash(FlxColor.WHITE, 0.5);
					princessBG.visible = true;
					princessFloor.visible = true;
					princessCrystals.visible = true;
					defaultCamZoom = 0.65;
					gf.y += 60;
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

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
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

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ if (curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish") "im not leaking" else SONG.song + " (" + storyDifficultyText
				+ ") " + Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			FlxG.sound.music.length
			- Conductor.songPosition);
		#end
	}

	public function setSongTime(time:Float) // I HATE THE PARTY CRASHER INTRO ITS SO FUCKING LONG
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}

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

		// reset cam lerp
		FlxG.camera.followLerp = 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS());

		if (beatClass != null)
		{
			Reflect.callMethod(beatClass, Reflect.field(beatClass, "beatHit"), [curBeat]);
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'hardships':
					if (curBeat == 158)
						boyfriend.useAlternateIdle = true;
				case 'loaded':
					roboStage.beatHit(curBeat);
				case 'soul' | 'portrait':
					switch (curBeat)
					{
						case 32:
							camHUD.flash(FlxColor.WHITE, 0.5);

							if (FlxG.save.data.shaders)
							{
								wiggleEffect = new WiggleEffect();
								wiggleEffect.effectType = WiggleEffectType.WAVY;
								wiggleEffect.waveAmplitude = 0.05;
								wiggleEffect.waveFrequency = 3;
								wiggleEffect.waveSpeed = 1;

								// filters.push(wiggleEffect.shader);
								// camGame.filtersEnabled = true;
								painting.shader = wiggleEffect.shader;
							}

							if (curSong == 'Portrait')
							{
								painting.visible = true;

								if (FlxG.save.data.shaders)
								{
									filters.push(ShadersHandler.chromaticAberration);
									camfilters.push(ShadersHandler.chromaticAberration);
									ShadersHandler.setChrome(FlxG.random.int(2, 2) / 1000);

									camHUD.filtersEnabled = true;
									camGame.filtersEnabled = true;
								}
							}
					}
				case 'tranquility':
					switch (curBeat)
					{
						case 48:
							disableCamera = true;
							FlxTween.tween(camFollow, {y: camFollow.y - 550}, 0.64);
							FlxTween.tween(blackScreen, {alpha: 1}, 0.58, {
								onComplete: (twn) ->
								{
									FlxTween.tween(wiggleEffect, {waveAmplitude: 0}, 0.6);
									FlxTween.cancelTweensOf(purpleOverlay);
									FlxTween.tween(purpleOverlay, {alpha: 0}, 0.1);
									try
									{
										@:privateAccess FlxTimer.globalManager._timers[0].cancel();
									}
									catch (e)
									{
									}
									disableHUD = true;
									for (i in strumLineNotes)
										FlxTween.tween(i, {alpha: 0.6}, 0.6);
									for (i in [iconP1, iconP2, healthBar, healthBarBG])
										FlxTween.tween(i, {alpha: 0}, 0.46, {
											onComplete: (twn) ->
											{
												if (i == healthBarBG)
												{
													FlxTween.tween(scoreTxt, {y: ClientPrefs.downscroll ? scoreTxt.y - 80 : scoreTxt.y + 80}, 0.38);
													disableScoreBop = true;
													FlxTween.tween(scoreTxt.scale, {x: 0.8, y: 0.8}, 0.38, {
														onComplete: (twn) ->
														{
															disableScoreBop = false;
														}
													});
												}
											}
										});
								}
							});
						case 146:
							for (i in [dad, boyfriend, gf])
							{
								i.color = FlxColor.WHITE;
								FlxTween.color(i, 3, FlxColor.WHITE, FlxColor.fromString("#C956FF"));
							}
							FlxTween.tween(whittyBG, {alpha: 0.65}, 3);
						case 176 | 180 | 194:
							FlxTween.tween(whittyBG, {alpha: 0.9}, (Conductor.crochet / 1000) * 2);
						case 178 /* | 192 */:
							FlxTween.tween(whittyBG, {alpha: 0.65}, (Conductor.crochet / 1000) * 2);
						case 208:
							for (i in [dad, boyfriend, gf])
							{
								FlxTween.color(i, (Conductor.crochet / 1000) * 2, FlxColor.fromString("#C956FF"), FlxColor.WHITE);
							}
							FlxTween.tween(whittyBG, {alpha: 1}, (Conductor.crochet / 1000) * 2);
						case 304:
							try
							{
								@:privateAccess FlxTimer.globalManager._timers[0].cancel();
							}
							catch (e)
							{
							}
							FlxTween.tween(purpleOverlay, {alpha: 0}, 2.6);
							FlxTween.tween(wiggleEffect, {waveAmplitude: 0}, 2.6);
					}
				case 'party-crasher':
					switch (curBeat)
					{
						case 95 | 159:
							FlxG.camera.shake(0.09, Conductor.crochet / 1000);
							camHUD.shake(0.09, Conductor.crochet / 1000);
						case 96:
							if (FlxG.save.data.shaders)
							{
								camGame.filtersEnabled = true;

								modchart.addCamEffect(tvshit);
							}
							pixelDiner.visible = true;

							bottomBoppers.loadGraphic(Paths.image('boppers/finalcrowdpixel', 'week5'));
							bottomBoppers.setPosition(-600, 840);
							bottomBoppers.antialiasing = false;
							bottomBoppers.updateHitbox();

							boyfriend.visible = false;
							fever_pixel.visible = true;

							gf.visible = false;
							tea_pixel.visible = true;
							iconP1.swapCharacter('bf-pixeldemon');

							curPlayer = fever_pixel;
							changeStrums(true);

							scoreTxt.setFormat(Paths.font("Retro Gaming.ttf"), #if !mobile 18 #else 24 #end, FlxColor.WHITE, CENTER,
								FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							font = true;
						case 160:
							if (FlxG.save.data.shaders)
							{
								camfilters.remove(ShadersHandler.scanline);
								camHUD.filtersEnabled = false;
								modchart.removeCamEffect(tvshit);
							}

							pixelDiner.visible = false;

							iconP1.swapCharacter('bf-demon');
							bottomBoppers.loadGraphic(Paths.image('boppers/finalcrowd', 'week5'));
							bottomBoppers.updateHitbox();
							bottomBoppers.setPosition(-635, 830);
							bottomBoppers.antialiasing = true;

							fever_pixel.visible = false;
							boyfriend.visible = true;

							gf.visible = true;
							tea_pixel.visible = false;

							curPlayer = boyfriend;

							changeStrums();

							font = false;
							scoreTxt.setFormat(Paths.font("vcr.ttf"), #if !mobile 18 #else 24 #end, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,
								FlxColor.BLACK);
					}
				case 'star-baby':
					switch (curBeat)
					{
						case 128:
							defaultCamZoom += 0.17;
							FlxTween.color(spookyBG, 0.45, FlxColor.WHITE, FlxColor.fromString("#828282"));
							FlxTween.color(gf, 0.45, FlxColor.WHITE, FlxColor.fromString("#828282"));
						case 192:
							defaultCamZoom -= 0.17;
							FlxTween.color(spookyBG, 0.45, FlxColor.fromString("#828282"), FlxColor.WHITE);
							FlxTween.color(gf, 0.45, FlxColor.fromString("#828282"), FlxColor.WHITE);
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
						for (i in takiBGSprites)
							i.visible = true;
					}
			}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (ClientPrefs.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

			if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
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
			var specialAnims:Array<String> = ['dodge', 'hey', 'shoot'];
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

		if (boyfriend.animation.curAnim.name != 'hey')
		{
			if (curBeat % gfSpeed == 0)
			{
				if (gf.animation.curAnim.name != 'scared' || gf.animation.curAnim.name == 'scared' && dad.holdTimer < -0.35)
					gf.dance();

				if (tea_pixel != null)
				{
					tea_pixel.dance();
				}
			}
		}

		if (!curPlayer.animation.curAnim.name.startsWith("sing") && !opponent)
		{
			var specialAnims:Array<String> = ['dodge', 'hey', 'shoot'];
			if (!specialAnims.contains(curPlayer.animation.curAnim.name) || curPlayer.animation.finished)
			{
				curPlayer.dance();
			}
		}

		if (opponent && !curPlayer.animation.curAnim.name.startsWith("sing"))
		{
			curPlayer.dance();
		}

		switch (curStage)
		{
			case 'schoolEvil':
				if (meat != null && !meat.animation.curAnim.name.startsWith("sing"))
					meat.dance();
			case 'finale':
				train.animation.play('drive');
			case 'school':
				if (SONG.song.toLowerCase() != 'space-demons')
				{
					bgGirls.dance();
				}
			case 'week5' | 'week5othercrowd' | 'ripdiner':
				bottomBoppers.beatHit();
			case 'limo' | 'limonight':
				if (FlxG.save.data.distractions)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});

					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}
			case 'stage':
				if (curBeat % 2 == 0)
				{
					if (w1city.animation.curAnim.curFrame > 2)
						w1city.animation.curAnim.curFrame = 0;
					else
						w1city.animation.curAnim.curFrame++;
				}
		}
	}

	function summonPainting()
	{
		var mechanic = new FlxSprite(1240, 300);
		mechanic.frames = Paths.getSparrowAtlas('mechanicShit/paintingShit');
		mechanic.animation.addByPrefix('idle', 'paintingShit', 30, false);
		mechanic.antialiasing = true;

		mechanic.animation.play('idle');
		add(mechanic);
		mechanic.animation.finishCallback = function(anim)
		{
			remove(mechanic);
		}
	}

	override function add(object:FlxBasic):FlxBasic
	{
		if (!ClientPrefs.antialiasing && Reflect.field(object, "antialiasing") != null)
		{
			Reflect.setField(object, "antialiasing", false);
		}

		return super.add(object);
	}

	// NEW INPUT SHIT
	var keybinds(get, never):Array<String>;
	var keysHeld:Array<Bool> = [false, false, false, false];
	var mashPity:Float = 0;

	function get_keybinds():Array<String>
	{
		return [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];
	}

	private function onKeyPress(input:KeyboardEvent)
	{
		if (paused || inCutscene)
			return;

		// Stolen from my engine, changed shit to support kade engine
		var key:Int = -1;

		@:privateAccess
		key = keybinds.indexOf(FlxKey.toStringMap[input.keyCode]);

		if (key == -1)
		{
			switch (input.keyCode) // arrow keys
			{
				case 37:
					key = 0;
				case 40:
					key = 1;
				case 38:
					key = 2;
				case 39:
					key = 3;
			}
		}

		if (FlxG.save.data.botplay || key == -1 || keysHeld[key])
		{
			return;
		}

		keysHeld[key] = true;

		var dumbNotes:Array<Note> = []; // notes to kill later
		var closestNote:Note = null;
		var nearbyNote:Note = null;

		notes.forEachAlive((note:Note) ->
		{
			if (note.mustPress && !note.isSustainNote)
			{
				if (note.noteData == key)
				{
					if (closestNote != null)
					{
						if (closestNote.noteData == note.noteData && Math.abs(note.strumTime - closestNote.strumTime) < 10)
						{
							dumbNotes.push(note);
						}
						else if (closestNote.strumTime > note.strumTime)
						{
							closestNote = note;
						}
					}
					else if (Math.abs(note.strumTime - Conductor.songPosition) <= 166)
					{
						closestNote = note;
					}
				}
				else if (nearbyNote == null)
				{
					if (Math.abs(note.strumTime - Conductor.songPosition) < 150)
					{
						nearbyNote = note;
					}
				}
			}
		});

		for (note in dumbNotes)
		{
			FlxG.log.add("killing dumb ass note at " + note.strumTime);
			note.kill();
			note.exists = false;
		}

		if (closestNote != null)
		{
			playerStrums.members[closestNote.noteData].animation.play('confirm');

			goodNoteHit(closestNote);
		}
		else
		{
			if (nearbyNote != null)
			{
				mashPity += 2;

				if (mashPity >= 4)
				{
					// cant mash and delete hallow's notes
					if (nearbyNote.type == 0)
					{
						nearbyNote.kill();
						nearbyNote.exists = false;
						health -= 0.02; // more punishing
						noteMiss();
					}
				}
			}
		}
	}

	private function onKeyRelease(event:KeyboardEvent)
	{
		if (paused || inCutscene)
			return;

		@:privateAccess
		var key:Int = keybinds.indexOf(FlxKey.toStringMap.get(event.keyCode));

		if (key == -1)
		{
			switch (event.keyCode) // arrow keys
			{
				case 37:
					key = 0;
				case 40:
					key = 1;
				case 38:
					key = 2;
				case 39:
					key = 3;
			}
		}

		if (key == -1)
			return;

		keysHeld[key] = false;

		if (playerStrums.members[key].animation.curAnim.name != 'static')
		{
			playerStrums.members[key].animation.play('static');
		}
	}

	function onGameResize(width, height)
	{
		var textAntialiasing:Bool = width > 1280 ? true : false;
		currentTimingShown.antialiasing = textAntialiasing;
		scoreTxt.antialiasing = textAntialiasing;
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

		/*for (i in unspawnNotes)
			{
				if (strumTime > i.strumTime)
				{
					unspawnNotes.remove(i);
				}
		}*/

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
}
