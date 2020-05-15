Shader "HOTATE/Filter/Infrared" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _basecolor ("BackColor",color) = (0.0,0.0,0.0,1.0)
        _laycolor ("LayColor",color) = (1.0,0.0,0.0,1.0)
        _maxdist ("MaxDist",float) = 10.0
        _pow ("Adjustment",float) = 0.1
    }
    SubShader {
        
        Tags {"Queue" = "Transparent+50000"}
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
 
            float4 _basecolor;
            float4 _laycolor;
            float _maxdist;
            float _pow;
 
            fixed4 frag(v2f IN) : SV_Target {
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, IN.screenuv)) / _maxdist;
                return lerp(_laycolor,_basecolor,saturate(pow(depth,_pow)));
            }
 
            ENDCG
        }
    }
}