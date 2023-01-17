package shaders;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

/**
 * ORIGINAL SHADER BY b005t3r
 * PORTED FOR HAXEFLIXEL USE FROM https://www.shadertoy.com/view/MtdXWl
 */
class CRTBend extends FlxShader
{
	@:glFragmentSource("
		#pragma header
        const float maskStr			= 0.0125;		// 0.0 - 1.0
        const float vignetteStr		= 0.10;			// 0.0 - 1.0
        const float crtBend			= 4.8;
        const float crtOverscan		= 0.1;			// 0.0 - 1.0	

        uniform vec2 iResolution;

        vec4 alphaBlend(vec4 top, vec4 bottom)
        {
            vec4 result;
            result.a = top.a + bottom.a * (1.0 - top.a);
            result.rgb = (top.rgb * top.aaa + bottom.rgb * bottom.aaa * (vec3(1.0, 1.0, 1.0) - top.aaa)) / result.aaa;
            
            return result;
        }

        vec3 vignette(vec2 uv)
        {
            float OuterVig = 1.0; // Position for the Outer vignette
            float InnerVig = 0.65; // Position for the inner Vignette Ring
            
            //vec2 uv = fragCoord.xy / iResolution.xy;
            
            vec2 center = vec2(0.5,0.5); // Center of Screen
            
            float dist  = distance(center,uv )*1.414213; // Distance  between center and the current Uv. Multiplyed by 1.414213 to fit in the range of 0.0 to 1.0 	
            float vig = clamp((OuterVig-dist) / (OuterVig-InnerVig),0.0,1.0); // Generate the Vignette with Clamp which go from outer Viggnet ring to inner vignette ring with smooth steps
            
            return vec3(vig, vig, vig);
        }

        vec2 crt(vec2 coord, float bend)
        {
            // put in symmetrical coords
            coord = (coord - 0.5) * 2.0 / (crtOverscan + 1.0);

            coord *= 1.1;	

            // deform coords
            coord.x *= 1.0 + pow((abs(coord.y) / bend), 2.0);
            coord.y *= 1.0 + pow((abs(coord.x) / bend), 2.0);

            // transform back to 0.0 - 1.0 space
            coord  = (coord / 2.0) + 0.5;

            return coord;
        }

        void main()
        {
            vec2 fragCoord = openfl_TextureCoordv * iResolution;

            vec2 uv = fragCoord.xy / iResolution.xy;
            vec2 crtCoords = crt(uv, crtBend);

            if(crtCoords.x < 0.0 || crtCoords.x > 1.0 || crtCoords.y < 0.0 || crtCoords.y > 1.0) {
    	        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
            }
            else {
                vec4 final = texture2D(bitmap, crtCoords);

                // 9. mix mask with final
                float moduloX = floor(mod(fragCoord.x, 6.0));
                float moduloY = floor(mod(fragCoord.y, 6.0));

                vec3 tmp;

                if(moduloX < 3.0) {
                    if(moduloY == 0.0 || moduloY == 5.0)
                        tmp.rgb = vec3(0.0, 0.0, 0.0);
                    else
                        tmp.rgb = vec3(1.0, 1.0, 1.0);
                }
                else {
                    if(moduloY == 2.0 || moduloY == 3.0)
                        tmp.rgb = vec3(0.0, 0.0, 0.0);
                    else
                        tmp.rgb = vec3(1.0, 1.0, 1.0);
                }

                tmp = final.rgb * tmp;
                final.rgb = alphaBlend(vec4(tmp, maskStr), final).rgb; 

                // 10. vignette
                tmp = final.rgb * vignette(fragCoord.xy / iResolution.xy);
                final.rgb = alphaBlend(vec4(tmp, vignetteStr), final).rgb;

                gl_FragColor = final;
            }
        }
	")
	public function new()
	{
		super();

		data.iResolution.value = [FlxG.width, FlxG.height];
	}
}
