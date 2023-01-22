package;

import Note.QueuedNote;
import Song.SwagSong;
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
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.system.System;
import scripting.*;
import shaders.*;
import sprites.*;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

using StringTools;

#if (flixel < "5.0.0")
import flixel.math.FlxPoint;
#else
import flixel.math.FlxPoint.FlxBasePoint as FlxPoint;
#end
#if (sys && !mobile)
import Discord.DiscordClient;
import sys.FileSystem;
#end

class PlayState extends MusicBeatState
{
	public static var SONG:SwagSong;
	public static var instance:PlayState = null;

	public var canHey:Bool = true;

	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var campaignScore:Int = 0;

	public static var curStage:String = '';
	public static var endingSong:Bool;

	private var curSong:String = "";
	private var vocals:FlxSound;
	private var startingSong:Bool = false;
	var inCutscene:Bool = false;

	public var gfSpeed:Int = 1;

	private var executeModchart = false;

	public var beatClass:Class<Dynamic> = null;

	public static var skipDialogue:Bool = false;

	var curBoyfriend:String = SONG.player1; // not to be confused with curPlayer, this overrides what character BF is

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
	public var disableHUD:Bool = false;
	public var disableModCamera:Bool = false; // disables the modchart from messing around with the camera
	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var filters:Array<BitmapFilter> = [];

	public var useDirectionalCamera:Bool = false;
	public var directionalCameraDist:Int = 15;

	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; // we do a little backporting

	public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();

	private var unspawnNotes:Array<QueuedNote> = [];

	public var strumLine:FlxSprite;
	public var lanes:FlxTypedGroup<FlxSprite>;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	public var health:Float = 1;
	public var songScore:Float = 0;
	public var displayedScore:Int = 0;
	public var combo:Int = 0;

	private var accuracy:Float = 0;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	public static var goods:Int = 0;
	public static var bads:Int = 0;
	public static var shits:Int = 0;
	public static var misses:Int = 0;
	public static var deaths:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// stage sprites
	public var purpleOverlay:FlxSprite;
	public var church:FlxSprite; // week 2.5 / bad nun

	var spookyBG:FlxSprite; // week 2
	var dark:FlxSprite;
	var moreDark:FlxSprite;
	var takiBGSprites:Array<FlxSprite> = [];
	var bgGirls:BackgroundGirls; // week 6

	public var roboStage:RoboBackground;
	public var roboBackground:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public var roboForeground:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	// HEALTH BAR
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var scoreTxt:FlxText;
	public var scoreBop:FlxTween;
	public var disableScoreBop:Bool = false;
	public var subtitles:Subtitles;

	var botPlayState:FlxText; // BotPlay text
	var currentTimingShown:TimingText;
	var songName:FlxText;

	public static function setModCamera(bool:Bool)
	{
		if (FlxG.save.data.disableModCamera)
			instance.disableModCamera = true;
		else
			instance.disableModCamera = bool;
	}

	public static var daPixelZoom:Float = 6;

	public var ratingsGrp:FlxTypedGroup<ComboRating> = new FlxTypedGroup<ComboRating>(ComboRating.MAX_RENDERED);
	public var numbersGrp:FlxTypedGroup<ComboNumber> = new FlxTypedGroup<ComboNumber>(ComboNumber.MAX_RENDERED);

	public var usePixelAssets(default, set):Bool = false;

	function set_usePixelAssets(set:Bool)
	{
		usePixelAssets = set;
		ratingsGrp.forEach(function(obj)
		{
			obj.loadFrames();
		});
		numbersGrp.forEach(function(obj)
		{
			obj.loadFrames();
		});
		return set;
	}

	var wiggleEffect:WiggleEffect;
	var vignette:FlxSprite;

	var meat:Character;

	var scripts:HScriptGroup = new HScriptGroup();
	var songScript:HaxeScript;
	var curSection:Int = 0;

	var snowOn:Bool = false;
	var snowShader:ShaderFilter;

	var boyfriendReflection:Boyfriend;
	var zoomTwn:FlxTween;

	var keybindTxt:FlxText;
	public var spacePressed:Bool = false;
	public var gotSmushed:Bool = false; //death stuff

	var emitter:FlxEmitter; //health tween shred effect

	override public function create()
	{
		instance = this;
		endingSong = false;

		if (!isStoryMode || StoryMenuState.get_weekData()[storyWeek][0].toLowerCase() == SONG.song.toLowerCase())
		{
			Main.clearMemory();
		}

		super.create();

		for (i in 0...ComboRating.MAX_RENDERED)
		{
			var cr = new ComboRating();
			ratingsGrp.add(cr);
			cr.kill();
			cr.exists = false;
		}

		for (i in 0...ComboNumber.MAX_RENDERED)
		{
			var cn = new ComboNumber();
			numbersGrp.add(cn);
			cn.kill();
			cn.exists = false;
		}

		// Preload
		add(new NoteSplash(0, 0, 0));
		setModCamera(false);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));
		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));

		#if windows
		executeModchart = FlxG.save.data.disableModCharts ? false : FileSystem.exists(Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));
		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));
		#end

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
		detailsPausedText = "Paused - " + detailsText; // String for when the game is paused
		detailsText = isStoryMode ? ("Story Mode: Week " + storyWeek) : "Freeplay";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ displayedScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		currentTimingShown = new TimingText();
		currentTimingShown.cameras = [camHUD];

		if (ClientPrefs.shaders)
		{
			camGame.setFilters(filters);
			camGame.filtersEnabled = true;
			camHUD.filtersEnabled = true;
		}

		persistentUpdate = true;
		persistentDraw = true;

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
		boyfriend = new Boyfriend(770, curBoyfriend == "bf" ? 400 : 450, curBoyfriend);
		if (SONG.song.toLowerCase() == 'shadow')
			boyfriendReflection = new Boyfriend(770, 450, "bf-CoatReflection"); // this is for shadow fever reflection
		dad = new Character(100, 100, SONG.player2);

		switch (SONG.stage)
		{
			default:
				if (SONG.stage == null)
					curStage = "stage";
				else
					curStage = SONG.stage;

				var stageScript:HaxeScript = new HaxeScript('assets/stages/$curStage.hx', "stage");
				scripts.add(stageScript);
				stageScript.callFunction("onCreate");
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
			case 'cave':
				{
					curStage = 'cave';
					defaultCamZoom = 1.6;

					var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('icecavelayer', 'shadow'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.85, 0.85);
					bg.setGraphicSize(Std.int(bg.width * 1.5));
					bg.updateHitbox();
					add(bg);

					var layer1:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('icecavelayer1', 'shadow'));
					layer1.antialiasing = true;
					layer1.scrollFactor.set(0.9, 0.9);
					layer1.setGraphicSize(Std.int(layer1.width * 1.5));
					layer1.updateHitbox();
					add(layer1);

					var layer2:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('icecavelayer2', 'shadow'));
					layer2.antialiasing = true;
					layer2.setGraphicSize(Std.int(layer2.width * 1.5));
					layer2.updateHitbox();
					add(layer2);
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
						bgGirls = new BackgroundGirls(-1205, -290);
						bgGirls.scrollFactor.set(0.9, 0.9);

						if (SONG.song.toLowerCase() == 'chicken-sandwich')
						{
							bgGirls.getScared();
						}

						bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
						bgGirls.updateHitbox();
						add(bgGirls);
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
		}

		gf.scrollFactor.set(0.95, 0.95);

		if (curStage == "schoolEvil")
			meat = new Character(260, 100.9, 'meat');

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

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
				dad.y += 100;
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
			case 'mako':
				dad.y += 445;
				dad.x += 25;
			case 'parents-christmas':
				dad.x -= 500;
			case 'bdbfever':
				dad.x += 80;
				dad.y += 560;
				dad.scrollFactor.set(0.9, 0.9);
			case 'mega':
				dad.x += 150;
				dad.y += 320;
				dad.scrollFactor.set(0.9, 0.9);
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'mega-angry':
				dad.x += 150;
				dad.y += 350;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'flippy':
				dad.y += 300;
				dad.x += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
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

				boyfriendReflection.x = 2535.35;
				boyfriendReflection.y = boyfriend.y + boyfriend.height - 125;
				boyfriendReflection.flipY = true;
				boyfriendReflection.scale.y = 0.7;
				boyfriendReflection.alpha = 0.5;
				boyfriendReflection.blend = BlendMode.ADD;

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
			case 'train':
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
		if (curStage == 'train')
			gf.visible = false;

		if (curStage == 'schoolEvil')
		{
			add(meat);
			FlxTween.circularMotion(meat, 300, 200, 50, 0, true, 4, true, {type: LOOPING});
		}
		add(dad);

		if (curStage == 'cave')
			add(boyfriendReflection);

		add(boyfriend);

		boyfriend.setPosition(boyfriend.x, boyfriend.y);

		if (roboStage != null)
		{
			add(roboForeground);
			roboStage.switchStage(roboStage.curStage);
		}

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

		if (SONG.song.toLowerCase() == 'shadow') // so its underhud
		{
			var snow:Snow = new Snow();
			var bloom:Bloom = new Bloom();

			var bloomShader = new ShaderFilter(bloom);
			snowShader = new ShaderFilter(snow);

			camGame.setFilters([snowShader, bloomShader]);
			snowOn = true;

			camGame.filtersEnabled = true;

			var blue:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLUE);
			blue.alpha = 0.15;
			blue.cameras = [camHUD];
			add(blue);

			var vig:FlxSprite = new FlxSprite().loadGraphic(Paths.image("effectShit/vignette-whitez", 'shared'));
			vig.cameras = [camHUD];
			vig.blend = BlendMode.OVERLAY;
			vig.alpha = 0.2;
			add(vig);

			FlxTween.tween(vig, {alpha: 0.7}, 3, {type: PINGPONG});
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).makeGraphic(601, 19, FlxColor.BLACK);
		if (ClientPrefs.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.antialiasing = true;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.createFilledBar(FlxColor.fromString('#FF' + curOpponent.iconColor), FlxColor.fromString('#FF' + curPlayer.iconColor));
		healthBar.antialiasing = true;
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 35, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), #if !mobile 18 #else 24 #end, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		updateScoring();

		scoreTxt.borderSize = 1.25;
		FlxG.signals.gameResized.add(onGameResize);

		
		emitter = new FlxEmitter(50, 75, 200);
		emitter.makeParticles(11, 11, FlxColor.fromString('#FF' + curPlayer.iconColor), 200);

		/*var particles = new FlxParticle();
		particles.makeGraphic(11, 11, FlxColor.fromString('#FF' + curPlayer.iconColor));
		emitter.add(particles);*/

		emitter.launchMode = FlxEmitterMode.CIRCLE;
		emitter.launchAngle.set(-45, 45);
		emitter.lifespan.set(0.1, 1);
		emitter.alpha.set(1, 1, 0, 0);
		emitter.acceleration.set(0, 0, 0, 0, 200, 200, 400, 400);
		add(emitter);

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		add(scoreTxt);

		if (ClientPrefs.botplay)
		{
			botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (ClientPrefs.downscroll ? 60 : -60), 0, "BOTPLAY", 20);
			botPlayState.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botPlayState.cameras = [camHUD];
			FlxTween.tween(botPlayState, {alpha: 0}, 1, {type: PINGPONG});
			// add(botPlayState);
		}

		if (!ClientPrefs.downscroll)
			healthBarBG.y - 100;

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

		lanes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		emitter.cameras = [camHUD];

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
			case 'bazinga' | 'crucify' | 'hallow' | 'hardships' | 'portrait' | 'run':
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
			case 'dead-mans-melody':
				keybindTxt = new FlxText(0, 0, FlxG.width, "YOUR DODGE/PARRY KEY IS " + ClientPrefs.dodgeBind, 20);
				keybindTxt.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				keybindTxt.cameras = [camHUD];
				keybindTxt.screenCenter();
				keybindTxt.antialiasing = true;
				keybindTxt.y = FlxG.height - 100;
				add(keybindTxt);
				keybindTxt.alpha = 0;
			case 'bad-nun':
				beatClass = shaders.BadNun;
		}

		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		startingSong = true;

		if (SONG.song.toLowerCase() == 'shadow') // hide hud without removing it plus dialogue stuff
		{
			dark = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
			dark.cameras = [camHUD];
			add(dark);
		}

		var cutscenePath:String = 'assets/data/${SONG.song.toLowerCase()}/cutscene.hx';
		if (Assets.exists(cutscenePath))
		{
			inCutscene = true;
			var cutsceneScript:HaxeScript = new HaxeScript(cutscenePath, "cutscene");
			scripts.add(cutsceneScript);
			cutsceneScript.callFunction("onCreate");
		}
		else if (isStoryMode || curSong == "Shadow")
		{
			switch (curSong.toLowerCase())
			{
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
		onGameResize(FlxG.stage.window.width, FlxG.stage.window.height);

		for (i in [false, true]) // call both of these so BF_CAM_POS and DAD_CAM_POS are set
			moveCamera(i);

		moveCamera(!PlayState.SONG.notes[curSection].mustHitSection);

		songScript = new HaxeScript(null, "modchart");
		scripts.add(songScript);
		songScript.callFunction("onCreate");
		scripts.callFunction("onCreatePost");

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

	function openDialogue(?callback:Void->Void):Void
	{
		var dialoguePath = 'assets/data/${SONG.song.toLowerCase()}/dialogue.xml';
		if (!sys.FileSystem.exists(dialoguePath))
		{
			startCountdown();
			return;
		}

		inCutscene = true;
		if (SONG.song.toLowerCase() == 'shadow')
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 90, boyfriend.getMidpoint().y - 150);
			camLocked = true;
		}
		else
			camFollow.setPosition(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);

		var doof:DialogueBox = new DialogueBox(dialoguePath);
		doof.cameras = [camHUD];
		doof.finishCallback = callback == null ? startCountdown : callback;
		add(doof);
	}

	var startTimer:FlxTimer;

	#if windows
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
				var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
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
		startedCountdown = true;
		skipDialogue = true;
		inCutscene = false;

		generateStaticArrows(cpuStrums, FlxG.width * 0.25, false);
		generateStaticArrows(playerStrums, FlxG.width * 0.75, true);

		#if windows
		if (executeModchart)
		{
			luaModchart = LuaScript.createModchartState();
			luaModchart.executeState('start', [PlayState.SONG.song]);
		}
		#end

		Conductor.songPosition = -Conductor.crochet * 5;

		if (SONG.song.toLowerCase() == 'dead-mans-melody' || SONG.song.toLowerCase() == 'c354r')
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

			if (boyfriendReflection != null)
				boyfriendReflection.dance();

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
			if (swagCounter > 0 && SONG.song.toLowerCase() != 'shadow')
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

		var dialoguePath = 'assets/data/${SONG.song.toLowerCase()}/dialogue-end.xml';
		var doof:DialogueBox = new DialogueBox(dialoguePath);
		doof.cameras = [camHUD];
		doof.finishCallback = endSong;
		add(doof);
	}

	function startSong():Void
	{
		startingSong = false;

		if (SONG.song.toLowerCase() == 'shadow') // so its underhud
		{
			dark.alpha = 0;
			camGame.flash(FlxColor.BLACK, 10);
			camHUD.alpha = 0;
			camZooming = true;

			for (i in 0...cpuStrums.length)
			{
				FlxTween.tween(cpuStrums.members[i], {alpha: 0.6}, 2, {type: PINGPONG, startDelay: 0.5 + (0.2 * i)});
			}

			zoomTwn = FlxTween.tween(camGame, {zoom: 1.0}, 19, {
				ease: FlxEase.sineInOut,
				onComplete: (twn) ->
				{
					defaultCamZoom = camGame.zoom;
				}
			});
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

		songPosBG = new FlxSprite(0, 10).loadGraphicFromSprite(healthBarBG);
		if (ClientPrefs.downscroll)
			songPosBG.y = FlxG.height * 0.9 + 45;
		songPosBG.screenCenter(X);
		songPosBG.scale.set(0.8, 0.8);

		songName = new FlxText(0, songPosBG.y + (songPosBG.height / 2), 0, '', 16);
		songName.text = CoolUtil.capitalizeFirstLetters(StringTools.replace(SONG.song, '-', ' ')) + ' - ${Song.getArtist(curSong)}';
		songName.y -= songName.height / 2;

		songName.antialiasing = true;
		songName.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.borderSize = 1.25;
		songName.screenCenter(X);

		if (ClientPrefs.songPosition)
		{
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), Conductor,
				'songPosition', 0, FlxG.sound.music.length
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
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ displayedScore
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

		var totalPlayerNotes:Int = 0;
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

				if (gottaHitNote)
					totalPlayerNotes++;

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

		Ratings.init(totalPlayerNotes);
	}

	private function generateStaticArrows(grp:FlxTypedGroup<FlxSprite>, centerPoint:Float, isPlayer:Bool = true):Void
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
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ displayedScore
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
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ FlxMath.roundDecimal(accuracy, 2)
					+ "% | Score: "
					+ displayedScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					FlxG.sound.music.length
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + '($storyDifficultyText)' + Ratings.GenerateLetterRank(accuracy), iconRPC);
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
	var canPause:Bool = true;
	var iconHurtTimer:Float = 0;

	public var cameraSpeed:Float = 1.3;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(controls.DODGE && !ClientPrefs.botplay && SONG.song.toLowerCase() == 'dead-mans-melody')
		{
			trace("GAY");
			spacePressed = true;
		}

		if(FlxG.keys.justPressed.E)
		{
			healthTween(-0.02);
		}

		if (snowOn) // snow stuff ig idk stealing from hypno
			snowShader.shader.data.time.value = [Conductor.songPosition / (Conductor.stepCrochet * 8)];

		// Using 180 here since that's the framerate I test with
		FlxG.camera.followLerp = elapsed * cameraSpeed * (180 / FlxG.drawFramerate);
		iconHurtTimer -= elapsed;

		if (SONG.song.toLowerCase() == 'shadow')
		{
			if (health >= 2) // for sum reason, the health goes above 2, then its like a timer for the thing to work so i did this to fix it
			{
				health = 2;
			}

			if (health == 2 || healthBar.percent == 100)
			{
				healthTween(-1);
			}
		}

		if (ClientPrefs.shaders)
		{
			if (wiggleEffect != null)
			{
				wiggleEffect.update(elapsed);
			}
		}

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

				if (boyfriendReflection != null)
				{
					if (boyfriendReflection.animation.curAnim.name.startsWith("idle"))
						boyfriendReflection.playAnim('hey');
				}

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

			@:privateAccess
			for (i in FlxTween.globalManager._tweens)
			{
				i.active = false;
			}

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

		if (health >= 2)
			health = 2;

		switch (healthBar.fillDirection)
		{
			default:
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - 26);
			case LEFT_TO_RIGHT:
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01) - 26);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01)) - (iconP2.width - 26);
		}

		emitter.x = iconP2.x + 60;

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
		if (FlxG.keys.justPressed.EIGHT && SONG.song.toLowerCase() != 'shadow')
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

		if (health <= 0)
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			if (SONG.song.toLowerCase() == 'shadow') // so its underhud
				camGame.filtersEnabled = false;

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ displayedScore
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

			if (SONG.song.toLowerCase() == 'shadow') // so its underhud
				camGame.filtersEnabled = false;

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ FlxMath.roundDecimal(accuracy, 2)
				+ "% | Score: "
				+ displayedScore
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
			if (daNote.mustPress && daNote.type == 1 && !daNote.animPlayed && daNote.timeDiff <= 750 * FlxG.sound.music.pitch)
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
							switch (curSong)
							{
								case 'Prayer':
									if (curStep >= 1359 && curStep < 1422) health -= 0.025; else if (curStep < 1681) health -= health > 0.2 ? 0.02 : 0.0065;
								case 'Crucify':
									health -= (daNote.isSustainNote ? 0.01 : 0.03);
								case 'Bazinga':
									health -= (daNote.isSustainNote ? 0.01435 : 0.025);
								default:
									health -= 0.02;
							}

							gf.playAnim('scared');
						case 'SG':
							if (healthBar.percent > 5 && !hpTweening)
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
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		scripts.callFunction("onPostUpdate", [elapsed]);
	}

	public var DAD_CAM_POS:FlxPoint = new FlxPoint(0, 0);
	public var BF_CAM_POS:FlxPoint = new FlxPoint(0, 0);

	public var DAD_CAM_OFFSET:FlxPoint = new FlxPoint(0, 0);
	public var BF_CAM_OFFSET:FlxPoint = new FlxPoint(0, 0);

	var camLocked:Bool = false;

	var hpTweening:Bool = false;
	var healthTweenOBJ:FlxTween;
	var startShredding:Bool = false;

	public function healthTween(amt:Float)
	{
		if (healthTweenOBJ != null)
			healthTweenOBJ.cancel();

		
		emitter.start(false, 0.01, 0);


		hpTweening = true;
		healthTweenOBJ = FlxTween.num(health, health + amt, 0.5, {ease: FlxEase.cubeInOut}, function(v:Float)
		{
			health = v;
			hpTweening = false;
			
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				emitter.kill();
				
			});
		});

		scripts.callFunction("onHealthTween", [amt]);
	}

	public function moveCamera(isDad:Bool = false)
	{
		if (!camLocked)
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
						camFollow.y = dad.getMidpoint().y - 130;
						camFollow.x = dad.getMidpoint().x + 175;
					case 'peakek' | 'peasus':
						camFollow.x = dad.getMidpoint().x - -400;
					case 'spooky' | 'feralspooky':
						camFollow.x = dad.getMidpoint().x + 190;
						camFollow.y = dad.getMidpoint().y - 30;
					case 'taki':
						camFollow.x = dad.getMidpoint().x + 155;
						camFollow.y = dad.getMidpoint().y - 50;
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
					case 'school' | 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 330;
						camFollow.y = boyfriend.getMidpoint().y - 15;
					case 'spooky' | 'spookyBOO':
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

								if (SONG.song == "Grando")
								{
									camFollow.x -= 110;
									camFollow.y += 110;
								}
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
						camFollow.x = boyfriend.getMidpoint().x - 950;
						camFollow.y = boyfriend.getMidpoint().y - 190;
				}

				camFollow.x += BF_CAM_OFFSET.x;
				camFollow.y += BF_CAM_OFFSET.y;
				BF_CAM_POS.set(camFollow.x, camFollow.y);
			}

			scripts.callFunction("onMoveCamera", [isDad]);
		}
	}

	function updateScoring(bop:Bool = false)
	{
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);

		scoreTxt.text = Ratings.CalculateRanking(displayedScore, accuracy);
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

		if (SONG.song.toLowerCase() == 'shadow')
		{
			Sys.exit(0);
		}

		if (!ClientPrefs.botplay && misses == 0 && !Highscore.fullCombos.exists(SONG.song))
			Highscore.fullCombos.set(SONG.song, 0);

		Highscore.saveScore(SONG.song, displayedScore, storyDifficulty);

		if (isStoryMode)
		{
			campaignScore += displayedScore;

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

				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.flush();

				endingSong = true;

				FlxG.switchState(new StoryMenuState());
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0 || storyDifficulty == 1)
					difficulty = '-easy';

				if (storyDifficulty >= 2)
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

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var wife:Float = Ratings.wife3(noteDiff, Conductor.timeScale);
		var score:Float = Ratings.scorePerNote;
		var daRating = daNote.rating;

		vocals.volume = 1;
		totalNotesHit += wife;

		switch (daRating)
		{
			case 'shit':
				score = 0;
				combo = 0;
				misses++;
				health -= 0.2;
				shits++;
			case 'bad':
				score /= 3;
				health -= 0.06;
				bads++;
			case 'good':
				score /= 2;
				goods++;
				if (!hpTweening)
					health += 0.02;
			case 'sick':
				if (!hpTweening)
					health += 0.04;

				if (ClientPrefs.notesplash)
				{
					var splash:NoteSplash = new NoteSplash(playerStrums.members[daNote.noteData].x, playerStrums.members[daNote.noteData].y, daNote.noteData);
					splash.cameras = [camHUD];
					add(splash);
				}
		}

		songScore += score;
		displayedScore = Math.ceil(songScore);

		if (SONG.song.toLowerCase() == 'shadow')
		{
			return;
		}

		if (daRating != 'miss') // wtf
		{
			var rating:ComboRating = ratingsGrp.recycle(ComboRating);
			rating.create(daRating);
			rating.cameras = [camHUD];
			rating.setPosition((FlxG.width * 0.55) - 125, (FlxG.height * 0.5) - (rating.height / 2) - 50);

			if (songScript.variables["forceComboPos"] != null
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

			ratingsGrp.add(rating);
			add(rating);

			if (ClientPrefs.showPrecision)
			{
				currentTimingShown.text = (FlxG.save.data.botplay ? 0 : FlxMath.roundDecimal(noteDiff, 2)) + 'ms' + (daNote.type == 1 ? "\n    DODGE!" : "");

				currentTimingShown.setPosition(rating.x + 140, rating.y + 100);
				currentTimingShown.velocity.copyFrom(rating.velocity);
				currentTimingShown.acceleration.y = rating.acceleration.y;

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

			if (combo >= 10 || combo == 0)
			{
				var seperatedScore:Array<String> = (combo + "").split('');

				if (seperatedScore.length == 2)
					seperatedScore.insert(0, "0");

				for (i in 0...seperatedScore.length)
				{
					var numScore:ComboNumber = numbersGrp.recycle(ComboNumber);
					numScore.create(seperatedScore[i]);
					numScore.x = rating.x + (43 * i) - 50;
					numScore.y = rating.y + 100 + (usePixelAssets ? 30 : 0);
					numScore.cameras = [camHUD];

					numbersGrp.add(numScore);
					add(numScore);

					FlxTween.tween(numScore, {alpha: 0}, 0.5, {
						onComplete: function(tween:FlxTween)
						{
							numScore.kill();
							numScore.exists = false;
						},
						startDelay: 0.3
					});
				}
			}

			FlxTween.tween(rating, {alpha: 0}, 0.45, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
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
		if (boyfriend.animation.curAnim.name != 'dodge')
		{
			curPlayer.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			if (boyfriendReflection != null)
				boyfriendReflection.playAnim('sing' + dataSuffix[direction] + 'miss', true);
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

				// if(SONG.song.toLowerCase() != 'shadow')
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
				scripts.callFunction("onPlayerNoteHit", [note]);
				curPlayer.holdTimer = 0;
				if (note.properties.singAnim == null)
					curPlayer.playAnim('sing' + dataSuffix[note.noteData] + altSuffix, true);
				else
					curPlayer.playAnim(note.properties.singAnim, true);

				if (boyfriendReflection != null)
				{
					boyfriendReflection.holdTimer = 0;
					boyfriendReflection.playAnim('sing' + dataSuffix[note.noteData] + altSuffix, true);
				}
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

		if (curSong == 'Shadow')
		{
			switch (curStep)
			{
				case 255:
					camLocked = false;
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
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% | Score: "
			+ displayedScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			FlxG.sound.music.length
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

		if (beatClass != null)
		{
			Reflect.callMethod(beatClass, Reflect.field(beatClass, "beatHit"), [curBeat]);
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'shadow':
					switch (curBeat)
					{
						case 64:
							FlxTween.tween(camHUD, {alpha: 1}, 0.5);
						case 96:
							defaultCamZoom = 0.5;
						case 128:
							beatSpeed = 1;
						case 256:
							beatSpeed = 2;
							defaultCamZoom += 0.05;
						case 320:
							defaultCamZoom -= 0.05;
							beatSpeed = 1;
						case 448:
							beatSpeed = 6;
						case 511:
							moveCamera(true);
							camLocked = true;

							zoomTwn = FlxTween.tween(camGame, {zoom: 0.7}, 10, {
								ease: FlxEase.sineInOut,
								onComplete: (twn) ->
								{
									defaultCamZoom = camGame.zoom;
								}
							});
						case 512:
							FlxTween.tween(camHUD, {alpha: 0}, 1);
							dad.playAnim('bye', true);
							dad.animation.finishCallback = function(anim)
							{
								dad.alpha = 0;
							}
					}

					if (curBeat >= 64 && curBeat <= 511)
					{
						if ((FlxG.camera.zoom < 1.35 && curBeat % beatSpeed == 0))
						{
							FlxG.camera.zoom += 0.015;
							camHUD.zoom += 0.05;
						}
					}

				case 'hardships':
					if (curBeat == 158)
						boyfriend.useAlternateIdle = true;
				case 'dead-mans-melody':
					switch(curBeat)
					{
						case 148:
							FlxTween.tween(keybindTxt, {alpha: 1, y: keybindTxt.y - 15}, 1, {ease: FlxEase.circOut});
						case 176: 
							FlxTween.tween(keybindTxt, {alpha: 0, y: keybindTxt.y + 15}, 1, {ease: FlxEase.circIn});
					}
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
						for (i in takiBGSprites)
							i.visible = true;
					}
			}
		}

		notes.sort(FlxSort.byY, (ClientPrefs.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].changeBPM)
		{
			Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			FlxG.log.add('CHANGED BPM!');
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
			var specialAnims:Array<String> = ['dodge', 'hey', 'shoot', 'phone', 'slam', 'transform', 'bye'];
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

				if (boyfriendReflection != null)
					boyfriendReflection.dance();
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
	var keysHeld:Array<Bool> = [false, false, false, false];

	private function onKeyPress(input:KeyboardEvent)
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

		Conductor.songPosition = previousTiming;
	}

	private function onKeyRelease(event:KeyboardEvent)
	{
		if (paused || inCutscene)
			return;

		var key:Int = -1;

		@:privateAccess
		key = ClientPrefs.keybinds.indexOf(FlxKey.toStringMap[event.keyCode]);

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
}
