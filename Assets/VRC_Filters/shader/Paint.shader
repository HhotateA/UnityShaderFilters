Shader "HOTATE/Filter/Point" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        [IntRange]_Radius ("Radius", Range(0, 10)) = 0
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
 
            int _Radius;

            //base on http://www.shaderslab.com/demo-99---pencil-effect-1.html
            float4 frag (v2f IN) : SV_Target {
                float2 screenpix = 1.0/_ScreenParams.xy;
                float2 pos;
                float3 col;
                float sigma2;
                float3 mean[4] = {float3(0.0, 0.0, 0.0),
                                  float3(0.0, 0.0, 0.0),
                                  float3(0.0, 0.0, 0.0),
                                  float3(0.0, 0.0, 0.0)};
                float3 sigma[4] = {float3(0.0, 0.0, 0.0),
                                   float3(0.0, 0.0, 0.0),
                                   float3(0.0, 0.0, 0.0),
                                   float3(0.0, 0.0, 0.0)};
                float2 start[4] = {float2(-_Radius, -_Radius),
                                   float2(-_Radius,      0.0),
                                   float2(     0.0, -_Radius),
                                   float2(     0.0,      0.0)};

                for (int k=0; k<4; k++) {
                    for(int i=0; i<=_Radius; i++) {
                        for(int j=0; j<=_Radius; j++) {
                            pos = float2(i, j) + start[k];
                            col = tex2Dproj(_BackgroundTexture, IN.screenuv + float4( pos.xy*screenpix.xy, 0.0, 0.0)).rgb;
                            mean[k] += col;
                            sigma[k] += col * col;
                        }
                    }
                }

                float n = pow(_Radius + 1, 2);
                float4 color = tex2Dproj(_BackgroundTexture, IN.screenuv);
                float roopmax = 1.0;
                [unroll] for (int l=0; l<4; l++) {
                    mean[l] /= n;
                    sigma[l] = abs(sigma[l] / n - mean[l] * mean[l]);
                    sigma2 = sigma[l].r + sigma[l].g + sigma[l].b;
 
                    if (sigma2 < roopmax) {
                        roopmax = sigma2;
                        color.rgb = mean[l].rgb;
                    }
                }
                return color;
            }
 
            ENDCG
        }
    }
}