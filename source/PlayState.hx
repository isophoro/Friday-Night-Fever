package;

import Section.SwagSection;
import Character.CostumeName;
import Character.Costume;
import flixel.util.FlxDirectionFlags;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import openfl.system.System;
#if cpp import cpp.vm.Gc; #end
import sprites.RoboBackground;
import flixel.effects.FlxFlicker;
import sprites.Crowd;
import openfl.display.BitmapData;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import sprites.CharacterTrail;
import Song.SwagSong;
import shaders.WiggleEffect;
import shaders.WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
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
import openfl.filters.BitmapFilter;
import shaders.Shaders;
import shaders.ModChart;
import GameJolt;
import GameJolt.GameJoltAPI;

using StringTools;

#if (sys && !mobile)
import Discord.DiscordClient;
import sys.FileSystem;
#end

class PlayState extends MusicBeatState 
{
	public static var instance:PlayState = null;
	public static var minus:Bool = false;
	
	public static var SONG:SwagSong;
	public static var curStage:String = '';
	private var curSong:String = "";
	public static var songOffset:Float = 0;	// Per song additive offset
	private var vocals:FlxSound;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	var inCutscene:Bool = false;

	private var executeModchart = false;
	public var beatClass:Class<Dynamic> = null;

	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var campaignScore:Int = 0;
	public static var skipDialogue:Bool = false;

	// Replay shit
	public static var rep:Replay;
	public static var loadRep:Bool = false;
	private var saveNotes:Array<Float> = [];
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var opponent:Bool = true; // decides if the player should play as fever or the opponent
	public static var curBoyfriend:Null<String>; // not to be confused with curPlayer, this overrides what character BF is
	public var curOpponent:Character; // these two variables are for the "swapping sides" portion
	public var curPlayer:Character; // just use the dad / boyfriend variables so stuff doesnt break

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;
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
	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	public var lanes:FlxTypedGroup<FlxSprite>;
	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	public var health:Float = 1; // making public because sethealth doesnt work without it
	private var combo:Int = 0;

	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;

	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;
	var songLength:Float = 0;

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
	var replayTxt:FlxText;
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

	// API stuff
	public function addObject(object:FlxBasic) 
	{
		add(object);
	}

	public function removeObject(object:FlxBasic) 
	{
		remove(object);
	}

	var scoreBop:FlxTween;
	var disableScoreBop:Bool = false;
	var wiggleEffect:WiggleEffect;
	var vignette:FlxSprite;

	var meat:Character;

	var shooting:FlxSprite;

	var alarm:FlxText;
	var roboFeverAttack:FlxSprite;

	public static var unlocked:FlxText;

	override public function create() 
	{
		trace(storyWeek);
		if (!isStoryMode || StoryMenuState.get_weekData()[storyWeek][0].toLowerCase() == SONG.song.toLowerCase())
		{
			Main.clearMemory();
		}



		#if cpp 
		Gc.run(true);
		#end

		super.create();
		add(new NoteSplash(0,0,0));

		for (i in ['sicks', 'bads', 'goods', 'shits', 'misses', 'repPresses', 'repReleases'])
			Reflect.setField(PlayState, i, 0);
		
		instance = this;
		opponent = FlxG.save.data.opponent;
		setModCamera(false);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));
		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));

		//partycrasher shit//
		modchart = new ModChart(this);
		//partycrasher shit//

		if (FlxG.save.data.fpsCap > 290)
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
			default:
				iconRPC = SONG.player2.split('-')[0]; // To avoid having duplicate images in Discord assets
		}
		detailsPausedText = "Paused - " + detailsText;	// String for when the game is paused

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = isStoryMode ? ("Story Mode: Week " + storyWeek) : "Freeplay";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ 	if(SONG.song == "Tranquility" || SONG.song == "Princess" || SONG.song == "Banish")
					"im not leaking"
				else
					SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
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

		currentTimingShown = new FlxText(0, 0, 0, "0ms");
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

		if(FlxG.save.data.subtitles)
		{
			var subtitleString:String = SONG.song.toLowerCase() + '/subtitles';

			if (CoolUtil.fileExists(Paths.json(subtitleString)))
			{
				subtitles = new Subtitles(FlxG.height * 0.68, haxe.Json.parse(CoolUtil.getFile(Paths.json(subtitleString))));
			}
		}

		switch (SONG.stage) {
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
					if(SONG.song.toLowerCase() == 'soul')
					{
						if (FlxG.save.data.shaders)
						{
							wiggleEffect = new WiggleEffect();
							wiggleEffect.effectType = WiggleEffectType.WAVY;
							wiggleEffect.waveAmplitude = 0.05;
							wiggleEffect.waveFrequency = 3;
							wiggleEffect.waveSpeed = 1;
							painting.shader = wiggleEffect.shader;
						}

						painting.visible = true;

						if(FlxG.save.data.shaders)
						{
							filters.push(ShadersHandler.chromaticAberration);
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
					if (curSong == 'Hallow' || curSong == 'Portrait') {
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
					var bg:FlxSprite = new FlxSprite(-820, -200).loadGraphic(Paths.image('christmas/lastsongyukichi', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					add(bg);
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

					if(SONG.song.toLowerCase() != 'space-demons'){
						bgGirls = new BackgroundGirls(-100, 190);
						bgGirls.scrollFactor.set(0.9, 0.9);
	
						if (SONG.song.toLowerCase() == 'chicken-sandwich') {
							if (FlxG.save.data.distractions) {
								bgGirls.getScared();
							}
						}
	
						bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
						bgGirls.updateHitbox();
						if (FlxG.save.data.distractions) {
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

				if(SONG.song.toLowerCase() == 'princess')
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
				w1city.animation.add('idle', [0,1,2], 0);
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

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(SONG.song == 'Down-Bad' ? 'stagecurtainsDOWNBAD' : 'stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(0.9, 0.9);
				add(stageCurtains);
			}
		}

		gf = new Character(400, 130, SONG.gfVersion == null ? 'gf' : SONG.gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		meat = new Character(260, 100.9, 'meat');

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2) {
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case "spooky":
				dad.y -= 30;
				//dad.y += 150;
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
				if (SONG.song.toLowerCase() == 'prayer' || SONG.song.toLowerCase() == 'bad-nun') {
					dad.y = 620;
					dad.x = 388;
				}

			case 'pepper':
				dad.y += 100;
				dad.x -= 100;
				dad.scrollFactor.set(0.9, 0.9);
			case 'dad':
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

		boyfriend = new Boyfriend(770, 450, curBoyfriend == null ? SONG.player1 : curBoyfriend);

		curPlayer = opponent ? dad : boyfriend;
		curOpponent = opponent ? boyfriend : dad;

		// REPOSITIONING PER STAGE
		switch (curStage) {
			case 'limo' | 'limonight':
				boyfriend.y -= 300;
				boyfriend.x += 260;
				gf.y += 20;
				gf.x -= 30;
				if (FlxG.save.data.distractions) {
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
			case 'week5' | 'week5othercrowd' | 'ripdiner':
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
				//if (dad.curCharacter == 'scarlet')
					//FlxTween.tween(dad, {y: dad.y - 25}, 0.76, {type: PINGPONG});
				boyfriend.scrollFactor.set(0.9, 0.9);
				gf.scrollFactor.set(0.9, 0.9);
		}

		if(SONG.song.toLowerCase() == 'bazinga' || SONG.song.toLowerCase() == 'crucify')
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

		// Shitty layering but whatev it works LOL
		if (limo != null)
			add(limo);

		if(curStage == 'schoolEvil')
		{
			add(meat);
			FlxTween.circularMotion(meat, 300, 200, 50, 0, true, 4, true, {type: LOOPING});
		}
		add(dad);
		add(boyfriend);
		//if(curStage == 'robocesbg')
		//{
			roboFeverAttack = new FlxSprite(dad.x - 100, dad.y);
			roboFeverAttack.frames = Paths.getSparrowAtlas('mechanicShit/roboShoot');
			roboFeverAttack.animation.addByPrefix('Attack', 'robo shoot', 24, false);
			roboFeverAttack.updateHitbox();
			roboFeverAttack.antialiasing = true;
			roboFeverAttack.alpha = 0;
			add(roboFeverAttack);
		//}


		boyfriend.setPosition(boyfriend.x + Costume.PlayerCostume.offsetPos.x, boyfriend.y + Costume.PlayerCostume.offsetPos.y);

		if (roboStage != null)
			add(roboForeground);

		if (curStage.startsWith('week5') || curStage == 'ripdiner')
		{
			bottomBoppers = new Crowd();
			add(bottomBoppers);
		}

		if (loadRep) 
		{
			FlxG.watch.addQuick('rep presses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);

			FlxG.save.data.botplay = true;
			FlxG.save.data.scrollSpeed = rep.replay.noteSpeed;
			FlxG.save.data.downscroll = rep.replay.isDownscroll;
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		lanes = new FlxTypedGroup<FlxSprite>();
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(lanes);
		add(strumLineNotes);

		if (playerStrums != null) {
			playerStrums.clear();
		}

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camPos.set(instance.gf.getGraphicMidpoint().x - 100, instance.gf.getGraphicMidpoint().y + 130);
		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = true;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, opponent ? LEFT_TO_RIGHT : RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromString('#FF' + curOpponent.iconColor), FlxColor.fromString('#FF' + curPlayer.iconColor));
		healthBar.antialiasing = true;
		// healthBar
		add(healthBar);

		healthBar.scale.x = 1.04;
		healthBarBG.scale.x = 1.04;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), #if !mobile 18 #else 24 #end, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		scoreTxt.borderSize = 1.25;
		FlxG.signals.gameResized.add(onGameResize);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}

		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();

		shooting = new FlxSprite(50, 50);
		shooting.frames = Paths.getSparrowAtlas('mechanicShit/shoot');
		shooting.animation.addByPrefix('0', 'shoot icon', 24);
		shooting.animation.addByPrefix('5', 'shoot five', 24);
		shooting.animation.addByPrefix('4', 'shoot four', 24);
		shooting.animation.addByPrefix('3', 'shoot three', 24);
		shooting.animation.addByPrefix('2', 'shoot two', 24);
		shooting.animation.addByPrefix('1', 'shoot one', 24);
		shooting.animation.play('0');
		shooting.scrollFactor.set();
		if(boyfriend.curCharacter == 'bf')
		{
			add(shooting);
		}

		alarm = new FlxText(0, 0, 0, "", 20);
		alarm.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		alarm.scrollFactor.set();
		add(alarm);
		alarm.screenCenter();
		alarm.cameras = [camHUD];
		


		if (FlxG.save.data.botplay && !loadRep)
			add(botPlayState);

		iconP1 = new HealthIcon(curBoyfriend == null ? SONG.player1 : curBoyfriend, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		add(scoreTxt);

		unlocked = new FlxText(640, healthBarBG.y + 100, 0, "", 20);
		unlocked.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		unlocked.scrollFactor.set();
		add(unlocked);
		unlocked.alpha = 0;
		unlocked.cameras = [camHUD];
		

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
			blackScreen.scale.set(5,5);
			add(blackScreen);

			if (curSong.toLowerCase() == 'tranquility')
			{
				new FlxTimer().start(1.35, (t) -> {
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
		shooting.cameras = [camHUD];

		if(subtitles != null)
		{
			subtitles.cameras = [camHUD];
			add(subtitles);
		}

		switch(SONG.song.toLowerCase())
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
		if (loadRep)
			replayTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		startingSong = true;

		if (isStoryMode && dialogue.length > 0 && !skipDialogue) 
		{
			switch (curSong.toLowerCase()) 
			{
				case 'bazinga':
					camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
					jumpscare(doof);
				default:
					if (curSong.toLowerCase() == 'chicken-sandwich')
						FlxG.sound.play(Paths.sound('ANGRY'));

					camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
					openDialogue(doof);
			}
		}
		else 
		{
			startCountdown();
		}

		if (!loadRep)
			rep = new Replay("na");

		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		onGameResize(FlxG.stage.window.width, FlxG.stage.window.height);
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
		new FlxTimer().start(1.4, function(tmr:FlxTimer) {
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

	function startCountdown():Void 
	{
		skipDialogue = true;
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		#if windows
		if (executeModchart) {
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [PlayState.SONG.song]);
		}
		#end

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
			dad.dance();
			if(curStage == 'schoolEvil')
			{
				meat.dance();
			}
			gf.dance();
			boyfriend.dance();

			var introAssets:Map<String, Array<String>> = [
				'default' => ['ready', "set", "go", "shared", ""],
				'school' => ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel','week6', "-pixel"],
				'schoolEvil' => ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel','week6', "-pixel"],
			];

			var introAlts:Array<String> = introAssets.get('default');
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

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0], introAlts[3]));
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					ready.cameras = [camHUD];
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1], introAlts[3]));
					set.updateHitbox();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					set.cameras = [camHUD];
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2], introAlts[3]));
					go.updateHitbox();
					go.cameras = [camHUD];

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);

					#if cpp 
					Gc.run(true); 
					#end
				case 4:
			}

			swagCounter++;
		}, 5);
	}

	var canPressSpace:Bool = false;
	var pressedSpace = false;

	function roboShoot()
	{
			pressedSpace = false;
			canPressSpace = true;
			
			alarm.alpha = 1;
			alarm.text = 'dodge!!!';
	
			roboFeverAttack.alpha = 1;
			dad.alpha = 0;
			roboFeverAttack.animation.play('Attack', true);
			roboFeverAttack.animation.finishCallback = function(name:String)
			{
					roboFeverAttack.alpha = 0;
					dad.alpha = 1;
					dad.dance();
			};
	
	
			new FlxTimer().start(0.55, function(tmr:FlxTimer)
			{
				alarm.alpha = 0;
	
				if(pressedSpace)
				{
					boyfriend.playAnim('dodge', true);
					health += 0.2;
	
				}
				else
				{
					health -= 1;
					FlxG.camera.shake(0.005);
					boyfriend.playAnim('singUPmiss', true);
				}
			});
		
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

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void 
	{
		startingSong = false;
		previousFrameTime = FlxG.game.ticks;

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

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			songPosBG.y = FlxG.height * 0.9 + 45;
		songPosBG.screenCenter(X);

		songName = new FlxText(0, songPosBG.y, 0, '', 16);
		songName.text = '"' + CoolUtil.capitalizeFirstLetters(StringTools.replace(SONG.song, '-', ' ')) + '" by ${Song.getArtist(curSong)}';
		if (FlxG.save.data.downscroll)
			songName.y -= 4;
		
		songName.antialiasing = FlxG.width > 1280 ? true : false;
		songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.screenCenter(X);

		if (FlxG.save.data.songPosition) 
		{
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
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
			FlxTween.tween(songName, {alpha:1}, 0.7, {onComplete: (twn) -> {
				new FlxTimer().start(5.8, (t) -> {
					FlxTween.tween(songName, {alpha:0}, 0.7);
				});
			}});
		}

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ 	if(curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish")
					"im not leaking"
				else
					SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void {
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song), false);
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);
		add(currentTimingShown);
		currentTimingShown.alpha = 0;

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';
		for (file in sys.FileSystem.readDirectory(songPath)) {
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path)) {
				if (path.endsWith('.offset')) {
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				} else {
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end

		for (section in noteData) {

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var noteType:Int = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3) {
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, null, noteType);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength)) {
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = opponent ? !gottaHitNote : gottaHitNote;

					if (sustainNote.mustPress) {
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = opponent ? !gottaHitNote : gottaHitNote;

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				} else {}
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void 
	{
		var square:FlxSprite = new FlxSprite();
		for (i in 0...4) 
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(-10, strumLine.y);

			switch (SONG.noteStyle) {
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i)) {
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				case 'normal':
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i)) {
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i)) {
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player) 
			{ 
				case 0:
					babyArrow.x -= 10;
					if (opponent)
						playerStrums.add(babyArrow);
					else
						cpuStrums.add(babyArrow);
				case 1:
					if (opponent)
						cpuStrums.add(babyArrow);
					else
						playerStrums.add(babyArrow);
			}

			babyArrow.animation.finishCallback = (anim) ->
			{
				if (anim == 'confirm')
				{
					babyArrow.animation.play('static');
					babyArrow.centerOffsets();
				}
			}

			babyArrow.animation.play('static');
			babyArrow.x += 110;
			babyArrow.x += ((FlxG.width / 2) * player);

			cpuStrums.forEach(function(spr:FlxSprite) {
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}

		if (player == 0)
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
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ 	if(curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish")
						"im not leaking"
					else
						SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() 
	{
		if (paused) 
		{
			if (FlxG.sound.music != null && !startingSong) {
				resyncVocals();
			}

			@:privateAccess
			for (i in FlxTween.globalManager._tweens)
			{
				i.active = true;
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished) {
				DiscordClient.changePresence(detailsText
					+ " "
					+ 	if(curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish")
							"im not leaking"
						else
							SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ FlxMath.roundDecimal(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			} else {
				DiscordClient.changePresence(detailsText, 
				if(curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish")
					"im not leaking"
				else
					SONG.song 
				+ " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
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
			+ 	if(curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish")
					"im not leaking"
				else
					SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
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

	var shootCoolDown:Float = 0;

	var isSooting:Bool = false;


	override public function update(elapsed:Float) 
	{


		if(shootCoolDown > 0)
		{
			trace(shootCoolDown);
			shootCoolDown -= elapsed;
			shooting.animation.play('${Math.ceil(shootCoolDown)}');
		}
		else
		{
			shooting.animation.play('0');

		}

		if(FlxG.keys.justPressed.U)
		{
			Achievements.getAchievement(11);
		}


		//trace(shootCoolDown);

		if(boyfriend.curCharacter == 'bf' && FlxG.keys.justPressed.SHIFT && shootCoolDown == 0 || boyfriend.curCharacter == 'bf' && FlxG.keys.justPressed.SHIFT && shootCoolDown < 0)
		{
			shootCoolDown = 5;
			boyfriend.playAnim('shoot', true);
			boyfriend.animation.finishCallback = function(name:String)
			{
				boyfriend.dance();
			};

			new FlxTimer().start(0.55, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('gunShoot'), 0.9);

				roboFeverAttack.x = dad.x - 100;
				roboFeverAttack.y = dad.y;

				FlxTween.tween(dad, {x: dad.x - 50}, 1, {ease: FlxEase.circOut, type: PINGPONG, onComplete: (twn) -> {
					dad.dance();
					FlxTween.cancelTweensOf(dad);
				}});

				

				

				health += 0.2;
				FlxG.camera.shake(0.005);
			});
		}


		if(canPressSpace && FlxG.keys.justPressed.SPACE)
		{
			pressedSpace = true;
			canPressSpace = false;
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

		if(easierMode == true)
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

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

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

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.curCharacter == 'bf-old')
				iconP1.swapCharacter(SONG.player1);
			else
				iconP1.swapCharacter('bf-old');
		}

		if (!inCutscene && !pressedSpace && FlxG.keys.justPressed.SPACE && boyfriend.animation.curAnim.name != 'hey') 
		{
			boyfriend.playAnim('hey');
			gf.playAnim('cheer');
		}

		/*
			if (gf.animation.curAnim.name.startsWith('dance'))
				gf.animation.curAnim.frameRate = 24 / (Conductor.crochet / 1000);
		*/

		if(FlxG.save.data.shaders)
		{
			if (wiggleEffect != null)
			{
				wiggleEffect.update(elapsed);
			}

			if(tvshit!=null)
			{
				tvshit.update(elapsed);
			}
		}

		super.update(elapsed);

		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.text = "Score: " + songScore;
		else
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, accuracy);

		scoreTxt.screenCenter(X);

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
			if (luaModchart != null) {
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		var iconOffset:Int = 26;

		switch (healthBar.fillDirection)
		{
			default:				
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
			case LEFT_TO_RIGHT:
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}

		if (health > 2)
			health = 2;
		
		if (health < 0 && opponent)
			health = 0;

		if(health >= 1.75 && hurtTimer <= 0)
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
		else if (FlxG.keys.justPressed.SIX)
		{
			FlxG.switchState(new AnimationDebug(gf.curCharacter));
			#if windows
			if (luaModchart != null) 
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end			
		}
		else if (FlxG.keys.justPressed.FIVE)
		{
			FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
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

			if (!paused) 
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) 
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}

			#if windows
			if (luaModchart != null && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end
		}

		if(PlayState.SONG.notes[Std.int(curStep / 16)] != null && !disableCamera)
		{
			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) 
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null) {
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end

				switch (dad.curCharacter) {
					case 'mom' | 'mom-carnight' | 'mom-car':
						camFollow.y = dad.getMidpoint().y + 90;
					case 'senpai' | 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'dad' | 'peasus':
						camFollow.x = dad.getMidpoint().x - -400;
					case 'spooky' | 'feralspooky':
						camFollow.x = dad.getMidpoint().x + 190;
						camFollow.y = dad.getMidpoint().y - 30;
					case 'taki':
						camFollow.x = dad.getMidpoint().x + 155;
						camFollow.y = minus ? dad.getMidpoint().y + 150 : dad.getMidpoint().y - 50;
					case 'monster':
						if (SONG.song.toLowerCase() == 'prayer') {
							camFollow.x = dad.getMidpoint().x - -560;
							camFollow.y = dad.getMidpoint().y - -100;
						} else {
							camFollow.x = dad.getMidpoint().x - -400;
							camFollow.y = dad.getMidpoint().y - -100;
						}
					case 'pepper':
						camFollow.y = dad.getMidpoint().y - 50;
						camFollow.x = dad.getMidpoint().x + 250;
					case 'spookyHALLOW':
						camFollow.x = dad.getMidpoint().x - -400;
					case 'hallow':
						camFollow.x = dad.getMidpoint().x - -500;
						camFollow.y = dad.getMidpoint().y - -100;
					case 'robo-cesar':
						if (roboStage != null)
						{
							switch(roboStage.curStage)
							{
								default:
									camFollow.y = dad.getMidpoint().y - 130;
									camFollow.x = dad.getMidpoint().x + 475;
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
							camFollow.y = dad.getMidpoint().y - 340;
							camFollow.x = dad.getMidpoint().x - -600;
						}
					case 'calamity':
						camFollow.x = dad.getMidpoint().x - -500;
						camFollow.y = dad.getMidpoint().y - -100;
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
						camFollow.y = dad.getMidpoint().y - 200;
					case 'gf':
						camFollow.y = dad.getMidpoint().y - 50;
					case 'flippy':
						camFollow.x = dad.getMidpoint().x - 360;
						camFollow.y = dad.getMidpoint().y - 440;
				}

				//defaultCamZoom = 1.55;
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100) 
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null) {
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
	
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
	
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
						camFollow.x = boyfriend.getMidpoint().x - 530;
						camFollow.y = boyfriend.getMidpoint().y - 260;
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
							default:
								camFollow.x = boyfriend.getMidpoint().x - 490;
								camFollow.y = boyfriend.getMidpoint().y - 280;
						}
				}

				camFollow.x += Costume.PlayerCostume.camOffsetPos.x;
				camFollow.y += Costume.PlayerCostume.camOffsetPos.y;
			}

			camFollow.x += fevercamX;
			//camFollow.y += fevercamY;
		}

		if (camZooming) 
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
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
				+ 	if(curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish")
						"im not leaking"
					else
						SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}

		if (FlxG.save.data.resetButton && FlxG.keys.justPressed.R) 
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
				+ 	if(curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish")
						"im not leaking"
					else
						SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null) 
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500) 
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic) 
		{
			notes.forEachAlive(function(daNote:Note) 
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)

				if (daNote.type == 1 && !daNote.animPlayed && Conductor.songPosition >= daNote.strumTime - 750 && 
					(opponent ? !daNote.mustPress : daNote.mustPress))
				{
					summonPainting();
					daNote.animPlayed = true;
				}

				daNote.active = !daNote.tooLate;
				daNote.visible = !daNote.tooLate;

				if (!daNote.modifiedByLua)
				{
					if (FlxG.save.data.downscroll) {
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
									2));
						else
							daNote.y = (cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
									2));
						if (daNote.isSustainNote) {
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!FlxG.save.data.botplay) 
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2)) {
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							} 
							else 
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					} else {
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
									2));
						else
							daNote.y = (cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
									2));
						if (daNote.isSustainNote) {
							daNote.y -= daNote.height / 2;

							if (!FlxG.save.data.botplay) {
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2)) {
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							} else {
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit) {
					if (SONG.song != 'Milk-Tea' && !disableCamera && !disableModCamera)
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null) 
					{
						if (!opponent && SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					var delay:Int = 0;
					curOpponent.holdTimer = 0;
					// Accessing the animation name directly to play it
					if (curSong == 'Princess' && (curBeat == 303 || curBeat == 367) && daNote.noteData == 2)
					{
						curOpponent.playAnim('singLaugh', true);
					}
					else
					{
						curOpponent.playAnim('sing' + dataSuffix[daNote.noteData] + altAnim, true);
						if(curStage == 'schoolEvil')
						{
							meat.playAnim('sing' + dataSuffix[daNote.noteData] + altAnim, true);
						}
					}

					if (!opponent)
					{
						if (storyDifficulty != 0)
						{
							switch (dad.curCharacter) {
								case 'robo-cesar':
									if (curSong == 'Loaded')
										if (curBeat >= 400 && curBeat < 432)
											health -= 0.01;
								case 'gf':
									health -= 0.02;
								case 'mom-car':
									health -= 0.01;
								case 'mom-carnight':
									health -= 0.02;
								case 'flippy':
									switch (storyDifficulty) {
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
											if (curStep >= 1359 && curStep < 1422)
												health -= 0.025;
											else if (curStep < 1681)
												health -= health > 0.2 ? 0.02 : 0.0065;
										default:
											health -= SONG.song == 'Crucify' ? 0.01 : 0.02;
									}
									if (!minus)
										gf.playAnim('scared');
								case 'hallow':
									if (healthBar.percent > 5) {
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
					notes.remove(daNote, true);
				}

				if (daNote.mustPress && !daNote.modifiedByLua) {
					daNote.visible = !opponent ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible : true;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				} else if (!daNote.wasGoodHit && !daNote.modifiedByLua) {
					daNote.visible = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}

				if (daNote.isSustainNote)
					daNote.x += daNote.width / 2 + 17;

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((daNote.mustPress && daNote.tooLate && !FlxG.save.data.downscroll || daNote.mustPress && daNote.tooLate && FlxG.save.data.downscroll)
					&& daNote.mustPress) {
					if (daNote.isSustainNote && daNote.wasGoodHit) {
						daNote.kill();
						notes.remove(daNote, true);
					}
					if (daNote.type == 0) 
					{
						health -= 0.075;
						vocals.volume = 0;
							noteMiss(daNote.noteData, daNote);
					} 
					else if (daNote.type == 1 && !opponent) 
					{
						health = -1;
		
						diedtoHallowNote = true;


						vocals.volume = 0;
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		cpuStrums.forEach(function(spr:FlxSprite) {
			if (spr.animation.finished) {
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene)
			keyShit();

		#if debug
		if(FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}
 
	function endSong():Void 
	{
		skipDialogue = false;

		if (!loadRep)
			rep.SaveReplay(saveNotes);
		else {
			FlxG.save.data.botplay = false;
			FlxG.save.data.scrollSpeed = 1;
			FlxG.save.data.downscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if windows
		if (luaModchart != null) {
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore) 
		{
			if (misses == 0 && !FlxG.save.data.fcs.contains(SONG.song))
				FlxG.save.data.fcs.push(SONG.song);

			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
		}

		trace('Line 2618');
		if (isStoryMode) {
			campaignScore += Math.round(songScore);

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) 
			{
				Main.playFreakyMenu();

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				#if windows
				if (luaModchart != null) {
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

				if(SONG.song.toLowerCase() == 'milk-tea' && storyDifficulty == 0)
				{
					Achievements.getAchievement(2);
				}

				if (storyWeek == 5)
					Costume.unlockCostume(Fever_Casual);

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
			} else {
				var difficulty:String = "";

				if (storyDifficulty == 0 || storyDifficulty == 1)
					difficulty = '-easy';

				if (storyDifficulty == 3 || storyDifficulty == 4)
					difficulty = '-hard';
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

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

	var hits:Array<Float> = [];

	private function popUpScore(daNote:Note):Void 
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
		var assetLib:String = usePixelAssets ? 'week6' : 'shared';

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;
		var daRating = daNote.rating;

		vocals.volume = 1;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		switch (daRating) 
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.2;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.25;
			case 'bad':
				score = 0;
				health -= 0.06;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				score = 200;
				goods++;
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;

				if (FlxG.save.data.notesplash)
				{
					var splash:NoteSplash = new NoteSplash(playerStrums.members[daNote.noteData].x, playerStrums.members[daNote.noteData].y, daNote.noteData);
					splash.cameras = [camHUD];
					add(splash);
				}
		}

		if (daRating != 'shit' || daRating != 'bad') 
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			var pixelShitPart1:String = usePixelAssets ? 'weeb/pixelUI/' : '';
			var pixelShitPart2:String = usePixelAssets ? '-pixel' : '';

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2, assetLib));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = (FlxG.width * 0.55) - 125;

			if (!disableHUD)
			{
				if (FlxG.save.data.changedHit) {
					rating.x = FlxG.save.data.changedHitX;
					rating.y = FlxG.save.data.changedHitY;
				}
			}
			else
			{
				rating.x = cpuStrums.members[cpuStrums.length - 1].x + cpuStrums.members[cpuStrums.length - 1].width;
				rating.y = cpuStrums.members[cpuStrums.length - 1].y;
				rating.alpha = 0.6;
			}

			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = FlxMath.roundDecimal(noteDiff, 2);
			if (FlxG.save.data.botplay)
				msTiming = 0;

			currentTimingShown.text = msTiming + 'ms';

			switch (daRating) 
			{
				case 'shit' | 'bad': currentTimingShown.color = 0xFFC4012D;
				case 'good': currentTimingShown.color = 0xFFE398DD;
				case 'sick': currentTimingShown.color = 0xFF7A55BB;
			}

			FlxTween.cancelTweensOf(currentTimingShown);
			currentTimingShown.alpha = 1;

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2, assetLib));
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.x = comboSpr.x + 140;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y = -150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!FlxG.save.data.botplay)
				add(rating);

			if (usePixelAssets)
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var comboSplit:Array<String> = (combo + "").split('');
			var seperatedScore:Array<Int> = [for (i in comboSplit) Std.parseInt(i)];

			if (comboSplit.length == 2)
				seperatedScore.insert(0, 0);

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, assetLib));
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
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

				if (combo >= 10 || combo == 0)
				{
					add(numScore);

					if (curSong.toLowerCase() == 'tranquility')
						numScore.shader = wiggleEffect.shader;
				}

				FlxTween.tween(numScore, {alpha: 0}, 0.5, {
					onComplete: function(tween:FlxTween) {
						numScore.kill();
					},
					startDelay: 0.3
				});

				daLoop++;
			}

			FlxTween.tween(rating, {alpha: 0}, 0.45, {startDelay: 0.27});
			FlxTween.tween(currentTimingShown, {alpha:0}, 0.45, {startDelay: 0.27});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.45, {
				onComplete: function(tween:FlxTween) {
					comboSpr.kill();
					rating.kill();
				},
				startDelay: 0.27
			});
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool {
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		#if windows
		if (luaModchart != null) 
		{
			if (controls.LEFT_P) {
				luaModchart.executeState('keyPressed', ["left"]);
			};
			if (controls.DOWN_P) {
				luaModchart.executeState('keyPressed', ["down"]);
			};
			if (controls.UP_P) {
				luaModchart.executeState('keyPressed', ["up"]);
			};
			if (controls.RIGHT_P) {
				luaModchart.executeState('keyPressed', ["right"]);
			};
		};
		#end

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

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		notes.forEachAlive(function(daNote:Note) {
			if (FlxG.save.data.downscroll && daNote.y > strumLine.y || !FlxG.save.data.downscroll && daNote.y < strumLine.y) {
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (FlxG.save.data.botplay && daNote.canBeHit && daNote.mustPress || FlxG.save.data.botplay && daNote.tooLate && daNote.mustPress) {
					if (loadRep) {
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						if (rep.replay.songNotes.contains(FlxMath.roundDecimal(daNote.strumTime, 2))) {
							goodNoteHit(daNote);
							curPlayer.holdTimer = daNote.sustainLength;
						}
					} else {
						goodNoteHit(daNote);
						curPlayer.holdTimer = daNote.sustainLength;
					}
				}
			}
		});
		
		if (curPlayer.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botplay)) 
		{
			if (curPlayer.animation.curAnim.name.startsWith('sing') && !curPlayer.animation.curAnim.name.endsWith('miss'))
			{
				curPlayer.dance();
				fevercamX = 0;
				fevercamY = 0;
			}
		}

		strumLineNotes.forEach((spr) -> {
			spr.centerOffsets();
			spr.centerOrigin();
		});
	}

	function noteMiss(direction:Int = 1, ?daNote:Note):Void 
	{
		if (!opponent && combo >= 10)
			gf.playAnim('sad');

		health -= 0.04;
		songScore -= 10;
		combo = 0;
		misses++;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit -= 1;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		if(boyfriend.animation.curAnim.name != 'shoot')
		{
			curPlayer.playAnim('sing' + dataSuffix[direction] + 'miss', true);

		}
	
		#if windows
		if (luaModchart != null)
			luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
		#end

		updateAccuracy();
	}

	function updateAccuracy() {
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	var etternaModeScore:Int = 0;

	function goodNoteHit(note:Note):Void 
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);

		if (!note.wasGoodHit) {
			if (!note.isSustainNote) 
			{
				popUpScore(note);
				combo += 1;
			} 
			else
				totalNotesHit += 1;

			if(boyfriend.animation.curAnim.name != 'shoot')
				{
					curPlayer.playAnim('sing' + dataSuffix[note.noteData], true);
		
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

			if (!loadRep && note.mustPress)
				saveNotes.push(FlxMath.roundDecimal(note.strumTime, 2));

			playerStrums.forEach(function(spr:FlxSprite) {
				if (Math.abs(note.noteData) == spr.ID) {
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			switch (note.type)
			{
				case 1:
					boyfriend.playAnim('dodge', true);
					health += 0.02;
			}

			note.kill();
			notes.remove(note, true);
			//note.destroy();

			updateAccuracy();

			if (!note.isSustainNote)
			{
				if (disableScoreBop)
					return;

				if (scoreBop != null)
					scoreBop.cancel();
	
				scoreTxt.scale.set(scoreTxt.scale.x < 0.9 ? 0.875 : 1.075, scoreTxt.scale.y < 0.9 ? 0.875 : 1.075);
				scoreBop = FlxTween.tween(scoreTxt.scale, {x: scoreTxt.scale.x < 0.9 ? 0.8 : 1, y: scoreTxt.scale.y < 0.9 ? 0.8 : 1}, 0.24, {
					onComplete: (twn) ->
					{
						scoreBop = null;
					}
				});
			}
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
			new FlxTimer().start(2, function(tmr:FlxTimer) {
				resetFastCar();
			});
		}
	}

	override function stepHit() 
	{
		super.stepHit();

		if(subtitles != null)
		{
			subtitles.stepHit(curStep);
		}

		if(curSong == 'Bazinga')
		{
			switch(curStep)
			{
				case 121: health += 0.32;
				case 1476 | 1508:
					if (!minus)
						characterTrail.visible = false;
					defaultCamZoom = 0.95;
				case 1500 | 1522:
					if (curStep == 1522 && !minus)
						characterTrail.visible = true;
					defaultCamZoom = 0.6;
				case 1524: health += 0.40;
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

		if(SONG.song.toLowerCase() == 'princess')
		{
			switch(curStep)
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
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ 	if(curSong == "Tranquility" || curSong == "Princess" || curSong == "Banish")
					"im not leaking"
				else
					SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	override function beatHit() 
	{
		super.beatHit();
		// reset cam lerp
		FlxG.camera.followLerp = 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS());

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
				case 'c354r': 
					switch(curBeat)
					{
						case 47: 
							roboShoot();
						case 55:
							roboShoot();
						case 78:
							roboShoot();
						case 103:
							roboShoot();
						case 143: 
							roboShoot();
						case 175: 
							roboShoot();
						case 271: 
							roboShoot();
						case 280:
							roboShoot();
						case 304:
							roboShoot();
						case 319:
							roboShoot();
						case 364:
							roboShoot();
						case 383:
							roboShoot();
					}
				case 'soul' | 'portrait':
					switch(curBeat)
					{
						case 32:
							camHUD.flash(FlxColor.WHITE, 0.5);
		
							if(curSong == 'Portrait')
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
							FlxTween.tween(blackScreen, {alpha: 1}, 0.58, {onComplete: (twn) -> {
								FlxTween.tween(wiggleEffect, {waveAmplitude: 0}, 0.6);
								FlxTween.cancelTweensOf(purpleOverlay);
								FlxTween.tween(purpleOverlay, {alpha: 0}, 0.1);
								try {
									@:privateAccess FlxTimer.globalManager._timers[0].cancel();
								} catch (e) {}
								disableHUD = true;
								for (i in strumLineNotes)
									FlxTween.tween(i, {alpha: 0.6}, 0.6);
								for (i in [iconP1, iconP2, healthBar, healthBarBG])
									FlxTween.tween(i, {alpha: 0}, 0.46, {onComplete: (twn) -> {
										if (i == healthBarBG)
										{
											FlxTween.tween(scoreTxt, {y: FlxG.save.data.downscroll ? scoreTxt.y - 80 : scoreTxt.y + 80}, 0.38);
											disableScoreBop = true;
											FlxTween.tween(scoreTxt.scale, {x: 0.8, y: 0.8}, 0.38, {onComplete: (twn) -> {
												disableScoreBop = false;
											}});
										}
									}});
							}});
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
							try {
								@:privateAccess FlxTimer.globalManager._timers[0].cancel();
							} catch (e) {}
							FlxTween.tween(purpleOverlay, {alpha: 0}, 2.6);
							FlxTween.tween(wiggleEffect, {waveAmplitude: 0}, 2.6);
					}
				case 'party-crasher':
					switch(curBeat)
					{
						case 95 | 159:
							FlxG.camera.shake(0.09, Conductor.crochet / 1000);
							camHUD.shake(0.09, Conductor.crochet / 1000);
						case 96:
		
							if (FlxG.save.data.shaders)
							{
								camfilters.push(ShadersHandler.scanline);
								camHUD.filtersEnabled = true;
		
								modchart.addCamEffect(tvshit);
							}
				
							scoreTxt.setFormat(Paths.font("Retro Gaming.ttf"), #if !mobile 18 #else 24 #end, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							font = true;
						case 160:
							if (FlxG.save.data.shaders)
							{
		
								camfilters.remove(ShadersHandler.scanline);
								camHUD.filtersEnabled = false;
								modchart.removeCamEffect(tvshit);
							}
				
							font = false;
							scoreTxt.setFormat(Paths.font("vcr.ttf"), #if !mobile 18 #else 24 #end, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				case 'star-baby':
					switch(curBeat)
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
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

			if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].changeBPM) 
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		#if windows
		if (executeModchart && luaModchart != null) {
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (!curOpponent.animation.curAnim.name.startsWith('sing'))
			curOpponent.dance();

		var iconBop:Float = curBeat % 4 == 0 ? 1.2 : 1.135;

		if (!usePixelAssets)
		{
			iconP1.origin.set(iconP1.width / 2,0);
			iconP2.origin.set(iconP2.width / 2,0);
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
			// disgusting code
			if (gf.animation.curAnim.name != 'scared' && gf.animation.curAnim.name != 'sad' || 
				gf.animation.curAnim.name == 'sad' && gf.animation.finished || 
				gf.animation.curAnim.name == 'scared' && dad.holdTimer < -0.35)
				gf.dance();
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
			case 'school':
				if(SONG.song.toLowerCase() != 'space-demons')
				{
					bgGirls.dance();
				}
			case 'week5' | 'week5othercrowd' | 'ripdiner':
				bottomBoppers.beatHit();
			case 'limo' | 'limonight':
				if (FlxG.save.data.distractions) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer) {
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
		mechanic.animation.finishCallback = function(anim){
			remove(mechanic);
		}
	}

	override function add(object:FlxBasic):FlxBasic
	{
		if (!FlxG.save.data.antialiasing && Reflect.field(object, "antialiasing") != null)
		{
			Reflect.setField(object, "antialiasing", false);
		}

		return super.add(object);
	}

	// RF INPUT SHIT
	var keybinds(get, never):Array<String>;
	var keysHeld:Array<Bool> = [false, false, false, false]; 
	var mashPity:Float = 0;

	function get_keybinds():Array<String>
	{
		return [FlxG.save.data.leftBind, FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
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
				case 37: key = 0;
				case 40: key = 1;
				case 38: key = 2;
				case 39: key = 3;
			}
		}

		if (FlxG.save.data.botplay || key == -1 || keysHeld[key])
		{
			return;
		}

		curPlayer.holdTimer = 0;
		keysHeld[key] = true;

		var dumbNotes:Array<Note> = []; // notes to kill later
		var closestNote:Note = null;
		var noteNearby:Bool = false;

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
				else if (!noteNearby)
				{
					if (Math.abs(note.strumTime - Conductor.songPosition) < 150)
					{
						noteNearby = true;
					}
				}
			}
		});

		for (note in dumbNotes)
		{
			FlxG.log.add("killing dumb ass note at " + note.strumTime);
			note.kill();
			notes.remove(note, true);
		}

		if (closestNote != null)
		{
			playerStrums.members[closestNote.noteData].animation.play('confirm');

			goodNoteHit(closestNote);
		}
		else
		{
			if (noteNearby)
			{
				mashPity += 2;

				if (mashPity >= 4)
					noteMiss();
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
				case 37: key = 0;
				case 40: key = 1;
				case 38: key = 2;
				case 39: key = 3;
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

		if (songName != null)
			songName.antialiasing = textAntialiasing;
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

		for (i in unspawnNotes)
		{
			if (strumTime > i.strumTime)
			{
				toKill.push(i);
			}				
		}

		for (i in toKill)
		{
			i.kill();
			if (notes.members.contains(i))
				notes.remove(i, true);
			else
				unspawnNotes.remove(i);
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