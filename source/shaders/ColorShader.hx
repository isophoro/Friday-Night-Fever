package shaders;


import flixel.system.FlxAssets.FlxShader;

/*
	MOSTLY A PORT OF THE SHADER FROM ATLAS-TRIANGLE BUT WITH SOME MINOR CHANGES TO IT
	https://github.com/loudoweb/AtlasTriangle/blob/master/atlasTriangle/shaders/HueSaturationShader.hx
 */
class ColorShader extends FlxShader
{
	public var hue:Float = 0;
	public var saturation:Float = 0;

	@:glFragmentSource("
		#pragma header
		#define PI 3.1415926535897932384626433832795
		
		uniform float _hue;
		uniform float _saturation;
		void main(void) {
			gl_FragColor = texture2D( bitmap, openfl_TextureCoordv );
			
			// hue
			float s = sin(_hue * PI), c = cos(_hue * PI);
			vec3 weights = (vec3(2.0 * c, -sqrt(3.0) * s - c, sqrt(3.0) * s - c) + 1.0) / 3.0;
			
			gl_FragColor.rgb = vec3(
				dot(gl_FragColor.rgb, weights.xyz),
				dot(gl_FragColor.rgb, weights.zxy),
				dot(gl_FragColor.rgb, weights.yzx)
			);
			
			// saturation
			float average = (gl_FragColor.r + gl_FragColor.g + gl_FragColor.b) / 3.0;
			
			if (_saturation > 0.0) {
				gl_FragColor.rgb += (average - gl_FragColor.rgb) * (1.0 - 1.0 / (1.001 - _saturation));
			} else {
				gl_FragColor.rgb += (average - gl_FragColor.rgb) * (-_saturation);
			}

			gl_FragColor *= openfl_Alphav;
		}
	")
	public function new()
	{
		super();
		//flixel.FlxG.stage.addEventListener(openfl.events.Event.ENTER_FRAME, onUpdate);
	}

	public function onUpdate(?_):Void
	{
		data._hue.value = [hue = FlxMath.bound(hue, -1, 1)];
		data._saturation.value = [saturation = FlxMath.bound(saturation, -1, 1)];
	}

	public function destroy()
	{
		//flixel.FlxG.stage.removeEventListener(openfl.events.Event.ENTER_FRAME, onUpdate);
	}
}
