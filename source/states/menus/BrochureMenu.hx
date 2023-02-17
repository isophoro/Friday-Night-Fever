package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;

using StringTools;

class BrochureMenu extends MusicBeatState
{
	var cscroll:FlxBackdrop;
	var fscroll:FlxBackdrop;

	var text:FlxText;
	var textBG:FlxSprite;

	var selectingFrenzy:Bool = true;
	var brochures:Array<FlxSprite> = [];
	var allowInput:Bool = false;

	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image("story/selecting/bg"));
		bg.antialiasing = true;
		add(bg);

		cscroll = new FlxBackdrop(Paths.image("story/selecting/cscroll"), X);
		cscroll.origin.set(0, 0);
		cscroll.scale.scale(1.55);
		cscroll.alpha = 0.000000009;
		fscroll = new FlxBackdrop(Paths.image("story/selecting/fscroll"), X);
		fscroll.origin.set(0, 0);
		fscroll.scale.scale(1.55);
		fscroll.alpha = 0.000000009;
		add(cscroll);
		add(fscroll);

		for (i in 0...2)
		{
			var brochure = new FlxSprite();
			brochure.frames = Paths.getSparrowAtlas("story/selecting/" + (i == 0 ? "f" : "c") + "brochure");
			for (i in ["confirm", "nselected", "selected", "open"])
			{
				brochure.animation.addByPrefix(i, i, 24, i.contains("selected"));
			}
			brochure.animation.play("nselected");
			brochure.scale.set(0.66, 0.66);
			brochure.updateHitbox();
			brochure.setPosition(FlxG.width * (i == 0 ? 0.3 : 0.6) - (brochure.width / 2), (FlxG.height * 0.5) - (brochure.height / 2));
			brochure.centerOffsets();
			brochure.animation.play("open");
			brochure.animation.finishCallback = (t) ->
			{
				if (t == "open")
				{
					allowInput = true;
					changeSelected(true);
				}
				else if (t == "confirm")
				{
					StoryMenuState.isFrenzy = selectingFrenzy;
					FlxG.switchState(new StoryMenuState());
				}
			}
			brochure.antialiasing = true;
			add(brochure);
			brochures.push(brochure);
			brochure.ID = i;
		}

		textBG = new FlxSprite(0, FlxG.height * 0.9).makeGraphic(10, 10, 0xFF000000);
		textBG.alpha = 0.6;
		textBG.origin.y = 0;
		add(textBG);

		text = new FlxText(0, FlxG.height * 0.9, 0, "", 24);
		text.setFormat("VCR OSD Mono", 22, 0xFFFFFFFF, CENTER);
		add(text);
	}

	function changeSelected(firstStart:Bool = false)
	{
		if (!firstStart)
			selectingFrenzy = !selectingFrenzy;

		for (i in brochures)
		{
			i.animation.play((selectingFrenzy && i.ID == 0 || !selectingFrenzy && i.ID == 1) ? "selected" : "nselected");
			if (i.ID == 1)
			{
				i.offset.set(-52.27, 128.93);
			}
		}

		fscroll.alpha = selectingFrenzy ? 0.2 : 0;
		cscroll.alpha = !selectingFrenzy ? 0.2 : 0;
		text.text = selectingFrenzy ? "Contains all of the brand new weeks featured in the Frenzy update" : "The original Friday Night Fever experience featuring Weeks 1 through 6";
		text.screenCenter(X);
		textBG.screenCenter(X);
		textBG.scale.set((text.width / textBG.width) * 1.03, text.height / textBG.height);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (allowInput && (controls.LEFT_P || controls.RIGHT_P))
			changeSelected();

		if (allowInput)
		{
			cscroll.x -= elapsed * 120;
			fscroll.x -= elapsed * 120;
			if (controls.ACCEPT)
			{
				allowInput = false;
				brochures[selectingFrenzy ? 0 : 1].animation.play("confirm");
			}
			else if (controls.BACK)
				FlxG.switchState(new MainMenuState());
		}
	}
}
