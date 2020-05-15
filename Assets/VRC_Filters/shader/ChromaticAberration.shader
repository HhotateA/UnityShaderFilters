Shader "HOTATE/Filter/ChromaticAberration" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _rshift ("RedShift",vector) = (0.01,0.0,0.0,0.0)
        _gshift ("GreenShift",vector) = (0.0,0.01,0.0,0.0)
        _bshift ("BlueShift",vector) = (-0.01,0.0,0.0,0.0)
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

            float4 _rshift;
            float4 _gshift;
            float4 _bshift;

            fixed4 frag(v2f IN) : SV_Target {
                float3 col;
                col.r = tex2Dproj(_BackgroundTexture, IN.screenuv+_rshift).r;
                col.g = tex2Dproj(_BackgroundTexture, IN.screenuv+_gshift).g;
                col.b = tex2Dproj(_BackgroundTexture, IN.screenuv+_bshift).b;
                return float4(col,1.0);
            }
            ENDCG
        }
    }
}