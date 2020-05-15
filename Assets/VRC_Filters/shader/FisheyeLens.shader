Shader "HOTATE/Filter/FisheyeLens" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        _zoom ("Zoom",range(0.1,10.0)) = 7.3
        _fov ("FOV",range(0.55,0.75)) = 0.73
    }
    SubShader {
        Tags { "Queue" = "Transparent+50000"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest always
        Zwrite off
        Cull off
		GrabPass { "_BackgroundTexture"}
        Pass {
            CGPROGRAM
            #pragma shader_feature MIRROR_MODE
            #pragma shader_feature FILTER_MODE
            #include "UnityCG.cginc"
            #include "vertexdata.cginc"
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

            float _fov;
            float _zoom;
            float4 _Color;
            
            //base on http://www.shaderslab.com/demo-99---pencil-effect-1.html
            #define RANGE 16.0
            #define STEP 2.0
            #define ROOPMAX 4.0
 
            float4 getCol(float2 pos) {
                return tex2D(_BackgroundTexture, pos / _ScreenParams.xy);
            }
            float getVal(float2 pos) {
                float4 col = getCol(pos);
                return dot(col.xyz, float3(0.2126, 0.7152, 0.0722));
            }
            float2 getGrad(float2 uv, float delta) {
                return float2(getVal(float2( uv.x+delta, uv.y      )) - getVal(float2( uv.x-delta, uv.y      )),
                              getVal(float2( uv.x      , uv.y+delta)) - getVal(float2( uv.x      , uv.y-delta))) / (delta*2.0);
            }
            float2 calcp(float2 p, float a) {
                return cos(a) * p + sin(a) * float2(p.y, -p.x);
            }

            fixed4 frag(v2f IN) : SV_Target {
                float2 screenuv = IN.screenuv.xy / IN.screenuv.w;
				screenuv = UnityStereoTransformScreenSpaceTex(screenuv);
                screenuv -= float2(0.5,0.5);
                float dist = distance(screenuv,float2(0.0,0.0));
                clip(0.5-dist);
                float r = tan(dist * UNITY_PI) / tan(2.0 * _fov * UNITY_PI);
                float2 uv;
                uv.x = screenuv.x * r * 2.0 / dist;
                uv.y = screenuv.y * r * 2.0 / dist;
                uv /= _zoom;
                uv += float2(0.5,0.5);
                float4 col = tex2D(_BackgroundTexture,uv);
                return float4(col.rgb,1.0);
            }
            ENDCG
        }
    }
}