package;

import shaders.WiggleEffect.WiggleShader;
import shaders.*;
import openfl.filters.ShaderFilter;

class ShadersHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	public static var scanline:ShaderFilter = new ShaderFilter(new Scanline());
	public static var grain:ShaderFilter = new ShaderFilter(new Grain());
	public static var hq2x:ShaderFilter = new ShaderFilter(new Hq2x());
	public static var tiltshift:ShaderFilter = new ShaderFilter(new Tiltshift());
	public static var wiggle:ShaderFilter = new ShaderFilter(new WiggleShader());
	public static var glitchy:ShaderFilter = new ShaderFilter(new PlayState.Glitch());

	
	public static function setChrome(chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}
}
