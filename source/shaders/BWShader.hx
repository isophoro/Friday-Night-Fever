package shaders;

import flixel.system.FlxAssets.FlxShader;

@:keep class BWShader extends FlxShader
{
    public var colorFactor(get, set):Float;

    function get_colorFactor():Float
    {
        return data.u_colorFactor.value[0];
    }

    function set_colorFactor(_new:Float):Float
    {
        data.u_colorFactor.value = [_new];
        return _new;
    }

    // Original shader written by Volcanoscar
    // https://gist.github.com/Volcanoscar/4a9500d240497d3c0228f663593d167a

    @:glFragmentSource('
    #pragma header

    uniform float u_colorFactor = 1.0;

    void main() {
        vec4 sample = flixel_texture2D(bitmap, openfl_TextureCoordv);
        float gray = 0.21 * sample.r + 0.71 * sample.g + 0.07 * sample.b;
        gl_FragColor = vec4(sample.rgb * (1.0 - u_colorFactor) + (gray * u_colorFactor), sample.a);
    }
    ')

    public function new()
    {
        super();
    }
}