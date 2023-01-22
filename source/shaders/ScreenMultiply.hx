package shaders;

import flixel.system.FlxAssets.FlxShader;

class ScreenMultiply extends FlxShader
{
	public var value(default, set):Float = 1;

	@:glFragmentSource("
        #pragma header

        const vec2 res = vec2(1280, 720);
        uniform float screens;

        void main()
        {
            vec2 fragCoord = openfl_TextureCoordv * res;
            vec2 uv = fragCoord.xy / res.xy;
            vec4 col = flixel_texture2D(bitmap,uv);

            float u = mod(uv.x * screens, 1.0);
            float v = mod(uv.y * screens, 1.0);

            gl_FragColor = flixel_texture2D(bitmap,vec2(u,v));
        }
    ")
	public function new()
	{
		super();
	}

	function set_value(_new:Float):Float
	{
		value = _new;
		data.screens.value = [_new];
		return _new;
	}
}
