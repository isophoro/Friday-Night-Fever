package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;


#if windows
import Discord.DiscordClient;
#end

using StringTools;

class SelectingSongState extends MusicBeatState
{
	var selectors:Array<String> = FreeplayState.FreeplayStyle.getArrayInOrder();

	var selectorIcon:FlxTypedGroup<FlxSprite>;

	static var curSelected:Int = 0;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.antialiasing = true;
		add(bg);

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			Main.playFreakyMenu();
		}

		selectorIcon = new FlxTypedGroup<FlxSprite>();
		add(selectorIcon);

		for (i in 0...selectors.length)
		{
			var selecterIcons:FlxSprite = new FlxSprite(200 + (i * 500), -900);
			selecterIcons.frames = Paths.getSparrowAtlas('freeplayShit/selectors');
			selecterIcons.animation.addByPrefix('idle', selectors[i] + " songs", 0);
			selecterIcons.animation.addByPrefix('selected', selectors[i] + " selected", 0);
			selecterIcons.animation.play('idle');
			selecterIcons.scrollFactor.set();
			selecterIcons.updateHitbox();
			selecterIcons.antialiasing = true;
			selecterIcons.ID = i;
			selectorIcon.add(selecterIcons);

			selectorIcon.forEach(function(spr:FlxSprite){
				FlxTween.tween(spr, {y: 200}, 0.8, {ease: FlxEase.smoothStepInOut});
			});
		}

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay", null);
		#end

		changeItem();
	
		super.create();
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= selectorIcon.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = selectorIcon.length - 1;

		selectorIcon.forEach(function(spr:FlxSprite)
		{
			spr.animation.play(spr.ID == curSelected ? 'selected' : 'idle');

			spr.updateHitbox();
		});
	}

	var disableInput:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!disableInput)
		{
			#if mobile
			// As there's only two items in the menu, just make it so it swaps between the two.
			// Just implement the other system from the other menus if theres more than two catergories
			for (spr in selectorIcon)
			{
				if (FlxG.touches.getFirst() != null && FlxG.touches.getFirst().overlaps(spr))
				{
					if (spr.ID == curSelected)
					{
						selectItem();
					}
					else
					{
						curSelected = spr.ID;
						changeItem();
					}

					break;
				}
			}
			#end
	
			if (controls.LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}
	
			if (controls.RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
	
			if (controls.getBack())
			{
				FlxG.switchState(new MainMenuState());
			}
	
			if (controls.ACCEPT)
			{
				selectItem();
			}
		}
	}

	function goToState()
	{
		if(FreeplayState.currentStyle != selectors[curSelected])
			FreeplayState.curSelected = 0;
		
		FreeplayState.currentStyle = selectors[curSelected];

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		FlxG.switchState(new FreeplayState());
	}

	function selectItem()
	{
		disableInput = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
	
		selectorIcon.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {y: 2000}, 0.8, {ease: FlxEase.smoothStepInOut});
				if (FlxG.save.data.flashing)
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						goToState();
					});
				}
				else
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						goToState();
					});
				}
		});
	}
}