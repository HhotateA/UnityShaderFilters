Shader "HOTATE/Filter/Outline" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _sampleint ("SampleInt",Range(0.0,15.0)) = 1.7
        _basecolor ("BackColor",color) = (0.0,0.0,0.0,0.0)
        _laycolor ("LayColor",color) = (1.0,0.0,0.0,1.0)
        _step ("Step",range(0.0,3.0)) = 0.00001
    }
    SubShader {
        
        Tags {"Queue" = "Transparent+50000"}
        Blend SrcAlpha OneMinusSrcALpha
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
 
            float _sampleint;
            float4 _basecolor;
            float4 _laycolor;
            float _step;
 
            fixed4 frag(v2f IN) : SV_Target {
                float4 sampleWH = _sampleint * fwidth(IN.screenuv);
                float depth[4];
                depth[0] = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, IN.screenuv + sampleWH * float4( 1.0, 0.0, 0.0, 0.0)));
                depth[1] = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, IN.screenuv + sampleWH * float4(-1.0, 0.0, 0.0, 0.0)));
                depth[2] = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, IN.screenuv + sampleWH * float4( 0.0, 1.0, 0.0, 0.0)));
                depth[3] = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, IN.screenuv + sampleWH * float4( 0.0,-1.0, 0.0, 0.0)));
                float weight = abs(depth[0]-depth[1]) + abs(depth[2]-depth[3]);
                return lerp(_laycolor,_basecolor,step(weight,_step));
            }
 
            ENDCG
        }
    }
}