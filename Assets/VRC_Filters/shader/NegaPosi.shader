Shader "HOTATE/Filter/NegaPosi" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _r ("Red",range(-1.0,1.0)) = -1.0
        _g ("Green",range(-1.0,1.0)) = -1.0
        _b ("Blue",range(-1.0,1.0)) = -1.0
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

            float _r;
            float _g;
            float _b;

            fixed4 frag(v2f IN) : SV_Target {
                float3 col = tex2Dproj(_BackgroundTexture, IN.screenuv);
                col = float3( lerp( 0.5, col.r, _r),
                              lerp( 0.5, col.g, _g),
                              lerp( 0.5, col.b, _b));
                return float4(col,1.0);
            }
            ENDCG
        }
    }
}