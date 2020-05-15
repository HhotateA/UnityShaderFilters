Shader "HOTATE/Filter/Pencil" {
    Properties {
        [Toggle(FILTER_MODE)] _FILTER_MODE ("Filter Mode",float) = 0
        [Toggle(Mirror_MODE)] _MIRROR_MODE ("Mirror Mode",float) = 0
        _GradThresh ("Gradiant threshold", range(0.000000001, 0.3)) = 0.01
        _ColorThreshold ("Color Threshold", range(-1.0, 10.0)) = 1.0
        _basecolor ("BackColor",color) = (1.0,1.0,1.0,1.0)
        _noudo ("Adjustment",float) = 1
        _range ("Range",float) = 16.0
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
 
            float _GradThresh;
            float _ColorThreshold;
            float4 _basecolor;
            float _Intensity;
            float _noudo;
            float _range;

            //base on http://www.shaderslab.com/demo-99---pencil-effect-1.html
            #define RANGE 16.0
            #define STEP 2.0
            #define ROOPMAX 4.0
 
            float4 getCol(float2 pos) {
                return tex2D(_BackgroundTexture, pos / _ScreenParams.xy);
            }
            float getVal(float2 pos) {
                float4 col = getCol(pos);
                return dot(col.xyz, float3(0.2126, 0.7152, 0.0722));
            }
            float2 getGrad(float2 uv, float delta) {
                return float2(getVal(float2( uv.x+delta, uv.y      )) - getVal(float2( uv.x-delta, uv.y      )),
                              getVal(float2( uv.x      , uv.y+delta)) - getVal(float2( uv.x      , uv.y-delta))) / (delta*2.0);
            }
            float2 calcp(float2 p, float a) {
                return cos(a) * p + sin(a) * float2(p.y, -p.x);
            } 
            fixed4 frag(v2f IN) : SV_Target {
                float2 screenuv = IN.screenuv.xy / IN.screenuv.w;
				screenuv = UnityStereoTransformScreenSpaceTex(screenuv);
                float2 screenPos = float2(IN.screenuv.x * _ScreenParams.x, IN.screenuv.y * _ScreenParams.y)/IN.screenuv.w;
                float weight = 1.0;
                for(int j = 0; j < ROOPMAX; j++) {
                    float2 dir = float2(1.0, 0.0) ;
                    dir = calcp(dir, j * UNITY_PI / ROOPMAX);
                    float2 grad = float2(-dir.y, dir.x);
                    for(int i=-RANGE; i<=RANGE; i+=STEP) {
                        float2 b = normalize(dir);
                        float2 pos2 = screenPos + float2(b.x, b.y) * i;
                        if (pos2.y < 0.0 || pos2.x < 0.0 || pos2.x > _ScreenParams.x || pos2.y > _ScreenParams.y) continue;
                        float2 g = getGrad(pos2, 1.0);
                        if (sqrt(dot(g,g)) < _GradThresh) continue;
                        weight -= pow(abs(dot(normalize(grad), normalize(g))), 10.0) / floor((STEP*RANGE+1.0) / 2.0) / ROOPMAX;
                    }
                }
                float4 col = getCol(screenPos)*_ColorThreshold;
                return lerp(col, _basecolor, pow(weight,_noudo));
            }
 
            ENDCG
        }
    }
}