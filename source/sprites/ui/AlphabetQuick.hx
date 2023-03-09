package sprites.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

using StringTools;

/*
	THIS IS SUCH AN OLD REWRITE FROM AROUND SPRING 2021 SOME OF THIS CODE IS HORRIBLE!!
	PLEASE BEAR WITH ME I'LL REWRITE AGAIN SOMEDAY
	okay now its december 21st and now i can say that i wont rewrite this class BECAUSE I AM ILLITERATE!
 */
enum Alignment
{
	LEFT;
	RIGHT;
}

typedef Properties =
{
	var ?bold:Bool;
	var ?size:Float;
	var ?spacing:Int;
	var ?format:Alignment;
	var ?screenCenterX:Bool;
	var ?settingsItem:Bool;
	var ?menuItem:Bool;
	var ?fieldWidth:Int;
	var ?dontBoldNumbers:Bool;
}

class AlphabetQuick extends FlxSpriteGroup
{
	public var text:String = '';

	var lastText:String = '';

	public var isBold:Bool = true;
	public var character_array:Array<AlphabetCharacter> = [];

	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;
	public var isSettingItem:Bool = false;
	public var format:Alignment = LEFT;

	public var graphicsize:Float = 1;
	public var spacing:Int = 0;

	public var onComplete:AlphabetQuick->Void;
	public var screenCenterX:Bool = false;
	public var fieldWidth:Int = 0;
	public var boldNumbers:Bool = true;

	public function new(X:Float, Y:Float, Text:String, properties:Properties, ?_onComplete:AlphabetQuick->Void)
	{
		super(X, Y);
		text = Text;
		graphicsize = Math.isNaN(properties.size) ? 1 : properties.size;
		isBold = properties.bold;
		spacing = properties.spacing == 0 ? 7 : properties.spacing;
		if (properties.format == RIGHT)
			format = RIGHT;
		screenCenterX = properties.screenCenterX;
		isSettingItem = properties.settingsItem;
		isMenuItem = properties.menuItem;
		fieldWidth = properties.fieldWidth;
		boldNumbers = properties.dontBoldNumbers;

		if (_onComplete != null)
			onComplete = _onComplete;
	}

	public function genText()
	{
		if (text == '' || text == null)
			return;

		var splitArray:Array<String> = switch (format)
		{
			case LEFT:
				text.split('');
			case RIGHT:
				CoolUtil.reverseString(text).split(''); // we reverse the process B)
		}
		var nextLocation:Int = Std.int(x);
		var liner:Float = Std.int(y);
		for (i in 0...splitArray.length)
		{
			if (splitArray[i] == ' ')
			{
				switch (format)
				{
					case LEFT:
						nextLocation += calculateAverage(true) + spacing;
					case RIGHT:
						nextLocation -= calculateAverage(true) - spacing;
				}
			}
			else if (splitArray[i] == '\n')
			{
				nextLocation = Std.int(x);
				switch (format)
				{
					case LEFT:
						liner += calculateAverage() + (spacing - 1);
					case RIGHT:
						liner += calculateAverage() - (spacing - 1);
				}
			}
			else
			{
				var letter:AlphabetCharacter = new AlphabetCharacter(splitArray[i], Std.parseInt(splitArray[i]) != null && isBold ? !boldNumbers : isBold,
					liner);
				letter.ID = i;
				add(letter);
				character_array.push(letter);
				var offsetY:Int = letter.isSmallSymbol ? 10 : 0;
				if (graphicsize != 1)
					letter.setGraphicSize(Std.int(letter.width * graphicsize));
				letter.updateHitbox();
				if (letter.isBottomSymbol)
					offsetY = Std.int(calculateAverage() - letter.width);
				switch (format)
				{
					case LEFT:
						letter.setPosition(nextLocation, liner + offsetY);
						nextLocation += Std.int(letter.width) + spacing;
					case RIGHT:
						letter.setPosition(nextLocation - letter.width, liner + offsetY);
						nextLocation = Std.int(letter.x) - spacing;
				}
			}
		}

		if (!isBold)
		{
			// organizes characters
			var line:FlxSprite = new FlxSprite(x, y + calculateAverage()).makeGraphic(10, 10);
			line.scrollFactor.set();
			// add(line);

			for (i in character_array)
			{
				if (i.y + i.height < line.y + (30 * graphicsize))
				{
					i.y = line.y - i.height;
				}
			}
		}

		if (screenCenterX)
			x = FlxG.width / 2 - (width / 2);

		if (onComplete != null)
			onComplete(this);
	}

	public function calculateAverage(?width:Bool):Int
	{
		var total:Int = 0;
		for (i in character_array)
			total += Std.int(width ? i.width : i.height);

		return Std.int(total / character_array.length - 1);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (lastText != text)
		{
			lastText = text;
			for (i in members)
			{
				i.kill();
			}
			clear();
			genText();
		}

		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * (120 * (graphicsize / 1))) + (FlxG.height * 0.28), 0.16 * (60 / FlxG.stage.application.window.frameRate));
			// x = FlxMath.lerp(x, (targetY * (20 * (graphicsize / 1)) + (90 * (graphicsize / 1))), 0.16);
		}
		if (isSettingItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.5);
		}
	}
}

class AlphabetCharacter extends FlxSprite
{
	var symbols:Array<String> = [
		"|", "~", "#", "$", "%", "(", ")", "*", "+", "-", ":", ";", "<", "=", ">", "@", "[", "]", "^", "_", ".", "'", "!", "?", "☹", "/", "\\"
	];
	var convert:Map<String, String> = [
		// for grabbing xml animation name
		'.' => 'period',
		"'" => 'apostraphie',
		'?' => 'question mark',
		'!' => 'exclamation point',
		"☹" => 'angry faic',
		'$' => 'dollarsign ',
		'^' => 'up arrow',
		'♡' => 'heart',
		'♥' => 'heart',
		'/' => 'forward slash',
		'&' => 'amp',
		'#' => 'hashtag ',
		'>' => 'right arrow',
		'<' => 'left arrow',
		'↓' => 'down arrow'
	];
	var smallSymbols:Array<String> = ['☹', ':', '<', '>'];
	var bottomSymbols:Array<String> = ['.', ',', '_'];

	public var character:String = '';
	public var isSmallSymbol:Bool = false;
	public var isBottomSymbol:Bool = false;

	public function new(letter:String, bold:Bool, line_y:Float)
	{
		super();
		character = letter;
		var prefix:String = bold ? ' bold' : ' lowercase';
		if (Std.parseInt(letter) != null)
		{
			if (!bold)
			{
				prefix = '';
				frames = Paths.getSparrowAtlas('alphabet/numbers');
			}
			else
			{
				frames = Paths.getSparrowAtlas('alphabet/bold');
			}
		}
		else if (symbols.contains(letter) || convert.exists(letter))
		{
			if (smallSymbols.contains(letter))
				isSmallSymbol = true;
			if (bottomSymbols.contains(letter))
				isBottomSymbol = true;
			if (convert.exists(letter))
				letter = convert.get(letter);

			prefix = '';
			if (bold)
				frames = Paths.getSparrowAtlas('alphabet/symbols_white');
			else
				frames = Paths.getSparrowAtlas('alphabet/symbols');
		}
		else
		{
			if (bold)
			{
				letter = letter.toUpperCase();
				frames = Paths.getSparrowAtlas('alphabet/bold');
			}
			else if (letter.toLowerCase() != letter)
			{
				prefix = ' capital';
				frames = Paths.getSparrowAtlas('alphabet/capital');
			}
			else
			{
				frames = Paths.getSparrowAtlas('alphabet/lowercase');
			}
		}

		antialiasing = true;
		animation.addByPrefix(letter, letter + prefix, 24);
		animation.play(letter);
		updateHitbox();
	}
}
