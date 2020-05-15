Shader "HOTATE/Filter/WireFramea" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _basecolor ("BaseColor",color) = (0.0,0.0,0.0,0.0)
        _linecolor ("LineCOlor",color) = (1.0,0.0,0.0,1.0)
    }
    SubShader {
        Tags { "Queue" = "Transparent+4999"}
        ZTest always
        Zwrite off
        Cull off
        Pass {
            CGPROGRAM
            #pragma shader_feature MIRROR_MODE
            #pragma shader_feature FILTER_MODE
            #define DEPTH_MODE
            #include "UnityCG.cginc"
            #include "vertexdata.cginc"
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

            fixed4 frag(v2f IN) : SV_Target {
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, IN.screenuv));
                float3 wpos = normalize(IN.cvec) * depth + _WorldSpaceCameraPos;
                float3 col = cross(normalize(ddx(wpos)),normalize(ddy(wpos)));
                return fixed4(col,1.0);
            }
            ENDCG
        }
		GrabPass {"_BackgroundTexture"}
        Pass {
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma shader_feature Mirrormode
            #include "vertexdata.cginc"
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

            float4 _basecolor;
            float4 _linecolor;

            fixed4 frag(v2f IN) : SV_Target {
                float4 pixuv = fwidth(IN.screenuv);
                float4 samplecol = tex2Dproj(_BackgroundTexture,IN.screenuv+pixuv);
                float weight = length(fwidth(samplecol).rgb);
                return lerp(_basecolor,_linecolor,weight);
            }
            ENDCG
        }
    }
}