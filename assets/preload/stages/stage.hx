var w1city:FlxSprite;
var leftAd:FlxSprite;
var rightAd:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = 0.9;
	var bg:FlxSprite = new FlxSprite(-720, -450).loadGraphic(Paths.image('w1city'), true, 2560, 1400);
	bg.animation.add('idle', [3], 0);
	bg.animation.play('idle');
	bg.scale.set(0.3, 0.3);
	bg.antialiasing = true;
	bg.scrollFactor.set(0.9, 0.9);
	add(bg);

	w1city = new FlxSprite(bg.x, bg.y).loadGraphic(Paths.image('w1city'), true, 2560, 1400);
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

	var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image(game.curSong == 'Down-Bad' ? 'stagecurtainsDOWNBAD' : 'stagecurtains'));
	stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
	stageCurtains.updateHitbox();
	stageCurtains.antialiasing = true;
	stageCurtains.scrollFactor.set(0.9, 0.9);
	add(stageCurtains);

	var dog:FlxSprite = new FlxSprite(stageCurtains.x + (880 * 0.9), stageCurtains.y + (745 * 0.9));
	dog.frames = Paths.getSparrowAtlas("week1/eepydog");
	dog.animation.addByPrefix("idle", "r", 24);
	dog.animation.play("idle");
	dog.scrollFactor.set(0.9, 0.9);
	dog.antialiasing = true;
	add(dog);

	leftAd = new FlxSprite(stageCurtains.x + (244 * 0.9), stageCurtains.y + (428 * 0.9));
	leftAd.frames = Paths.getSparrowAtlas("week1/ads");
	leftAd.animation.addByPrefix("a", "leftAds0", 0);
	leftAd.animation.play("a");
	leftAd.setGraphicSize(Std.int(leftAd.width * 0.9));
	leftAd.updateHitbox();
	leftAd.scrollFactor.set(0.9, 0.9);
	leftAd.antialiasing = true;
	add(leftAd);

	rightAd = new FlxSprite(stageCurtains.x + (1585 * 0.9), stageCurtains.y + (429 * 0.9));
	rightAd.frames = Paths.getSparrowAtlas("week1/ads");
	rightAd.animation.addByPrefix("a", "rightAds0", 0);
	rightAd.animation.play("a");
	rightAd.origin.set(0, 0);
	rightAd.setGraphicSize(Std.int(rightAd.width * 0.86));
	rightAd.updateHitbox();
	rightAd.scrollFactor.set(0.9, 0.9);
	rightAd.antialiasing = true;
	add(rightAd);
}

function onCreatePost()
{
	for (i in [dad, boyfriend, gf])
		i.x -= 170;
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

	if (curBeat % 8 == 0)
	{
		for (i in [rightAd, leftAd])
		{
			if (i.animation.curAnim.curFrame > 2)
				i.animation.curAnim.curFrame = 0;
			else
				i.animation.curAnim.curFrame++;
		}
	}
}
