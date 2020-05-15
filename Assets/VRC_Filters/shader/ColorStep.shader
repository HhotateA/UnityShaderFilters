Shader "HOTATE/Filter/ColorStep" {
    Properties {
		[Toggle(Mirrormode)] _Mirrormode ("MirrorMode", float) = 0.0
        _step ("Step",float) = 5.0
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
            #include "UnityCG.cginc"
            #pragma shader_feature Mirrormode
            #include "vertexdata.cginc"
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

            float _step;

            fixed4 frag(v2f IN) : SV_Target {
                float3 col = tex2Dproj(_BackgroundTexture, IN.screenuv);
                col = floor(col*_step) / _step;
                return float4(col,1.0);
            }
            ENDCG
        }
    }
}