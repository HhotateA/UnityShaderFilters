Shader "HOTATE/Filter/DoF" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _zoom ("Zoom",range(1.0,30.0)) = 1.0
        _sampleint ("SampleInt",Range(0.0,15.0)) = 1.7
		[Toggle(AutoPint)] _AutoPint ("AutoFocus", float) = 1.0
        _pintdist ("FocusDist",range(0.0,100.0)) = 10.0
        _threshold ("Threshold",range(0.0,100.0)) = 0.3
        _gain ("Gain",range(0.0,1.0)) = 0.5
    }
    SubShader {
        
        Tags {"Queue" = "Transparent+50001"}
        Blend SrcAlpha OneMinusSrcALpha
        ZTest always
        Zwrite off
        Cull off
		GrabPass { "_BackgroundTexture"}
        Pass {
            CGPROGRAM
            #pragma shader_feature MIRROR_MODE
            #pragma shader_feature FILTER_MODE
            #define DEPTH_MODE
            #include "UnityCG.cginc"
            #pragma shader_feature AutoPint
            #include "vertexdata.cginc"
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

            #define roopnum 10 //ぼかしのクオリティ

            sampler2D _BackgroundTexture; 
            float _zoom;
            float _sampleint;
            float _pintdist;
            float _threshold;
            float _gain;

            float gammacorrect(float gamma, float input) {
                return saturate(pow( 1.0-input, 1.0/gamma));
            }
            float calcdist (float2 linecolumn) {
                return distance(linecolumn,float2(0.0,0.0))/distance(float2(roopnum,roopnum),float2(0.0,0.0));
            }
            float bias(float b, float x) {
                return pow(x, log(b) / log(0.5));
            }
            float gain(float gamma, float input) {
                float output1 = bias(1.0 - gamma, 2.0 * input) / 2.0;
                float output2 = 1.0 - bias(1.0 - gamma, 2.0 - 2.0 * input) / 2.0;
                return lerp(output1,output2,step(0.5,input));
            }
 
            fixed4 frag(v2f IN) : SV_Target {
                float4 sampleWH = _sampleint * fwidth(IN.screenuv);
                float4 uv = IN.screenuv;
                uv.xy -= float2(0.5,0.5);
                uv.xy /= _zoom;
                uv.xy += float2(0.5,0.5);
                float4 col = float4(0.0,0.0,0.0,0.0);
                float dist = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
                float pintdist = _pintdist;
                #ifdef AutoPint
                pintdist = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, float4(0.5,0.5,0.0,0.0)));
                #endif
                float pintdelta;
                [unroll] for(float linenum=-roopnum;linenum++;linenum<=roopnum){
                    [unroll] for(float columnnum=-roopnum;columnnum++;columnnum<=roopnum){
                        col += float4( tex2Dproj( _BackgroundTexture, uv + sampleWH*float4(linenum,columnnum,0.0,0.0)).rgb, 1.0)
                                *gammacorrect( lerp( 0.0, 1.0, gain(_gain,abs(dist-pintdist)/_threshold)), calcdist(float2(linenum,columnnum)));
                    }
                }
                col /= col.a;
                return col;
            }
 
            ENDCG
        }
    }
}