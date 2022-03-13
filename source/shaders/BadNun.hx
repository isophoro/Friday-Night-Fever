package shaders;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import sprites.CharacterTrail;

class BadNun
{
	public static var failed:Bool = false;
	public static var colorShader:SolidColorShader = new SolidColorShader();
	public static var bgColorShader:SolidColorShader = new SolidColorShader();
	public static var instance:PlayState;
	public static var trail:CharacterTrail;
	public static var movieBars:FlxTypedGroup<FlxSprite>;
	public static var darken:FlxSprite;
	public static var translate:Bool = false;

	public static function beatHit(curBeat:Int)
	{
		if (curBeat == 1)
		{
			// Reset?
			try
			{
				colorShader = new SolidColorShader();
				bgColorShader = new SolidColorShader();
			}
			catch (e)
			{
				Application.current.window.alert('Failed compiling shaders:\n$e', "Friday Night Fever");
				failed = true;
			}

			if (failed)
				return;

			instance = PlayState.instance;
			instance.dad.shader = colorShader;
			instance.gf.shader = colorShader;
			instance.boyfriend.shader = colorShader;
			instance.church.shader = bgColorShader;
			trail = new CharacterTrail(instance.dad, null, 4, 24, 0.3, 0.069);
			movieBars = new FlxTypedGroup<FlxSprite>();
			movieBars.cameras = [instance.camGame];
			darken = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			darken.scrollFactor.set();
			darken.alpha = 0;
		}

		if (failed)
			return;

		switch (curBeat)
		{
			case 96:
				PlayState.luaModchart.setVar("showOnlyStrums", true);
				enableShader(true);
				bgColorShader.color.value = [0, 0, 0];

				instance.purpleOverlay.visible = false;
				PlayState.setModCamera(true);
				instance.camZooming = false;
				FlxTween.tween(instance.camGame, {zoom: instance.camGame.zoom + 0.2}, 7, {
					onComplete: (twn) ->
					{
						FlxTween.tween(instance.camGame, {zoom: instance.camGame.zoom - 0.2}, 3.5);
					}
				});

			case 124 | 126 | 128 | 156 | 158:
				for (i in [instance.dad, instance.boyfriend, instance.gf])
				{
					FlxTween.cancelTweensOf(i);
					i.alpha = 1;
					if (curBeat != 128)
						FlxTween.tween(i, {alpha: 0}, Conductor.crochet / 1000);
				}

				if (curBeat == 128)
				{
					instance.gf.visible = false;
					FlxTween.tween(instance.dad, {x: instance.dad.x + 100}, 0.15, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(instance.boyfriend, {x: instance.boyfriend.x - 100}, 0.15, {ease: FlxEase.smootherStepInOut});
					instance.disableCamera = true;

					instance.camFollow.setPosition(instance.gf.getGraphicMidpoint().x - 55, instance.gf.getGraphicMidpoint().y - 130);
				}

				bgColorShader.color.value = [1, 1, 1];
				colorShader.color.value = [0, 0, 0];

			case 125 | 127 | 157 | 159:
				bgColorShader.color.value = [0, 0, 0];
				colorShader.color.value = [1, 1, 1];

				for (i in [instance.dad, instance.boyfriend, instance.gf])
				{
					FlxTween.cancelTweensOf(i);
					i.alpha = 1;
					if (curBeat != 159)
						FlxTween.tween(i, {alpha: 0}, Conductor.crochet / 1000);
				}
			case 160:
				instance.boyfriend.visible = false;
				instance.gf.visible = false;
				instance.camFollow.setPosition(instance.dad.getMidpoint().x + 120, instance.dad.getMidpoint().y - 50);
				FlxTween.tween(instance.camGame, {zoom: instance.camGame.zoom + 0.2}, 6);
				FlxTween.tween(instance.dad, {angle: 10}, 7);
			case 175:
				FlxTween.cancelTweensOf(instance.dad);
				instance.dad.angle = 0;
				bgColorShader.color.value = [1, 1, 1];
				colorShader.color.value = [0, 0, 0];
				instance.boyfriend.visible = true;
				instance.gf.visible = true;
				instance.dad.visible = false;
				instance.defaultCamZoom = 0.85;
				instance.camFollow.setPosition(instance.gf.getGraphicMidpoint().x + 100, instance.gf.getGraphicMidpoint().y + 245);
				instance.gf.y += 130;
			case 190:
				instance.camZooming = false;
				instance.camFollow.x -= 50;
				FlxTween.tween(instance.camGame, {zoom: 6.3}, 0.465);
			case 192:
				FlxTween.cancelTweensOf(instance.camGame);
				bgColorShader.color.value = [1, 1, 1];
				colorShader.color.value = [0, 0, 0];
				instance.dad.visible = true;
				instance.gf.visible = false;
				instance.camZooming = false;

				instance.boyfriend.visible = false;
				instance.dad.x += 850;
				instance.boyfriend.x -= 1060;

				focusCamera(instance.dad.getMidpoint().x + 40, instance.dad.getMidpoint().y - 50);
				FlxTween.tween(instance.camGame, {zoom: 0.8}, 1.15);
			case 207:
				instance.gf.x = 948;
				instance.gf.y = 722;
				instance.camZooming = false;
				instance.boyfriend.visible = true;
				FlxTween.tween(instance.camGame, {zoom: 0.55}, 7);
			case 222:
				FlxTween.tween(instance.church, {alpha: 0}, Conductor.crochet / 1000);
			case 224 | 448:
				FlxTween.tween(instance.church, {alpha: 1}, Conductor.crochet / 1000);
				instance.disableCamera = false;
				PlayState.setModCamera(false);
				if (curBeat == 224)
				{
					instance.dad.x -= 850;
					instance.boyfriend.x += 1060;
					instance.add(darken);
					darken.scale.set(6, 6); // just to be safe?
				}
				else
				{
					instance.dad.alpha = 1;
					instance.boyfriend.alpha = 1;
					instance.boyfriend.x = 1828;
					instance.boyfriend.y = 1148;
					instance.dad.y = 620;
					instance.dad.x = 388;
				}

				instance.purpleOverlay.visible = true;
				instance.purpleOverlay.alpha = 0.33; // used for the last segment
				instance.defaultCamZoom = 0.5;
				instance.camGame.focusOn(new FlxPoint(instance.gf.getGraphicMidpoint().x - 55, instance.gf.getGraphicMidpoint().y - 130));
				enableShader(false);
				instance.gf.visible = true;
				instance.dad.visible = true;
				instance.camZooming = true;
			case 289:
				FlxTween.tween(darken, {alpha: 1}, 9, {
					onComplete: (t) ->
					{
						instance.camGame.alpha = 0;
						focusCamera(instance.dad.getMidpoint().x + 40, instance.dad.getMidpoint().y - 50);
					}
				});
				FlxTween.tween(instance.purpleOverlay, {alpha: 0}, 8);
			case 320:
				instance.remove(darken);
				FlxTween.tween(instance.camGame, {alpha: 1}, 0.09);
				instance.camGame.shake(0.0115, 0.9);
				if (instance.health > 1.1)
					FlxTween.tween(instance, {health: 1}, 0.9);
				instance.camGame.zoom = 0.7;

				enableShader(true);
				bgColorShader.color.value = [0, 0, 0];
				colorShader.color.value = [1, 1, 1];
			case 344:
				instance.camZooming = false;
				PlayState.setModCamera(true);

				FlxTween.tween(instance.camGame, {zoom: instance.camGame.zoom + 0.1}, 2);
			case 348:
				translate = true;
				PlayState.instance.scoreTxt.font = Paths.font("unifont.otf");
				PlayState.instance.scoreTxt.size = 18;

				instance.camZooming = true;

				bgColorShader.color.value = [1, 1, 1];
				colorShader.color.value = [0, 0, 0];
				instance.dad.visible = false;
				instance.gf.visible = false;
				instance.boyfriend.visible = false;

				if (instance.health > 1)
					instance.health = 1;

			case 352:
				instance.dad.visible = true;

				instance.remove(instance.dad);
				instance.add(trail);
				instance.add(instance.dad);
				instance.camZooming = false;
				instance.disableCamera = true;

				instance.dad.x += 500;
				focusCamera(instance.dad.x + 120, instance.dad.y + 90);
				instance.camGame.zoom = 1;
				FlxTween.tween(instance.camFollow, {x: instance.dad.x + 120 + instance.dad.width, y: instance.dad.y + 90 + (instance.dad.height / 4)}, 9.5);
			case 368:
				FlxTween.cancelTweensOf(instance.camFollow);
				instance.remove(trail);
				instance.dad.x -= 500;
				instance.dad.visible = false;
				instance.boyfriend.visible = true;
				instance.boyfriend.x += 500;
				focusCamera(instance.boyfriend.x + 120, instance.boyfriend.y + 150);
				FlxTween.tween(instance.camFollow,
					{x: instance.boyfriend.x + instance.boyfriend.width - 50, y: instance.boyfriend.y + 90 + (instance.boyfriend.height / 4)}, 9.5);
			case 384:
				FlxTween.cancelTweensOf(instance.camFollow);
				instance.camGame.zoom = 1.1;
				focusCamera(instance.dad.x + 350, instance.dad.y + 120);
				instance.add(movieBars);
				instance.dad.visible = true;
				instance.boyfriend.visible = false;
				instance.boyfriend.x -= 500;

				var m1:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 145, FlxColor.BLACK);
				m1.scrollFactor.set();
				movieBars.add(m1);

				var m2:FlxSprite = m1.clone();
				m2.setPosition(0, FlxG.height - m2.pixels.height);
				m2.scrollFactor.set();
				movieBars.add(m2);
				m1.y -= 145;
				m2.y += 145;
				FlxTween.tween(m1, {y: m1.y + 145}, 0.35);
				FlxTween.tween(m2, {y: m2.y - 145}, 0.35);
				FlxTween.tween(instance.dad, {x: instance.dad.x + 140}, 7);
			case 400:
				FlxTween.cancelTweensOf(instance.dad);
				instance.dad.visible = false;
				instance.dad.x -= 140;
				instance.boyfriend.visible = true;

				focusCamera(instance.boyfriend.x + 350, instance.boyfriend.y + 120);
				FlxTween.tween(instance.boyfriend, {x: instance.boyfriend.x - 135}, 7.5);
			case 416:
				instance.dad.alpha = 0.45;
				instance.dad.visible = true;
				instance.dad.setPosition(instance.boyfriend.x + 600, instance.boyfriend.x - 450);
			case 432:
				instance.dad.visible = false;
			case 446:
				FlxTween.tween(instance.church, {alpha: 0}, 0.4);
				FlxTween.tween(instance.boyfriend, {alpha: 0}, 0.4, {
					onComplete: (t) ->
					{
						PlayState.instance.scoreTxt.font = Paths.font("vcr.ttf");
						PlayState.instance.scoreTxt.size = 18;
						translate = false;
					}
				});
				instance.remove(movieBars);
		}
	}

	public static function focusCamera(x:Float, y:Float)
	{
		instance.camFollow.setPosition(x, y);
		instance.camGame.focusOn(new FlxPoint(instance.camFollow.x, instance.camFollow.y));
	}

	public static function enableShader(bool:Bool)
	{
		bgColorShader.shaderActive.value[0] = bool;
		colorShader.shaderActive.value[0] = bool;
	}
}

class SolidColorShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header
        
        uniform vec3 color;
        uniform bool shaderActive; // REMINDER TO NOT BE DUMB AND NAME THE VARIABLE ACTIVE, THATS ALREADY RESERVED!!!

        void main()
        {
            vec4 _color = flixel_texture2D(bitmap, openfl_TextureCoordv);

            if (shaderActive)
            {
                _color = vec4(color.x * _color.a, color.y * _color.a, color.z * _color.a, _color.a); 
            }
            
            gl_FragColor = _color;
        }
    ')
	
	public function new()
	{
		super();
		color.value = [1, 1, 1];
		shaderActive.value = [false];
	}
}
