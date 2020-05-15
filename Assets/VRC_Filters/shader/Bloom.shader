Shader "HOTATE/Filter/Bloom" {
    Properties{
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        _threshold ("Threshold", range(0.0, 2.0)) = 0.0
        _soft_threshold ("SoftThreshold", range(0.0, 1.0)) = 0.0
        _intensity ("Intensity", range(0.0, 10.0)) = 0.0
        _radius ("Radius",float) = 1.0
    }
    SubShader {
        Tags {"Queue" = "Transparent+50000"}
        ZTest always
		ZWrite off
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

            float _threshold;
            float _soft_threshold;
            float _intensity;
            float _radius;

            #define pixpow 8.0
            #define pixmul 2.0

            static float3 linecolumn[41]={
                                                                                                                float3(-4.0, 0.0, 1.0),
                                                                                        float3(-3.0,-1.0, 4.0), float3(-3.0, 0.0, 1.0), float3(-3.0, 1.0, 4.0),
                                                                float3(-2.0,-2.0, 6.0), float3(-2.0,-1.0, 3.0), float3(-2.0, 0.0,17.0), float3(-2.0, 1.0, 3.0), float3(-2.0, 2.0, 6.0),
                                        float3(-1.0,-3.0, 4.0), float3(-1.0,-2.0, 3.0), float3(-1.0,-1.0,26.0), float3(-1.0, 0.0,10.0), float3(-1.0, 1.0,26.0), float3(-1.0, 2.0, 3.0), float3(-1.0, 3.0, 4.0),
                float3( 0.0,-4.0, 1.0), float3( 0.0,-3.0, 1.0), float3( 0.0,-2.0,17.0), float3( 0.0,-1.0,10.0), float3( 0.0, 0.0,31.0), float3( 0.0, 1.0,10.0), float3( 0.0, 2.0,17.0), float3( 0.0, 3.0, 1.0), float3( 0.0, 4.0, 1.0),
                                        float3( 1.0,-3.0, 4.0), float3( 1.0,-2.0, 3.0), float3( 1.0,-1.0,26.0), float3( 1.0, 0.0,10.0), float3( 1.0, 1.0,26.0), float3( 1.0, 2.0, 3.0), float3( 1.0, 3.0, 4.0),
                                                                float3( 2.0,-2.0, 6.0), float3( 2.0,-1.0, 3.0), float3( 2.0, 0.0,17.0), float3( 2.0, 1.0, 3.0), float3( 2.0, 2.0, 6.0),
                                                                                        float3( 3.0,-1.0, 4.0), float3( 3.0, 0.0, 1.0), float3( 3.0, 1.0, 4.0),
                                                                                                                float3( 4.0, 0.0, 1.0),

            };

            float4 calcoffset (float2 screenpix,float delta) {
                return float2(1.0/screenpix).xyxy * float2(-delta, delta).xxyy;
            }
			float3 sampleBox (float4 uv, float delta, float2 screenpix) {
				float4 offset = calcoffset(screenpix,delta);
				float3 sum = tex2Dproj( _BackgroundTexture, uv + float4(offset.xy,0.0,0.0))
                           + tex2Dproj( _BackgroundTexture, uv + float4(offset.zy,0.0,0.0))
                           + tex2Dproj( _BackgroundTexture, uv + float4(offset.xw,0.0,0.0))
                           + tex2Dproj( _BackgroundTexture, uv + float4(offset.zw,0.0,0.0));
				return sum * 0.25;
			}
			float colormax (float3 color) {
				return max(color.r, max(color.g, color.b));
			}
//最初の
			float4 firstpass (float4 uv, float2 screenpix) {
                float knee = _threshold * _soft_threshold;
				float4 col = float4(sampleBox( uv, 1.0, screenpix),1.0);
                float brightness = colormax(col.rgb); //サンプル点の明度を取る
                float soft = brightness - (_threshold-knee); //(_threshold-knee) - (_threshold+knee)間でSoft knee
                soft = clamp(soft,0.0,knee*2.0);
                soft = soft*soft * (0.25 / (knee+0.00001));
                float contribution = max(soft,brightness-_threshold) / max(brightness,0.00001);
                return col * contribution;
			}

			fixed4 frag (v2f IN) : SV_Target {
                float2 screenpix = _ScreenParams.xy;
				screenpix = screenpix.xy / (pixpow*_radius);
                float4 sampleuv;
				float2 offset = (1.0/screenpix) * 0.5;
                float4 sumcolor = (float4)0.0;
                [unroll] for(int index=0;index<41;index++) {
                    sampleuv = IN.screenuv + float4(linecolumn[index].xy*offset,0.0,0.0);
                    sumcolor += firstpass(sampleuv,screenpix) * linecolumn[index].z;
                }
				return sumcolor*_intensity /331.0 + tex2Dproj( _BackgroundTexture, IN.screenuv);
			}
			ENDCG
        }
    }
}