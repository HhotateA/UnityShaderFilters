﻿Shader "HOTATE/Filter/Sobel" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _sampleint ("SampleInt",Range(0.0,15.0)) = 1.0
        _backcolor ("BackColor",color) = (0.0,0.0,0.0,1.0)
        _linecolor ("LineColor",color) = (1.0,1.0,1.0,1.0)
        _saturation ("Saturation",range(0.0,1.0)) = 1.0
    }
    SubShader {
        
        Tags {"Queue" = "Transparent+50000"}
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
 
            float _weight;
            float _sampleint;
            float4 _backcolor;
            float4 _sampleX;
            float4 _sampleY;
            float4 _sampleZ;
            float4 _linecolor;
            float _saturation;
 
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
                float2 screenPos = float2(IN.screenuv.x * _ScreenParams.x, IN.screenuv.y * _ScreenParams.y)/IN.screenuv.w;
                float2 sampleWH = _sampleint * abs(float2( ddx(screenPos.x), ddy(screenPos.y)));
                float4 col[9];
                col[0] = getCol(screenPos +sampleWH*float2(-1.0,-1.0));
                col[1] = getCol(screenPos +sampleWH*float2(-1.0, 0.0));
                col[2] = getCol(screenPos +sampleWH*float2(-1.0, 1.0));
                col[3] = getCol(screenPos +sampleWH*float2( 0.0,-1.0));
                col[4] = getCol(screenPos +sampleWH*float2( 0.0, 0.0));
                col[5] = getCol(screenPos +sampleWH*float2( 0.0, 1.0));
                col[6] = getCol(screenPos +sampleWH*float2( 1.0,-1.0));
                col[7] = getCol(screenPos +sampleWH*float2( 1.0, 0.0));
                col[8] = getCol(screenPos +sampleWH*float2( 1.0, 1.0));
                float4 samplecol1 = col[0]+2*col[1]+col[2]
                                   -col[6]-2*col[7]-col[8];
                float4 samplecol2 = col[0]+2*col[3]+col[6]
                                   -col[2]-2*col[5]-col[8];
                float weight = saturate(length(samplecol1.rgb)*length(samplecol1.rgb) + length(samplecol2.rgb)*length(samplecol2.rgb));
                float4 outputcol = lerp(_backcolor,col[4],weight);
                float4 outputgray = lerp(_backcolor,_linecolor,weight);
                return lerp(outputgray,outputcol,_saturation);
            }
            ENDCG
        }
    }
}