Shader "HOTATE/Filter/ShadowColor" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _basecolor ("LightColor",color) = (0.0,0.0,0.0,0.0)
        _shadowcolor ("ShadowColor",color) = (1.0,0.0,0.0,0.3)
    }
    SubShader {
        
        Tags {"Queue" = "Transparent-500"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest always
        Zwrite off
        Cull off
        Pass {
            CGPROGRAM
            #pragma shader_feature MIRROR_MODE
            #pragma shader_feature FILTER_MODE
            #include "UnityCG.cginc"
            #include "vertexdata.cginc"
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag
 
            sampler2D _ShadowMapTexture;
            float4 _basecolor;
            float4 _shadowcolor;
 
            fixed4 frag(v2f IN) : SV_Target {
                float4 shadowpower = tex2Dproj(_ShadowMapTexture, IN.screenuv);
                return lerp(_shadowcolor,_basecolor,shadowpower.r);
            }
 
            ENDCG
        }
    }
}