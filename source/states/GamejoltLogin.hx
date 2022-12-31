package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.api.FlxGameJolt;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class GamejoltLogin extends MusicBeatState
{
	var usernameText:FlxText;
	var tokenText:FlxText;
	var coolUsernameBox:FlxSprite;
	var coolTokenBox:FlxSprite;
	var curText:Array<FlxText> = [];
	var curBox:Array<FlxSprite> = [];
	var curSelected:Int = 0;
	var maxCharLength:Int = 18; // idk if 18 is the max length... might be throwing here LMAO

	override function create()
	{
		super.create();

		// FlxG.sound.muteKeys = null;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		var alphabet:Alphabet = new Alphabet(0, 15, "Login with", true);
		alphabet.screenCenter(X);
		add(alphabet);

		var logo:FlxSprite = new FlxSprite(180, 80).loadGraphic(Paths.image('gamejolt'));
		logo.scale.set(0.75, 0.75);
		logo.screenCenter(X);
		logo.antialiasing = true;
		add(logo);

		coolUsernameBox = new FlxSprite(0, 240).makeGraphic(450, 110, FlxColor.BLACK);
		coolUsernameBox.screenCenter(X);
		coolUsernameBox.alpha = 0.65;
		add(coolUsernameBox);

		coolTokenBox = new FlxSprite(0, 360).makeGraphic(450, 110, FlxColor.BLACK);
		coolTokenBox.screenCenter(X);
		coolTokenBox.alpha = 0.65;
		add(coolTokenBox);

		var coolText:FlxText = new FlxText(0, 250, 0, "Type your Gamejolt username here!", 28);
		coolText.setFormat("VCR OSD Mono", 22);
		add(coolText);
		coolText.screenCenter(X);

		var coolerText:FlxText = new FlxText(0, 370, 0, "Type your Gamejolt token here!", 28);
		coolerText.setFormat("VCR OSD Mono", 22);
		add(coolerText);
		coolerText.screenCenter(X);

		var warningText:FlxText = new FlxText(0, coolTokenBox.x + coolTokenBox.height + 20, 0,
			"Your game token is NOT your password! Do not give any mod or game your gamejolt password.\n\nUse the arrow keys to switch selections\nPress ESCAPE to leave | Press ENTER to login.",
			28);
		warningText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		if (FlxGameJolt.username.toLowerCase() != 'no user')
			warningText.text += '\n\n\n\n\nCurrently logged in as ' + FlxGameJolt.username;
		warningText.screenCenter(X);

		var ugh:FlxSprite = new FlxSprite(0, warningText.y - 9).makeGraphic(1280, 800, FlxColor.BLACK);
		ugh.alpha = 0.55;
		add(ugh);
		add(warningText);

		usernameText = new FlxText(0, 290, 0, "", 28);
		usernameText.setFormat("VCR OSD Mono", 32);
		add(usernameText);
		usernameText.screenCenter(X);

		tokenText = new FlxText(0, 410, 0, "", 28);
		tokenText.setFormat("VCR OSD Mono", 32);
		add(tokenText);
		tokenText.screenCenter(X);

		FlxTween.tween(logo, {y: logo.y + 35}, 2.35, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
		curText = [usernameText, tokenText];
		curBox = [coolUsernameBox, coolTokenBox];
		changeSelection();
	}

	var coolTimer:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ANY)
		{
			if (!FlxG.keys.justPressed.BACKSPACE)
			{
				var keyPressed = FlxKey.toStringMap.get(FlxG.keys.firstJustPressed());

				if (!FlxG.keys.pressed.SHIFT)
					keyPressed = keyPressed.toLowerCase();

				updateText(curText[curSelected], keyPressed);
			}
			else
			{
				if (!FlxG.keys.pressed.CONTROL)
					removeText(curText[curSelected]);
			}
		}

		// use deltatime for removing shit so its cool on all framerates
		if (FlxG.keys.pressed.BACKSPACE)
		{
			coolTimer += elapsed;
			if (coolTimer >= 0.09)
			{
				removeText(curText[curSelected]);
				coolTimer = 0;
			}
		}
		else
		{
			coolTimer = 0;
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V)
		{
			var clipboardText:String = lime.system.Clipboard.text;
			// idc if you got some random ass symbols in there as long as u got that less than maxCharLength we cool
			if (clipboardText != null && clipboardText.length <= maxCharLength)
			{
				// checks if the copy and pasted text could be added on
				if (new String(curText[curSelected].text + clipboardText).length - 1 <= maxCharLength)
				{
					removeText(curText[curSelected]); // so the V isn't put in
					curText[curSelected].text += clipboardText;
					curText[curSelected].screenCenter(X);
				}
				else // if adding it on would make it reach max length
				{
					curText[curSelected].text = clipboardText;
					curText[curSelected].screenCenter(X);
				}
			}
			else
			{
				FlxG.log.warn("Clipboard is either null or its contents are too long to paste in");
			}
		}

		// no using controls.UP since that accepts W and S as inputs
		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);

		if (FlxG.keys.justPressed.ENTER)
		{
			openSubState(new GamejoltLoginSubstate(curText[0].text, curText[1].text));
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}
	}

	function changeSelection(change:Int = 0)
	{
		curBox[curSelected].alpha = 0.6;
		FlxTween.cancelTweensOf(curBox[curSelected]);
		curSelected += change;

		if (curSelected >= curText.length)
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = curText.length - 1;

		FlxTween.tween(curBox[curSelected], {alpha: 0.75}, 0.65, {type: PINGPONG});
	}

	function updateText(text:FlxText, keyPressed:String)
	{
		var idkRegex:String = Alphabet.AlphaCharacter.alphabet + '${Alphabet.AlphaCharacter.numbers}-_'; // so we pull off this bs

		if (text.text.length <= maxCharLength) // ugly ass if statement text.text.text.text shit
		{
			if (idkRegex.contains(keyPressed.toLowerCase()))
			{
				text.text += keyPressed;
				// trace(text.text);
			}
			else if (exceptions.exists(keyPressed.toUpperCase()))
			{
				// support for underscores when holding shift
				if (keyPressed.toUpperCase() == 'MINUS')
				{
					text.text += FlxG.keys.pressed.SHIFT ? '_' : exceptions.get(keyPressed.toUpperCase());
				}
				else
				{
					text.text += exceptions.get(keyPressed.toUpperCase());
				}

				// trace(text.text);
			}
		}
		text.screenCenter(X);
	}

	function removeText(text:FlxText)
	{
		if (text.text.length > 0)
		{
			// this sucks
			text.text = text.text.substring(0, text.text.length - 1);
			// trace(text.text);
		}

		text.screenCenter(X);
	}

	var exceptions:Map<String, String> = [
		'MINUS' => '-', // underscores also count here
		'ONE' => '1',
		'TWO' => '2',
		'THREE' => '3',
		'FOUR' => '4',
		'FIVE' => '5',
		'SIX' => '6',
		'SEVEN' => '7',
		'EIGHT' => '8',
		'NINE' => '9',
		'ZERO' => '0'
	];
}
