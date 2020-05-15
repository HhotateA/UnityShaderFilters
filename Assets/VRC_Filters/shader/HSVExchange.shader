Shader "HOTATE/Filter/HSVExchange" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _h ("H",range(-0.5,0.5)) = 0.0
        _s ("S",range(-1.0,1.0)) = 0.0
        _v ("V",range(-1.0,1.0)) = 0.0
    }
    SubShader {
        Tags {"Queue" = "Transparent+50000"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest always
        Zwrite off
        Cull off
		GrabPass {"_BackgroundTexture"}
        Pass {
            CGPROGRAM
            #pragma shader_feature MIRROR_MODE
            #pragma shader_feature FILTER_MODE
            #include "UnityCG.cginc"
            #include "vertexdata.cginc"
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

            float _h;
            float _s;
            float _v;
            
            //base on http://www.shaderslab.com/demo-99---pencil-effect-1.html
            #define RANGE 16.0
            #define STEP 2.0
            #define ROOPMAX 4.0

            //base on "https://qiita.com/_nabe/items/c8ba019f26d644db34a8"
            float3 rgb2hsv(float3 c) {
                float4 k = float4( 0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0 );
                float e = 1.0e-10;
                float4 p = lerp( float4(c.bg, k.wz), float4(c.gb, k.xy), step(c.b, c.g) );
                float4 q = lerp( float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r) );
                float d = q.x - min(q.w, q.y);
                return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x );
            }
            float3 hsv2rgb(float3 c) {
                float4 k = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
                float3 p = abs( frac(c.xxx + k.xyz) * 6.0 - k.www );
                return c.z * lerp( k.xxx, saturate(p - k.xxx), c.y );
            }

            fixed4 frag(v2f IN) : SV_Target {
                float4 col = tex2Dproj(_BackgroundTexture, IN.screenuv);
                float3 hsv = rgb2hsv(col.rgb);
                hsv.x += _h;
                hsv.y = lerp(lerp(0.0,hsv.y,_s+1.0),lerp(hsv.y,1.0,_s),step(0.0,_s)); //_sが0以下ならlerp(0.0-s),_sが０以上ならlerp(s-1.0)
                hsv.z = lerp(lerp(0.0,hsv.z,_v+1.0),lerp(hsv.z,1.0,_v),step(0.0,_v));

                float pi = UNITY_PI * 2.0;
                float four_pi = UNITY_FOUR_PI / 2.0;
                col = float4( UNITY_TWO_PI, pi, four_pi, pi*four_pi*_h);
                col = float4(hsv2rgb(hsv),1.0);
                return col;
            }
            ENDCG
        }
    }
}