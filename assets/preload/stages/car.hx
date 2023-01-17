var seats:FlxSprite;
var arm:Character;
var wheel:FlxSprite;

function onCreate()
{
	game.defaultCamZoom = 0.93;
	var sky:FlxSprite = new FlxSprite(-660, -70).loadGraphic(Paths.image("roboStage/sky"));
	sky.antialiasing = true;
	sky.scale.set(0.8, 0.8);
	add(sky);

	var buildings:FlxSprite = new FlxSprite(-350, -57);
	buildings.frames = Paths.getSparrowAtlas("rolldog/roll_dog_buildings");
	buildings.animation.addByPrefix("loop", "buildings", 24, true);
	buildings.animation.play("loop");
	buildings.antialiasing = true;
	add(buildings);

	var bg:FlxSprite = new FlxSprite(-252, -117).loadGraphic(Paths.image("rolldog/dog bg"));
	bg.antialiasing = true;
	add(bg);

	seats = new FlxSprite().loadGraphic(Paths.image("rolldog/bg chairs"));
	seats.antialiasing = true;
	add(seats);

	arm = new Character(590, 270, "fevers-fucking-arm", false);
	setGlobalVar("arm", arm);

	wheel = new FlxSprite(815, 335);
	wheel.frames = Paths.getSparrowAtlas("rolldog/wheel crazy");
	wheel.animation.addByPrefix("loop", "wheel", 24, true);
	wheel.animation.play("loop");
	wheel.antialiasing = true;
	wheel.visible = false;
	setGlobalVar("wheel", wheel);

	forceComboPos = new FlxPoint(FlxG.width * 0.15, 140);
}

function onCreatePost()
{
	dad.y = 320;
	boyfriend.setPosition(660, -85);
	remove(gf);
	add(gf, getIndexOfMember(seats));
	gf.x = 440;
	gf.y += 10;

	game.disableCamera = true;
	game.camFollow.setPosition(gf.getGraphicMidpoint().x + 25, gf.getGraphicMidpoint().y);
	add(arm);
	add(wheel);
	remove(boyfriend);
	add(boyfriend, getIndexOfMember(arm));
	arm.playAnim("wheel");
}

function onOpponentNoteHit(note:Note)
{
	if (note.type == 2)
	{
		arm.playAnim("sing" + dataSuffix[note.noteData], true);
	}
}

function onBeatHit(curBeat:Int)
{
	if (arm.animation.curAnim.name.charAt(0) != "w" && arm.animation.finished)
		arm.playAnim("idle");

	if (game.curPlayer != boyfriend && game.curOpponent != boyfriend)
		boyfriend.dance();

	if (game.curPlayer != dad && game.curOpponent != dad)
		dad.dance();
}

function onUpdate(elapsed:Float)
{
	if (arm.animation.curAnim.name == "idle" && boyfriend.animation.curAnim.name == "idle")
	{
		if (arm.animation.curAnim.curFrame != boyfriend.animation.curAnim.curFrame)
			arm.animation.curAnim.curFrame = boyfriend.animation.curAnim.curFrame;
	}
}
