#define clipdist 0.3
#define mirrordist 30.0

#ifdef FILTER_MODE
	#ifdef DEPTH_MODE
				UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

				struct appdata {
					float4 vertex : POSITION;
				};
				struct v2f {
					float4 screenuv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 cvec : TEXCOORD1;
				};

				appdata vert (appdata v){
					return v;
				}
				[maxvertexcount(3)]
				void geom (triangle appdata IN[3],inout TriangleStream< v2f > OUT)	{
					v2f output;
					[unroll] for(uint index=0; index<3; index++){
						output.vertex = UnityObjectToClipPos(IN[index].vertex);
						output.screenuv = ComputeGrabScreenPos(output.vertex);
						output.cvec = mul(UNITY_MATRIX_M,IN[index].vertex)-_WorldSpaceCameraPos;
						OUT.Append(output);
					}
					OUT.RestartStrip();
				}
	#else
				sampler2D _BackgroundTexture;

				struct appdata {
					float4 vertex : POSITION;
				};
				struct v2f {
					float4 screenuv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};
				appdata vert (appdata v){
					return v;
				}
				[maxvertexcount(3)]
				void geom (triangle appdata IN[3],inout TriangleStream< v2f > OUT)	{
					v2f output;
					[unroll] for(uint index=0; index<3; index++){
						output.vertex = UnityObjectToClipPos(IN[index].vertex);
						output.screenuv = ComputeGrabScreenPos(output.vertex);
						OUT.Append(output);
					}
					OUT.RestartStrip();
				}
	#endif
#else

	static float2 screenvertex[4] =	{float2(-1.0, 1.0),
									float2( 1.0, 1.0),
									float2(-1.0,-1.0),
									float2( 1.0,-1.0)};
									
	void clipprocess(inout float4 output){
		float dist = distance(_WorldSpaceCameraPos,mul(UNITY_MATRIX_M,float4(0.0,0.0,0.0,1.0)));
		#ifdef MIRROR_MODE
			if(dist>mirrordist) output = float4(-1.0,-1.0,-1.0,-1.0);
			if(UNITY_MATRIX_P[2][2]>0) output = float4(-1.0,-1.0,-1.0,-1.0);
		#else
			if(dist>clipdist) output = float4(-1.0,-1.0,-1.0,-1.0);
			if(abs(_ScreenParams.x-1280.0)+abs(_ScreenParams.y-720.0)>0.1 && abs(_ScreenParams.x-1920.0)+abs(_ScreenParams.y-1080.0)>0.1 ) output = float4(-1.0,-1.0,-1.0,-1.0);
		#endif
	}

	#ifdef DEPTH_MODE
				UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

				struct v2f {
					float4 screenuv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 cvec : TEXCOORD1;
				};

				v2f vert () {
					v2f output = (v2f)0;
					return output;
				}
				[maxvertexcount(4)]
				void geom (point v2f IN[1],inout TriangleStream< v2f > OUT)	{
					v2f output;
					[unroll] for(uint index=0; index<4; index++){
						output.vertex = float4(screenvertex[index],0.0,1.0);
						clipprocess(output.vertex);
						output.screenuv = ComputeGrabScreenPos(output.vertex);
						output.cvec = mul(UNITY_MATRIX_M,screenvertex[index])-_WorldSpaceCameraPos;
						OUT.Append(output);
					}
					OUT.RestartStrip();
				}
	#else
				sampler2D _BackgroundTexture;

				struct v2f {
					float4 screenuv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};
				v2f vert () {
					v2f output = (v2f)0;
					return output;
				}
				[maxvertexcount(4)]
				void geom (point v2f IN[1],inout TriangleStream< v2f > OUT)	{
					v2f output;
					[unroll] for(uint index=0; index<4; index++){
						output.vertex = float4(screenvertex[index],0.0,1.0);
						clipprocess(output.vertex);
						output.screenuv = ComputeGrabScreenPos(output.vertex);
						OUT.Append(output);
					}
					OUT.RestartStrip();
				}
	#endif
#endif

float3 stereocamerapos () {
	float3 cameraPos = _WorldSpaceCameraPos;
	#if defined(USING_STEREO_MATRICES)
	cameraPos = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * .5;
	#endif
	return cameraPos;
}
