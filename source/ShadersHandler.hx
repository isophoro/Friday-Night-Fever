package;

import openfl.filters.ShaderFilter;
import shaders.*;
import shaders.WiggleEffect.WiggleShader;

class ShadersHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	public static var scanline:ShaderFilter = new ShaderFilter(new Scanline());
	public static var grain:ShaderFilter = new ShaderFilter(new Grain());
	public static var wiggle:ShaderFilter = new ShaderFilter(new WiggleShader());
	public static var bloom:ShaderFilter = new ShaderFilter(new Bloom());

	public static function setChrome(chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}

	public static function setBloom(val:Float):Void
	{
		bloom.shader.data.actualScale.value = [val];
	}
}
