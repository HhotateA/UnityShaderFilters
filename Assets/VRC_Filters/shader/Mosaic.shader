﻿Shader "HOTATE/Filter/Mosaic" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        _xint ("X",float) = 100.0
        _yint ("Y",float) = 100.0
    }
    SubShader {
        Tags { "Queue" = "Transparent+5000"}
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

            float _xint;
            float _yint;
 
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
                float2 dot = float2(1.0/_xint,1.0/_yint);
                float2 dotnum = floor(screenuv / dot);
                float2 dotuv  = (screenuv % dot) / dot;
                float dotdist = distance(float2((dotuv.x%(1.0/3.0))*3.0,dotuv.y),float2(0.5,0.5));
                float3 col = tex2D(_BackgroundTexture, dot*dotnum);
                return float4(col,1.0);
            }
            ENDCG
        }
    }
}