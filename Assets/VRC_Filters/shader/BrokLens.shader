Shader "HOTATE/Filter/BrokLens" {
	Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
		_radius ("Radius", range(0.0,0.3)) = 0.0005
		_gaussPhi ("GaussPhi", range(0.1,90.0)) = 3.0
	}
	SubShader {
		Tags {"Queue" = "Transparent+50000"}
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
			#define roop 0.2
			float _gaussPhi;
			float _radius;

			float gaussian (float2 input,float intensity) {
				float phi = _gaussPhi * (intensity+0.000001);
				float range = saturate(length(input));
				float output = 1.0/sqrt(2.0*3.14159265358979*phi) * exp(- pow(range,2.0)/(2.0*pow(phi,2.0)));
				return output;
			}
			
			fixed4 frag (v2f IN) : SV_Target {
				float4 col = float4(0.0,0.0,0.0,1.0);
				float3 buf;
                [unroll] for(float i=-1.0; i<1.0; i+=roop){
					[unroll] for(float j=-1.0; j<1.0; j+=roop){
						buf = tex2Dproj(_BackgroundTexture, IN.screenuv+float4(i*_radius,j*_radius,0.0,0.0));
						col.rgb += buf*gaussian( float2(i,j), length(buf));
					}
				}
				return col*roop;
			}
			ENDCG
		}
	}
}
