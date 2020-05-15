Shader "HOTATE/Filter/ColorMono" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _color ("Color",color) = (0.0,1.0,0.0,1.0)
        _tolerance ("Tolerance",vector) = (0.1,0.1,0.1,0.0)
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

            float4 _color;
            float4 _tolerance;

            fixed4 frag(v2f IN) : SV_Target {
                float3 col = tex2Dproj(_BackgroundTexture, IN.screenuv);
                float3 mono = ((col.r+col.g+col.b)/3.0).xxx;
                float weight = step(_tolerance.r,abs(col.r-_color.r)) + step(_tolerance.g,abs(col.g-_color.g)) + step(_tolerance.b,abs(col.b-_color.b)); 
                float3 output = lerp(col,mono,saturate(weight));
                return float4(output,1.0);
            }
            ENDCG
        }
    }
}