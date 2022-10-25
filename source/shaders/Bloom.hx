package shaders;

import flixel.system.FlxAssets.FlxShader;

class Bloom extends FlxShader
{
    public var valueScale(default, set):Float = 0;

	function set_valueScale(v:Float):Float
	{
		valueScale = v;
		data.scale.value = [v];
		return v;
	}

	@:glFragmentSource('
    #pragma header

    uniform vec2 iResolution;
    #define resolution ( iResolution.xy )

    uniform sampler2D tInput;
    float kernel = .005;
    uniform float actualScale;
    float scale = actualScale;
    float thresh = 1.;
    vec2 vUv =openfl_TextureCoordv;
    
    void main()
    {
        vec4 sum = vec4(0);
    
        // mess of for loops due to gpu compiler/hardware limitations
        int j=-2;
        for( int i=-2; i<=2; i++) sum+=texture2D(bitmap,vUv+vec2(i,j)*kernel);
        j=-1;
        for( int i=-2; i<=2; i++) sum+=texture2D(bitmap,vUv+vec2(i,j)*kernel);
        j=0;
        for( int i=-2; i<=2; i++) sum+=texture2D(bitmap,vUv+vec2(i,j)*kernel);
        j=1;
        for( int i=-2; i<=2; i++) sum+=texture2D(bitmap,vUv+vec2(i,j)*kernel);
        j=2;
        for( int i=-2; i<=2; i++) sum+=texture2D(bitmap,vUv+vec2(i,j)*kernel);
        sum/=25.0;
    
        vec4 s=texture2D(bitmap, vUv);
        gl_FragColor=s;
    
        if (length(sum)>thresh)
        {
            gl_FragColor +=sum*scale;
        }
    }')
	public function new()
	{
		super();
	}
}
