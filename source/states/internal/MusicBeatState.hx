package states.internal;

import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import haxe.rtti.Meta;
import meta.Conductor.BPMChangeEvent;
import openfl.Lib;
import openfl.system.System;
import scripting.HScriptGroup;
import scripting.HaxeScript;

class MusicBeatState extends FlxUIState
{
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	private var controls(get, never):Controls;
	private var disableBeathit:Bool = false;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	private var _clearMemory:Bool = false;

	var scripts:HScriptGroup = new HScriptGroup();

	public function new(clearMemory:Bool = false)
	{
		super();
		_clearMemory = clearMemory;
	}

	override function create()
	{
		var metadata = Meta.getType(Type.getClass(FlxG.state));
		if (metadata.presence != null)
			FlxG.stage.window.title = "Friday Night Fever: Frenzy - " + metadata.presence[0];
		else
			FlxG.stage.window.title = "Friday Night Fever: Frenzy";

		if (_clearMemory)
			Main.clearMemory(false);

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(ClientPrefs.fpsCap);

		super.create();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0 && !disableBeathit)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	inline public function fancyOpenURL(schmancy:String)
	{
		#if linux
		return Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		return FlxG.openURL(schmancy);
		#end
	}

	override function onFocus()
	{
		System.gc();
		super.onFocus();
	}

	override function onFocusLost()
	{
		System.gc();
		super.onFocusLost();
	}

	public function addScript(script:HaxeScript)
	{
		scripts.add(script);
	}
}
