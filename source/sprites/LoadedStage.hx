package sprites;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

typedef Stage =
{
	?zoom:Null<Float>,
	?background:Array<FlxSprite>,
	?foreground:Array<FlxSprite>,
	?positioning:Map<String, Array<Float>>,
	?characterScroll:Null<Float>,
	?color:Null<FlxColor>,
	?onBeatHit:Int->Void,
	?onSwitch:Bool->Void,
	?transition:Null<FlxColor>
}

enum LoadedEvent
{
	SwitchStage(beat:Int, stage:String);
}

class LoadedStage extends FlxTypedGroup<FlxSprite>
{
	private static final baseStage:Stage = {
		zoom: 1,
		background: [],
		foreground: [],
		positioning: ["boyfriend" => [1085.2, 482.3], "dad" => [-254.7, 315.3]],
		characterScroll: 0.9,
		color: FlxColor.WHITE,
		onBeatHit: (curBeat:Int) -> {},
		onSwitch: (switchOut:Bool) -> {},
		transition: FlxColor.WHITE
	}

	public var stages:Map<String, Stage> = [];
	public var curStage:String = 'default';
	public var foreground:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	private var instance:PlayState;
	private var events:Array<LoadedEvent> = [
		SwitchStage(32, "zardy"),
		SwitchStage(96, "tricky"),
		SwitchStage(128, "whitty"),
		SwitchStage(144, "boardwalk"),
		SwitchStage(160, "default"),
		SwitchStage(224, "peakek"),
		SwitchStage(256, "diner"),
		SwitchStage(288, "boardwalk"),
		SwitchStage(320, "pixel"),
		SwitchStage(336, "default"),
		SwitchStage(400, "church"),
		SwitchStage(432, "diner"),
		SwitchStage(463, "tricky"),
		SwitchStage(496, "matt"),
		SwitchStage(560, "peakek"),
		SwitchStage(592, "default")
	];

	public function new()
	{
		super();
		instance = PlayState.instance;

		createStages();
	}

	public function switchStage(stageName:String)
	{
		if (stages[stageName] == null)
			return;

		if (instance.health > 1)
			instance.health = 1;

		var stage = stages[stageName];

		addSprites(stage.background, this);
		addSprites(stage.foreground, foreground);

		for (i in ["dad", "boyfriend"])
		{
			var char:Character = cast Reflect.field(instance, i);
			char.setPosition(stage.positioning[i][0], stage.positioning[i][1]);
			char.scrollFactor.set(stage.characterScroll, stage.characterScroll);
			char.color = stage.color;
		}

		instance.defaultCamZoom = stage.zoom;
		if (stages[curStage].zoom != stage.zoom)
		{
			instance.camGame.zoom = stage.zoom + ((stages[curStage].zoom - stage.zoom) / 2);
		}

		instance.camGame.flash(stage.transition, 0.45);
		instance.camZooming = true;
		instance.disableCamera = false;

		curStage = stageName;
		instance.moveCamera(!PlayState.SONG.notes[Std.int(instance.curStep / 16)].mustHitSection);
	}

	private function addSprites(sprites:Array<FlxSprite>, grp:FlxTypedGroup<FlxSprite>)
	{
		grp.clear();

		for (spr in sprites)
		{
			grp.add(spr);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Catch up if there's any cringe lag spikes
		if (events[0] != null && events[0].getParameters()[0] <= instance.curBeat)
		{
			beatHit(instance.curBeat);
		}
	}

	public function addStage(name:String, stage:Stage)
	{
		// null prevention stuff
		for (i in Reflect.fields(baseStage))
		{
			var stageObj = Reflect.field(stage, i);
			if (stageObj == null)
			{
				Reflect.setField(stage, i, Reflect.field(baseStage, i));
			}
			else if (stageObj is haxe.Constraints.IMap)
			{
				// If the field is a map and contains any null fields, fill them in
				var map = (cast stageObj : Map<String, Dynamic>);
				for (k => v in (cast Reflect.field(baseStage, i) : Map<String, Dynamic>))
				{
					if (!map.exists(k))
					{
						map[k] = v;
					}
				}
			}
		}

		if (PlayState.instance.boyfriend.curCharacter == "bf" && name != 'pixel')
		{
			stage.positioning["boyfriend"][1] -= 50;
		}

		stages[name] = stage;
	}

	public function beatHit(curBeat:Int)
	{
		stages[curStage].onBeatHit(curBeat);

		while (events[0] != null && events[0].getParameters()[0] <= curBeat)
		{
			switch (events[0])
			{
				case SwitchStage(beat, stage):
					switchStage(stage);
			}

			events.shift();
		}
	}

	private function createStages()
	{
		addStage("default", createDefault());
		addStage("zardy", createZardy());
		addStage("whitty", createWhitty());
		addStage("tricky", createTricky());
		addStage("matt", createMatt());
		addStage("peakek", createPeakek());
		addStage("diner", createDiner());
		addStage("church", createChurch());
		addStage("boardwalk", createBoardwalk());
	}

	private function createDefault():Stage
	{
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

		return {
			background: [sky, city, rail, bg, wires],
			foreground: [overlay],
			positioning: ["boyfriend" => [880, 482.3], "dad" => [160, 315.3]],
			zoom: 0.4,
			transition: FlxColor.BLACK
		};
	}

	private function createZardy():Stage
	{
		var bg:FlxSprite = new FlxSprite(-200.6, -200).loadGraphic(Paths.image('roboStage/zardy_bg'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.75, 0.3);

		var town:FlxSprite = new FlxSprite(-224.35, -198.9).loadGraphic(Paths.image('roboStage/zardy_fevertown'));
		town.antialiasing = true;
		town.scrollFactor.set(0.6, 1);

		var foreground:FlxSprite = new FlxSprite(-203.35, -193.85).loadGraphic(Paths.image('roboStage/zardy_foreground'));
		foreground.antialiasing = true;
		foreground.scrollFactor.set(1, 1);

		return {
			background: [bg, town, foreground],
			positioning: ["boyfriend" => [1001.3, 325.8], "dad" => [-1.7245, 160.8]],
			zoom: 0.715
		};
	}

	private function createWhitty():Stage
	{
		var bg:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/alleyway'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.scale.set(1.25, 1.25);

		return {
			background: [bg],
			zoom: 0.55
		};
	}

	private function createTricky():Stage
	{
		var bg:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/rockymountains'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.scale.set(1.25, 1.25);

		var sky:FlxSprite = new FlxSprite(-728, -230).loadGraphic(Paths.image('roboStage/rockysky'));
		sky.antialiasing = true;
		sky.scrollFactor.set(0.7, 0.7);
		sky.scale.set(1.25, 1.25);

		return {
			background: [sky, bg],
			positioning: ["boyfriend" => [775, 482.3], "dad" => [-160, 315.3]],
			zoom: 0.55,
			color: 0xFFFFE6D8
		};
	}

	private function createMatt():Stage
	{
		var bg:FlxSprite = new FlxSprite(-200, -230).loadGraphic(Paths.image('roboStage/matt_bg'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.4, 0.4);
		bg.scale.set(1.05, 1.05);

		var fg:FlxSprite = new FlxSprite(bg.x, bg.y).loadGraphic(Paths.image('roboStage/matt_foreground'));
		fg.antialiasing = true;
		fg.scrollFactor.set(0.9, 0.9);
		fg.scale.set(1.05, 1.05);

		var crowd:FlxSprite = new FlxSprite(bg.x - 55, bg.y - 15);
		crowd.frames = Paths.getSparrowAtlas('roboStage/matt_crowd');
		crowd.animation.addByPrefix('bop', 'robo crowd hehe', 24, false);
		crowd.antialiasing = true;
		crowd.scrollFactor.set(0.85, 0.85);

		var spotlight:FlxSprite = new FlxSprite(bg.x, bg.y).loadGraphic(Paths.image('roboStage/matt_spotlight'));
		spotlight.antialiasing = true;
		spotlight.scrollFactor.set(0.73, 0.73);

		return {
			background: [bg, crowd, fg],
			foreground: [spotlight],
			positioning: ["boyfriend" => [1185.2, 332.3], "dad" => [135.7, 165.3]],
			zoom: 0.73
		};
	}

	private function createPeakek():Stage
	{
		var bmp = openfl.Assets.getBitmapData(Paths.image('w1city'));

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

		var stageFront:FlxSprite = new FlxSprite(-730, 530).loadGraphic(Paths.image('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(0.9, 0.9);

		return {
			background: [bg, w1city, stageFront, stageCurtains],
			positioning: ["boyfriend" => [1070, 360], "gf" => [400, 85], "dad" => [-50, 200]],
			zoom: 0.757,
			onBeatHit: (curBeat) ->
			{
				if (curBeat % 4 == 0)
				{
					if (w1city.animation.curAnim.curFrame > 2)
						w1city.animation.curAnim.curFrame = 0;
					else
						w1city.animation.curAnim.curFrame++;
				}
			}
		};
	}

	private function createDiner():Stage
	{
		var w5bg:FlxSprite = new FlxSprite(-820, -400).loadGraphic(Paths.image('yukichi', 'week5'));
		w5bg.antialiasing = true;
		w5bg.scrollFactor.set(0.9, 0.9);

		return {
			background: [w5bg],
			zoom: 0.55
		};
	}

	private function createChurch():Stage
	{
		var church = new FlxSprite(-948, -779).loadGraphic(Paths.image('bg_taki'));
		church.antialiasing = true;

		return {
			background: [church],
			zoom: 0.55
		};
	}

	private function createBoardwalk():Stage
	{
		var cherry:Character = new Character(360, 70, "gf-cherry", false);
		cherry.scrollFactor.set(0.95, 0.95);

		var week4Assets:Array<FlxSprite> = [];
		for (i in ["sky", "city", "water", "boardwalk"])
		{
			var spr = new FlxSprite(-300, -300).loadGraphic(Paths.image(i, 'week4'));
			spr.scale.set(1.4, 1.4);
			spr.antialiasing = true;
			week4Assets.push(spr);
		}

		return {
			background: week4Assets.concat([cherry]),
			positioning: ["boyfriend" => [850, 395], "dad" => [180, 245]],
			zoom: 0.9,
			onBeatHit: (curBeat) ->
			{
				cherry.dance();
			}
		};
	}
}
