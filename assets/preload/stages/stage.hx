import ("openfl.Assets");
import("openfl.display.BitmapData");

var w1city:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = 0.9;
	var bmp:BitmapData = Assets.getBitmapData(Paths.image('w1city'));

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

	var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(SONG.song == 'Down-Bad' ? 'stagecurtainsDOWNBAD' : 'stagecurtains'));
	stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
	stageCurtains.updateHitbox();
	stageCurtains.antialiasing = true;
	stageCurtains.scrollFactor.set(0.9, 0.9);
	add(stageCurtains);
}

function onBeatHit(curBeat:Int)
{
	if (curBeat % 2 == 0)
	{
		if (w1city.animation.curAnim.curFrame > 2)
			w1city.animation.curAnim.curFrame = 0;
		else
			w1city.animation.curAnim.curFrame++;
	}
}
