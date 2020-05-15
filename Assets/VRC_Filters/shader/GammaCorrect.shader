Shader "HOTATE/Filter/GammaCorrect" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _gamma ("GammaCorrect",range(-1.0,1.0)) = 1.0
    }
    SubShader {
        Tags { "Queue" = "Transparent+50000"}
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

            //base on https://qiita.com/oishihiroaki/items/9d899cdcb9bee682531a
            float bias(float gamma, float input) {
                return pow( input, log(gamma)/log(0.5));
            }
            float gain(float gamma, float input){
                float output1 = bias(1.0 - gamma, 2.0 * input) / 2.0;
                float output2 = 1.0 - bias(1.0 - gamma, 2.0 - 2.0 * input) / 2.0;
                return lerp(output1,output2,step(0.5,input));
            }
            float3 gammacorrect(float gamma, float3 input){
                return float3(gain(gamma,input.r),
                              gain(gamma,input.g),
                              gain(gamma,input.b));
            }

            float _gamma;

            fixed4 frag(v2f IN) : SV_Target {
                float3 col = tex2Dproj(_BackgroundTexture, IN.screenuv);
                col = gammacorrect(_gamma, col);
                return float4(col,1.0);
            }
            ENDCG
        }
    }
}