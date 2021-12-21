package shaders;

import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class BadNun
{
	public static var colorShader:SolidColorShader = new SolidColorShader();
	public static var bgColorShader:SolidColorShader = new SolidColorShader();
    public static var instance:PlayState;

    public static function beatHit(curBeat:Int)
    {
        if (curBeat == 1)
        {
            // Reset?
            colorShader = new SolidColorShader();
            bgColorShader = new SolidColorShader();  
            instance = PlayState.instance;
            instance.dad.shader = colorShader;
            instance.gf.shader = colorShader;
            instance.boyfriend.shader = colorShader;
            instance.church.shader = bgColorShader;
        }

        switch (curBeat)
        {
            case 96:
                PlayState.luaModchart.setVar("showOnlyStrums", true);
                colorShader.active.value[0] = true;
                bgColorShader.active.value[0] = true;
                bgColorShader.color.value = [0,0,0];

                instance.disableModCamera = true;
                instance.camZooming = false;
                FlxTween.tween(instance.camGame, {zoom: instance.camGame.zoom + 0.2}, 7, {onComplete: (twn) -> {
                    FlxTween.tween(instance.camGame, {zoom: instance.camGame.zoom - 0.2}, 3.5);
                }});

            case 124 | 126 | 128 | 156 | 158:
                for (i in [instance.dad, instance.boyfriend, instance.gf])
                {
                    FlxTween.cancelTweensOf(i);
                    i.alpha = 1;
                    if (curBeat != 128)
                        FlxTween.tween(i, {alpha:0}, Conductor.crochet / 1000);
                }

                if (curBeat == 128)
                {
                    instance.gf.visible = false;
                    FlxTween.tween(instance.dad, {x: instance.dad.x + 100}, 0.15, {ease:FlxEase.smootherStepInOut});
                    FlxTween.tween(instance.boyfriend, {x: instance.boyfriend.x - 100}, 0.15, {ease:FlxEase.smootherStepInOut});
                    instance.disableCamera = true;

                    instance.camFollow.setPosition(instance.gf.getGraphicMidpoint().x - 55, instance.gf.getGraphicMidpoint().y - 130);
                }

                bgColorShader.color.value = [1,1,1];
                colorShader.color.value = [0,0,0];

            case 125 | 127 | 157 | 159:
                bgColorShader.color.value = [0,0,0];
                colorShader.color.value = [1,1,1];

                for (i in [instance.dad, instance.boyfriend, instance.gf])
                {
                    FlxTween.cancelTweensOf(i);
                    i.alpha = 1;
                    if (curBeat != 159)
                        FlxTween.tween(i, {alpha:0}, Conductor.crochet / 1000);
                }
            case 160:
                instance.boyfriend.visible = false;
                instance.gf.visible = false;
                instance.camFollow.setPosition(instance.dad.getMidpoint().x + 120, instance.dad.getMidpoint().y - 50);
                FlxTween.tween(instance.camGame, {zoom: instance.camGame.zoom + 0.2}, 6);
            case 175:
                bgColorShader.color.value = [1,1,1];
                colorShader.color.value = [0,0,0];
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
                bgColorShader.color.value = [1,1,1];
                colorShader.color.value = [0,0,0];
                instance.dad.visible = true;
                instance.gf.visible = false;
                instance.camZooming = false;

                instance.boyfriend.visible = false;
                instance.dad.x += 850;
                instance.boyfriend.x -= 1060;

                instance.camFollow.setPosition(instance.dad.getMidpoint().x + 40, instance.dad.getMidpoint().y - 50);
                instance.camGame.focusOn(new FlxPoint(instance.camFollow.x, instance.camFollow.y));
                FlxTween.tween(instance.camGame, {zoom:0.8}, 1.15);
            case 207:
                instance.gf.x = 948;
				instance.gf.y = 722;
                instance.camZooming = false;
                instance.boyfriend.visible = true;
                FlxTween.tween(instance.camGame, {zoom:0.55}, 7);
            case 222:
                FlxTween.tween(instance.church, {alpha:0}, Conductor.crochet / 1000);
            case 224:
                FlxTween.tween(instance.church, {alpha:1}, Conductor.crochet / 1000);
                instance.disableCamera = false;
                instance.dad.x -= 850;
                instance.boyfriend.x += 1060;

                instance.defaultCamZoom = 0.5;
                instance.camGame.focusOn(new FlxPoint(instance.gf.getGraphicMidpoint().x - 55, instance.gf.getGraphicMidpoint().y - 130));
                colorShader.active.value[0] = false;
                bgColorShader.active.value[0] = false;
                instance.gf.visible = true;
                instance.dad.visible = true;
                instance.camZooming = true;
        }
    }
}

class SolidColorShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header
        
        uniform vec3 color;
        uniform bool active;

        void main()
        {
            vec4 _color = flixel_texture2D(bitmap, openfl_TextureCoordv);

            if (active)
            {
                _color = vec4(color.x * _color.a, color.y * _color.a, color.z * _color.a, _color.a); 
            }
            
            gl_FragColor = _color;
        }
    ')

    public function new()
    {
        super();
        color.value = [1,1,1];
        active.value = [false];
    }
}