package shaders;

import flixel.system.FlxAssets.FlxShader;

/*
	MOSTLY A PORT OF THE SHADER FROM ATLAS-TRIANGLE BUT WITH SOME MINOR CHANGES TO IT
	https://github.com/loudoweb/AtlasTriangle/blob/master/atlasTriangle/shaders/HueSaturationShader.hx
 */
class ColorShader extends FlxShader
{
	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;

	private function set_hue(hue:Float)
	{
		this.hue = hue;
		data._hue.value = [this.hue];
		return this.hue;
	}

	private function set_saturation(sat:Float)
	{
		this.saturation = FlxMath.bound(sat, -1, 1);
		data._saturation.value = [this.saturation];
		return this.saturation;
	}

	@:glFragmentSource("
		#pragma header
		#define PI 3.1415926535897932384626433832795
		
		uniform float _hue;
		uniform float _saturation;
		void main(void) {
			gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			float alpha = gl_FragColor.a;
			
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

			gl_FragColor *= alpha;
		}
	")
	public function new()
	{
		super();
	}
}
