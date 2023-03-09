package sprites.objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import shaders.ShadersHandler;

/*
	Contains all of the code for the background switching in Loaded.
	This code is almost a year old so please ignore any weird quirks in the code im BEGGING YOU.
	If any major bugs pop up im rewriting this entire thing lmao

	To add a stage all you have to do is create the sprite variables contained inside the stage and create an instance in the stages map
		stages['stage name'] = new RoboStage([background_sprites], [foreground_sprites], [positioning], [character scrollfactors], cameraZoom);
 */
class RoboBackground
{
	public var stages:Map<String, RoboStage> = [];
	public var curStage:String = 'c354r-default';
	public var instance:PlayState;

	private var taki:Character;
	private var robofever:Character;
	var tea_pixel:Character;
	var fever_pixel:Character;
	var cherry:Character;

	public function new()
	{
		instance = PlayState.instance;

		var bg:FlxSprite = new FlxSprite(-450, -355).loadGraphic(Paths.image('roboStage/ROBO_BG'));
		bg.antialiasing = true;
		bg.scale.set(1.85, 1.85);
		bg.scrollFactor.set(0.9, 0.85);

		var rail:FlxSprite = new FlxSprite(-450 + 660, -355 + 413).loadGraphic(Paths.image('roboStage/rail'));
		rail.antialiasing = true;
		rail.origin.set(0, 0);
		rail.scale.set(1.85, 1.85);
		rail.scrollFactor.set(0.9, 0.85);

		var city:FlxSprite = new FlxSprite(-450, -355).loadGraphic(Paths.image('roboStage/ROBO_BG_CITY'));
		city.antialiasing = true;
		city.scale.set(1.85, 1.85);
		city.scrollFactor.set(0.85, 0.95);

		var sky:FlxSprite = new FlxSprite(-450, -355).loadGraphic(Paths.image('roboStage/ROBO_BG_SKY'));
		sky.antialiasing = true;
		sky.scale.set(1.85, 1.85);
		sky.scrollFactor.set(0.65, 0.95);

		var overlay:FlxSprite = new FlxSprite(-450, -355).loadGraphic(Paths.image('roboStage/ROBO_BG_OVERLAY'));
		overlay.antialiasing = true;
		overlay.scale.set(1.85, 1.85);
		overlay.scrollFactor.set(0.85, 0.85);
		overlay.alpha = 0.35;

		var wires:FlxSprite = new FlxSprite(-450, -355).loadGraphic(Paths.image('roboStage/ROBO_BG_WIRES'));
		wires.antialiasing = true;
		wires.scale.set(1.85, 1.85);
		wires.scrollFactor.set(0.85, 0.85);

		stages['c354r-default'] = new RoboStage([sky, city, rail, bg, wires], [overlay],
			["boyfriend" => [880, 482.3], "gf" => [335, 149], "dad" => [160, 315.3]], [], 0.4);

		if (PlayState.SONG.song == 'Loaded')
		{
			taki = new Character(0, 0, "gf-taki");
			robofever = new Character(0, 0, "robo-cesar-pixel");
			tea_pixel = new Character(0, 0, "tea-pixel");
			fever_pixel = new Character(0, 0, "bf-pixel", true);
			cherry = new Character(360, 70, "gf-cherry", false);
			tea_pixel.scrollFactor.set(0.9, 0.9);
			fever_pixel.scrollFactor.set(0.9, 0.9);
			robofever.scrollFactor.set(0.9, 0.9);
			cherry.scrollFactor.set(0.95, 0.95);
			// ZARDY STAGE
			var dumboffset:Int = 95;

			dumboffset = 365;
			var offsetY:Int = 200;
			var zardybg:FlxSprite = new FlxSprite(164.4 - dumboffset, 0 - offsetY).loadGraphic(Paths.image('roboStage/zardy_bg'));
			zardybg.antialiasing = true;
			zardybg.scrollFactor.set(0.75, 0.3);

			var zardytown:FlxSprite = new FlxSprite(140.65 - dumboffset, 1.1 - offsetY).loadGraphic(Paths.image('roboStage/zardy_fevertown'));
			zardytown.antialiasing = true;
			zardytown.scrollFactor.set(0.6, 1);

			var zardyforeground:FlxSprite = new FlxSprite(161.65 - dumboffset, 6.15 - offsetY).loadGraphic(Paths.image('roboStage/zardy_foreground'));
			zardyforeground.antialiasing = true;
			zardyforeground.scrollFactor.set(1, 1);

			stages['zardy'] = new RoboStage([zardybg, zardytown, zardyforeground], [], [
				"boyfriend" => [1366.3 - (dumboffset), 525.8 - offsetY],
				"gf" => [810.9 - (dumboffset * 1.275), 244.4 - offsetY],
				"dad" => [492.5 - (dumboffset * 1.765) + (150), 410.8 - offsetY - (50)]
			], [], 0.715);

			// WHITTY STAGE
			var whittyBG:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/alleyway'));
			whittyBG.antialiasing = true;
			whittyBG.scrollFactor.set(0.9, 0.9);
			whittyBG.scale.set(1.25, 1.25);
			stages['whitty'] = new RoboStage([whittyBG], [], [], [], 0.55);

			// TRICKY
			var trickyBG:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/rockymountains'));
			trickyBG.antialiasing = true;
			trickyBG.scrollFactor.set(0.9, 0.9);
			trickyBG.scale.set(1.25, 1.25);

			var trickySky:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/rockysky'));
			trickySky.antialiasing = true;
			trickySky.scrollFactor.set(0.7, 0.7);
			trickySky.scale.set(1.25, 1.25);

			stages['tricky'] = new RoboStage([trickySky, trickyBG], [], ["boyfriend" => [775, 482.3], "gf" => [115, 149], "dad" => [-160, 315.3]], [], 0.55);

			// matt shit
			var mattbg:FlxSprite = new FlxSprite(-200, -230).loadGraphic(Paths.image('roboStage/matt_bg'));
			mattbg.antialiasing = true;
			mattbg.scrollFactor.set(0.4, 0.4);
			mattbg.scale.set(1.05, 1.05);

			var mattfg:FlxSprite = new FlxSprite(mattbg.x, mattbg.y).loadGraphic(Paths.image('roboStage/matt_foreground'));
			mattfg.antialiasing = true;
			mattfg.scrollFactor.set(0.9, 0.9);
			mattfg.scale.set(1.05, 1.05);

			var mattcrowd:FlxSprite = new FlxSprite(mattbg.x - 55, mattbg.y - 15);
			mattcrowd.frames = Paths.getSparrowAtlas('roboStage/matt_crowd');
			mattcrowd.animation.addByPrefix('bop', 'robo crowd hehe', 24, false);
			mattcrowd.antialiasing = true;
			mattcrowd.scrollFactor.set(0.85, 0.85);

			var spotlight:FlxSprite = new FlxSprite(mattbg.x, mattbg.y).loadGraphic(Paths.image('roboStage/matt_spotlight'));
			spotlight.antialiasing = true;
			spotlight.scrollFactor.set(0.73, 0.73);

			var dumboffset:Int = 95;
			stages['matt'] = new RoboStage([mattbg, mattcrowd, mattfg], [spotlight], [
				"boyfriend" => [1280.2 - dumboffset, 482.3 - 150],
				"gf" => [585 - dumboffset, 149 - 70],
				"dad" => [130.7 - dumboffset + (100), 365.3 - 150 - (50)] // 100 and 50 are for the new sprites
			], [], 0.73);

			// week 1
			var bmp:BitmapData = openfl.Assets.getBitmapData(Paths.image('w1city'));

			var bg:FlxSprite = new FlxSprite(-720, -450).loadGraphic(bmp, true, 2560, 1400);
			bg.animation.add('idle', [3], 0);
			bg.animation.play('idle');
			bg.scale.set(0.3, 0.3);
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);

			var w1city = new FlxSprite(bg.x, bg.y).loadGraphic(bmp, true, 2560, 1400);
			w1city.animation.add('idle', [0, 1, 2], 0);
			w1city.animation.play('idle');
			w1city.scale.set(bg.scale.x, bg.scale.y);
			w1city.antialiasing = true;
			w1city.scrollFactor.set(0.9, 0.9);
			w1city.ID = 42069;

			var stageFront:FlxSprite = new FlxSprite(-730, 530).loadGraphic(Paths.image('stagefront'));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(0.9, 0.9);
			stageCurtains.active = false;

			stages['week1'] = new RoboStage([bg, w1city, stageFront, stageCurtains], [], ["boyfriend" => [1070, 360], "gf" => [400, 85], "dad" => [-50, 200]],
				[], 0.757);

			// WEEK 5
			var w5bg:FlxSprite = new FlxSprite(-820, -400).loadGraphic(Paths.image('yukichi', 'week5'));
			w5bg.antialiasing = true;
			w5bg.scrollFactor.set(0.9, 0.9);

			stages['week5'] = new RoboStage([w5bg], [], [], [], 0.55);

			// WEEK 2.5
			var church = new FlxSprite(-948, -779).loadGraphic(Paths.image('bg_taki'));
			church.antialiasing = true;

			stages['church'] = new RoboStage([church], [], [], ["gf" => 1, "dad" => 1, "boyfriend" => 1], 0.55);

			// SCHOOL
			var bgSky = new FlxSprite(0, -200).loadGraphic(Paths.image('weeb/weebSky', 'week6'));
			bgSky.scrollFactor.set(0.9, 0.9);

			var repositionShit = -200;

			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
			bgSchool.scrollFactor.set(0.9, 0.9);

			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
			bgStreet.scrollFactor.set(0.9, 0.9);

			var widShit = Std.int(bgSky.width * 6);

			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);

			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();

			var bgFront:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebfront', 'week6'));
			bgFront.scrollFactor.set(0.9, 0.9);

			var bgOverlay:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weeboverlay', 'week6'));
			bgOverlay.scrollFactor.set(0.9, 0.9);

			bgFront.setGraphicSize(widShit);
			bgOverlay.setGraphicSize(widShit);

			bgFront.updateHitbox();
			bgOverlay.updateHitbox();

			stages['school'] = new RoboStage([bgSky, bgSchool, bgStreet, bgFront, bgOverlay], [], [], ["gf" => 1], 0.98);

			// Week 4
			var week4Assets:Array<FlxSprite> = [];
			for (i in ["sky", "city", "water", "boardwalk"])
			{
				var spr = new FlxSprite(-300, -300).loadGraphic(Paths.image(i, 'week4'));
				spr.scale.set(1.4, 1.4);
				spr.antialiasing = true;
				week4Assets.push(spr);
			}

			stages['boardwalk'] = new RoboStage(week4Assets.concat([cherry]), [], ["boyfriend" => [850, 395], "dad" => [180, 245]],
				["boyfriend" => 1, "dad" => 1], 0.9);

			// fixes initial lag spike when switching to the week 4 stage
			addSprites(stages['boardwalk'].backgroundSprites, instance.roboBackground);
			instance.gf.visible = false;
		}
	}

	public function switchStage(stage:String)
	{
		trace('Switching stage to $stage');

		if (stages[stage] == null)
			return trace('$stage does not exist');

		var _stage:RoboStage = stages[stage];

		addSprites(_stage.backgroundSprites, instance.roboBackground);
		addSprites(_stage.foregroundSprites, instance.roboForeground);

		for (ch => pos in _stage.positioning)
		{
			if (Reflect.field(instance, ch) != null)
			{
				var character:Character = Reflect.field(instance, ch);
				character.setPosition(pos[0], pos[1]);
				character.scrollFactor.set(_stage.characterScrolling[ch], _stage.characterScrolling[ch]);
			}
		}

		instance.defaultCamZoom = _stage.cameraZoom;

		if (curStage == stage)
			return;

		if (instance.health > 1)
			instance.health = 1;

		instance.gf.color = instance.boyfriend.color = instance.dad.color = FlxColor.WHITE;
		switch (stage)
		{
			case 'tricky':
				instance.gf.color = instance.boyfriend.color = instance.dad.color = FlxColor.fromString("#FFE6D8");
			case 'church':
				replaceGf('taki');
			case 'boardwalk' | 'matt':
				replaceGf('die');
			default:
				replaceGf('gf');
		}

		var curGF:Character = stage == 'church' ? taki : stage == 'boardwalk' ? cherry : stage == 'school' ? tea_pixel : instance.gf;
		instance.camFollow.setPosition(curGF.getGraphicMidpoint().x - 460, curGF.getGraphicMidpoint().y + 250);

		curStage = stage;
		instance.camGame.flash(stage == 'default' || stage == 'c354r-default' ? FlxColor.BLACK : FlxColor.WHITE, 0.45);

		if (curStage == 'default' || curStage == 'c354r-default')
			instance.camGame.zoom = _stage.cameraZoom;

		instance.camZooming = true;
		instance.disableCamera = false;

		instance.remove(instance.roboForeground);
		instance.add(instance.roboForeground);

		instance.moveCamera(!PlayState.SONG.notes[Std.int(instance.curStep / 16)].mustHitSection);
	}

	public function addSprites(sprites:Array<FlxSprite>, typedGroup:FlxTypedGroup<FlxSprite>)
	{
		for (spr in typedGroup)
		{
			if (spr != null)
			{
				typedGroup.remove(spr, true);
				spr.kill();
			}
		}

		for (spr in sprites)
		{
			if (!spr.alive)
				spr.revive();

			typedGroup.add(spr);
		}
	}

	public function beatHit(curBeat:Int)
	{
		if (PlayState.SONG.song == 'Loaded')
		{
			switch (curBeat)
			{
				case 0 | 1:
					instance.camHUD.visible = false;

				case 32:
					instance.camHUD.visible = true;
					switchStage('zardy');
					instance.defaultCamZoom += 0.22;
				case 64:
					instance.defaultCamZoom -= 0.22;
				case 88:
					instance.defaultCamZoom += 0.3;
				case 92 | 104 | 123 | 464 | 470 | 472 | 475 | 488 | 491:
					instance.defaultCamZoom += curBeat > 480 ? 0.05 : 0.085;
				case 399 | 528:
					instance.gf.playAnim('cheer', true);
				case 96 | 463:
					switchStage('tricky');
				case 128:
					switchStage('whitty');
				case 144 | 288:
					switchStage('boardwalk');
				case 160 | 592:
					switchStage(/* 'default' */ 'c354r-default');
				case 224 | 560:
					switchStage('week1');
				case 256 | 432:
					switchStage('week5');
				case 320: // ur girl
					switchStage('school');
					changeStrums(true);
					instance.usePixelAssets = true;
					instance.iconP1.swapCharacter('bf-pixel');
					instance.iconP2.swapCharacter('robofever-pixel');
					tea_pixel.setPosition(instance.gf.x + 460, instance.gf.y + 265);
					fever_pixel.setPosition(instance.boyfriend.x + 190, instance.boyfriend.y + 50);
					robofever.setPosition(instance.dad.x + 455, instance.dad.y + 180);

					instance.add(tea_pixel);
					instance.add(robofever);
					instance.add(fever_pixel);
					instance.gf.visible = false;
					instance.dad.visible = false;
					instance.boyfriend.visible = false;
					instance.curOpponent = robofever;
					instance.curPlayer = fever_pixel;
				case 336:
					switchStage(/* 'default' */ 'c354r-default');
					changeStrums();
					instance.usePixelAssets = false;
					instance.iconP1.swapCharacter(PlayState.SONG.player1);
					instance.iconP2.swapCharacter(PlayState.SONG.player2);
					instance.remove(tea_pixel);
					instance.remove(fever_pixel);
					instance.remove(robofever);
					instance.dad.visible = true;
					instance.boyfriend.visible = true;
					instance.curOpponent = instance.dad;
					instance.curPlayer = instance.boyfriend;
				case 400:
					switchStage('church');
				case 494:
					PlayState.instance.moveCamera(true);
					PlayState.instance.dad.playAnim('hey', true);
				case 496:
					switchStage('matt');
				case 355 | 359 | 387 | 391:
					if (curBeat == 355)
						instance.filters.push(ShadersHandler.chromaticAberration);

					if (curBeat == 355 || curBeat == 359)
					{
						FlxTween.tween(ShadersHandler.chromaticAberration.shader, {redOffset: 0.0065}, Conductor.crochet / 1300);
						FlxTween.tween(ShadersHandler.chromaticAberration.shader, {blueOffset: -0.0065}, Conductor.crochet / 1300);
						instance.camGame.focusOn(new FlxPoint(instance.dad.getMidpoint().x + 250, instance.dad.getMidpoint().y - 190));
					}
					else
						instance.camGame.focusOn(new FlxPoint(instance.boyfriend.getMidpoint().x - 300, instance.boyfriend.getMidpoint().y - 320));
					instance.defaultCamZoom += 0.245;
					instance.camGame.zoom = instance.defaultCamZoom;
				case 356 | 360 | 388 | 392:
					FlxTween.tween(ShadersHandler.chromaticAberration.shader, {redOffset: 0}, 0.25);
					FlxTween.tween(ShadersHandler.chromaticAberration.shader, {blueOffset: 0}, 0.25);
					instance.defaultCamZoom -= 0.245;
					instance.camGame.zoom = instance.defaultCamZoom;
			}
		}

		cherry.dance();
		taki.dance();
		tea_pixel.dance();

		for (i in instance.roboBackground.members)
		{
			animCheck(i);

			switch (curStage)
			{
				case 'week1':
					if (i.ID == 42069 && curBeat % 4 == 0) // this is such a shitty way of doing it
					{
						if (i.animation.curAnim.curFrame > 2)
							i.animation.curAnim.curFrame = 0;
						else
							i.animation.curAnim.curFrame++;
					}
			}
		}

		for (i in instance.roboForeground.members)
		{
			animCheck(i);
		}
	}

	public function replaceGf(gf:String)
	{
		switch (gf)
		{
			case 'taki':
				instance.gf.visible = false;
				instance.remove(instance.boyfriend, true);
				instance.remove(instance.dad, true);
				instance.remove(instance.roboForeground, true);
				instance.add(taki);
				instance.add(instance.dad);
				instance.add(instance.boyfriend);
				instance.add(instance.roboForeground);
				taki.setPosition(245, 149 - 190);
			case 'die':
				instance.gf.visible = false;
			default:
				instance.gf.visible = false;

				if (instance.members.contains(taki))
				{
					instance.remove(taki);
				}
		}
	}

	public function animCheck(i:FlxSprite)
	{
		if (i != null && i.animation.getByName('bop') != null)
		{
			i.animation.play('bop', true);
			return;
		}

		if (Reflect.field(i, 'beatHit') != null)
			Reflect.callMethod(i, Reflect.field(i, 'beatHit'), []);
	}

	public function changeStrums(?pixel:Bool)
	{
		if (pixel)
		{
			PlayState.cpuStrums.forEach(function(babyArrow:FlxSprite)
			{
				babyArrow.loadGraphic(Paths.image('notes/ROBO-NOTES-PIXEL', 'shared'), true, 17, 17);
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

			PlayState.playerStrums.forEach(function(babyArrow:FlxSprite)
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
			// SWITCHING BACK TO ITS NOTESKIN
			PlayState.cpuStrums.forEach(function(babyArrow:FlxSprite)
			{
				var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

				babyArrow.frames = Paths.getSparrowAtlas('notes/ROBO-NOTE_assets');
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

			PlayState.playerStrums.forEach(function(babyArrow:FlxSprite)
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
}

class RoboStage
{
	public var backgroundSprites:Array<FlxSprite> = [];
	public var foregroundSprites:Array<FlxSprite> = [];

	public var cameraZoom:Float = 0.4;
	public var positioning:Map<String, Array<Float>> = [];
	public var characterScrolling:Map<String, Float> = [];

	private var defPositioning:Map<String, Array<Float>> = ["boyfriend" => [1085.2, 482.3], "gf" => [245, 149], "dad" => [-254.7, 315.3]];

	public function new(backgroundSprites:Array<FlxSprite>, ?foregroundSprites:Array<FlxSprite>, ?positioning:Map<String, Array<Float>>,
			?characterScrolling:Map<String, Float>, cameraZoom:Float)
	{
		for (k => v in defPositioning)
		{
			if (!positioning.exists(k))
			{
				positioning[k] = v;
			}

			if (!characterScrolling.exists(k))
			{
				characterScrolling[k] = 0.9;
			}
		}

		if (PlayState.instance.boyfriend.curCharacter == "bf" && cameraZoom != 0.98)
		{
			positioning["boyfriend"][1] -= 50;
		}

		this.positioning = positioning;
		this.characterScrolling = characterScrolling;
		this.cameraZoom = cameraZoom;

		this.backgroundSprites = backgroundSprites;
		this.foregroundSprites = foregroundSprites == null ? [] : foregroundSprites;
	}
}
