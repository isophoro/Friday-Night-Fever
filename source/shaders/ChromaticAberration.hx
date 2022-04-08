package shaders;

import flixel.system.FlxAssets.FlxShader;

class ChromaticAberration extends FlxShader
{
	public var redOffset(default, set):Float = 0;
	public var blueOffset(default, set):Float = 0;
	public var greenOffset(default, set):Float = 0;
	
	function set_redOffset(v:Float):Float
	{
		redOffset = v;
		data.rOffset.value = [v];
		return v;
	}

	function set_blueOffset(v:Float):Float
	{
		blueOffset = v;
		data.bOffset.value = [v];
		return v;
	}

	function set_greenOffset(v:Float):Float
	{
		greenOffset = v;
		data.gOffset.value = [v];
		return v;
	}

	@:glFragmentSource('
		#pragma header

		uniform float rOffset;
		uniform float gOffset;
		uniform float bOffset;

		void main()
		{
			vec4 col1 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(rOffset, 0.0));
			vec4 col2 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(gOffset, 0.0));
			vec4 col3 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(bOffset, 0.0));
			vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
			toUse.r = col1.r;
			toUse.g = col2.g;
			toUse.b = col3.b;

			gl_FragColor = toUse;
		}')
	public function new()
	{
		super();
	}
}
