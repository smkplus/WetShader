Shader "Example/WorldRefl Normalmap" {
	Properties{
		_MainTex("Texture", 2D) = "white" {}
	_BumpMap("Bumpmap", 2D) = "bump" {}
	_Mask("Mask",2D) = "white"{}
	_Cube("Cubemap", CUBE) = "" {}
	_Metallic("Metallic",Range(0,1)) = 1
	_Smoothness("Smoothness",Range(0,1)) = 1
	_Alpha("Alpha",Range(0,1)) = 1
	_CutOff("CutOff",Range(0,1)) = 0.5
	_FLowMap("FlowMap",2D) = "white"{}
	_Intensity("Intensity",Float) = 5
	}
		SubShader{


		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex,_Mask,_BumpMap;
		fixed _CutOff,_Intensity;
		half _Metallic;
 		half _Smoothness;


		struct Input {
			float2 uv_MainTex;
			float2 uv_Mask;
			float2 uv_BumpMap;
		};


		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
		o.Metallic = _Metallic;
		o.Smoothness = _Smoothness;
		float4 mask = tex2D(_Mask, IN.uv_Mask);
		mask = smoothstep(mask, 0, _CutOff);
		o.Normal = UnpackNormal(tex2D (_BumpMap, IN.uv_BumpMap))+mask*_Intensity;
			o.Alpha = c.a;
		}
		ENDCG

		Name "Water"
		CGPROGRAM
#pragma surface surf Standard fullforwardshadows alpha :fade

		struct Input {
		float2 uv_MainTex;
		float2 uv_Mask;
		float2 uv_FlowMap;
		float2 uv_BumpMap;

		float3 worldRefl;
		INTERNAL_DATA
	};
	sampler2D _MainTex, _Mask, _BumpMap;
	samplerCUBE _Cube;
	half _Smoothness,_Metallic;
	fixed _CutOff;

	void surf(Input IN, inout SurfaceOutputStandard o) {
		float4 mask = tex2D(_Mask, IN.uv_Mask);
		mask = smoothstep(mask, 0, _CutOff);
		//float4 floawMap = tex2D(_FLowMap, IN.uv_FlowMap);

		o.Normal = UnpackNormal(tex2D (_BumpMap, IN.uv_BumpMap));
		//o.Emission = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal)).rgb*mask;
		o.Metallic = _Metallic;
		o.Smoothness = _Smoothness;
		clip(mask);
		o.Alpha = mask;
	}
	ENDCG


	}
		Fallback "Diffuse"
}