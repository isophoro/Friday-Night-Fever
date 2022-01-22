package shaders;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

class CRTShader extends FlxShader
{
    public var shader:CRTShader;
    @:glFragmentSource('
    #pragma header
    uniform vec2 iResolution;

    uniform float warp = 0.75; // simulate curvature of CRT monitor
    uniform float scan = 0.75; // simulate darkness between scanlines

    void main()
	{
        vec2 fragCoord = openfl_TextureCoordv * iResolution;

        // squared distance from center
        vec2 uv = fragCoord/iResolution.xy;
        vec2 dc = abs(0.5-uv);
        dc *= dc;
        
        // warp the fragment coordinates
        uv.x -= 0.5; uv.x *= 1.0+(dc.y*(0.3*warp)); uv.x += 0.5;
        uv.y -= 0.5; uv.y *= 1.0+(dc.x*(0.4*warp)); uv.y += 0.5;

        // sample inside boundaries, otherwise set to black
        if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0)
            gl_FragColor = vec4(0.0,0.0,0.0,1.0);
        else
        {
        // determine if we are drawing in a scanline
        float apply = abs(sin(fragCoord.y)*0.5*scan);
        // sample the texture
        gl_FragColor = vec4(mix(texture2D(bitmap ,uv).rgb,vec3(0.0),apply),1.0);
        }
	}
    ')

    public function new()
    {
        shader = this;
        super();
        iResolution.value = [FlxG.width, FlxG.height];
        warp.value = [0.0];
        scan.value = [0.0];
    }
}