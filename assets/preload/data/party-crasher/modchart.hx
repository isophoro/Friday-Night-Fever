import flixel.util.FlxTimer;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import shaders.Scanline;

var pixelDiner;
var yukichi_pixel;
var tea_pixel;
var fever_pixel;

function onCreate()
{
	game.defaultCamZoom = 0.6;

	FlxTimer.globalManager.clear();
	game.startSong();
	FlxG.sound.music.time = 0;
	Conductor.songPosition = 0;
	getGlobalVar("bop").y += 90;
	getGlobalVar("bop").x += 50;
	setHUDVisibility(false);
	snapCamera();

	pixelDiner = new FlxSprite(-950, -200).loadGraphic(Paths.image('yukichi-pixel', 'week5'));
	pixelDiner.antialiasing = true;
	pixelDiner.scrollFactor.set(0.9, 0.9);
	pixelDiner.antialiasing = false;
	add(pixelDiner);
	pixelDiner.origin.set(0, 0);
	pixelDiner.scale.set(6, 6);
	pixelDiner.visible = false;

	yukichi_pixel = new Character(0, 0, "yukichi-pixel");
	tea_pixel = new Character(0, 0, "tea-pixel");
	fever_pixel = new Character(0, 0, "bf-pixeldemon", true);
	tea_pixel.scrollFactor.set(0.9, 0.9);
	fever_pixel.scrollFactor.set(0.9, 0.9);
	yukichi_pixel.scrollFactor.set(0.9, 0.9);
	tea_pixel.setPosition(gf.x + 300, gf.y + 320);
	fever_pixel.setPosition(boyfriend.x + 150, boyfriend.y + 37);
	yukichi_pixel.setPosition(dad.x + 190, dad.y + 190);
	fever_pixel.visible = false;
	tea_pixel.visible = false;
	yukichi_pixel.visible = false;

	add(tea_pixel);
	add(yukichi_pixel);
	add(fever_pixel);
}

function onBeatHit(curBeat:Int)
{
	switch (curBeat)
	{
		case 32:
			setHUDVisibility(true);
		case 95:
			FlxG.camera.shake(0.09, Conductor.crochet / 1000);
			camHUD.shake(0.09, Conductor.crochet / 1000);
		case 96:
			camGame.filtersEnabled = true;
			var sl = new ShaderFilter(new Scanline());
			camGame.setFilters([sl]);
			camHUD.setFilters([sl]);

			game.curPlayer = fever_pixel;
			game.curOpponent = yukichi_pixel;

			fever_pixel.visible = true;
			tea_pixel.visible = true;
			yukichi_pixel.visible = true;
			pixelDiner.visible = true;

			iconP1.swapCharacter('bf-pixeldemon');
			iconP2.swapCharacter('yukichi-pixel');

			game.changeStrums(true);
			game.usePixelAssets = true;

			getGlobalVar("bop").visible = false;
		case 159:
			FlxG.camera.shake(0.09, Conductor.crochet / 1000);
			camHUD.shake(0.09, Conductor.crochet / 1000);
		case 160:
			fever_pixel.visible = false;
			tea_pixel.visible = false;
			pixelDiner.visible = false;
			yukichi_pixel.visible = false;

			camGame.setFilters([]);
			camHUD.setFilters([]);

			game.changeStrums(false);
			game.usePixelAssets = false;

			game.curPlayer = boyfriend;
			game.curOpponent = dad;

			iconP1.swapCharacter('bf-demon');
			iconP2.swapCharacter('yukichi');

			getGlobalVar("bop").visible = true;
	}

	if (curBeat % 2 == 0 && game.camZooming && !fever_pixel.visible)
	{
		camHUD.zoom += 0.02;
	}

	tea_pixel.dance();
}

function setHUDVisibility(theBool:Bool)
{
	for (i in strumLineNotes)
		i.visible = theBool;

	for (i in [iconP1, iconP2, healthBar, healthBarBG, scoreTxt])
		i.visible = theBool;

	notes.visible = theBool;
}
