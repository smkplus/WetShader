Shader "Kamaly/WetShader" {
	Properties{
		_MainTex("MainTex",2D) = "white"{}
		_Distortion("Distortion",2D) = "white"{}
		_Cube("Cubemap", CUBE) = "" {}
		_BumpMap("Bumpmap", 2D) = "bump" {}
	_Metallic("Metallic",Range(0,1)) = 0
		_Smoothness("Smoothness",Range(0,1)) = 1
		_ReflectAlpha("ReflectAlpha",Range(0,1)) = 1
		scaleX("UV.X scale",Float) = 10.0
		scaleY("UV.Y scale",Float) = 10.0
		_Smooth("Smooth",Float) = 0.4
		_Intensity("Intensity",Float) = 1
	}
		SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 200
		Pass{
		ColorMask 0
	}
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB

		CGPROGRAM
#pragma surface surf Standard fullforwardshadows alpha:fade

		struct Input {
		float2 uv_MainTex;
		float2 uv_Distortion;
		float3 worldRefl;
		float2 uv_BumpMap;
		INTERNAL_DATA
	};
	sampler2D _MainTex, _Distortion;
	samplerCUBE _Cube;
	float _Metallic;
	float _Smoothness;
	float4 _EmissionColor;
	float _Alpha;
	float _ReflectAlpha;
	sampler2D _NormalMap;
	uniform fixed scaleX, scaleY, _Smooth, _Intensity;

	static const float2x2 m = float2x2(-0.5, 0.8, 1.7, 0.2);

	float hash(float2 n)
	{
		return frac(sin(dot(n, float2(95.43583, 93.323197))) * 65536.32);
	}

	float noise(float2 p)
	{
		float2 i = floor(p);
		float2 u = frac(p);
		u = u*u*(3.0 - 2.0*u);
		float2 d = float2 (1.0, 0.0);
		float r = lerp(lerp(hash(i), hash(i + d.xy), u.x), lerp(hash(i + d.yx), hash(i + d.xx), u.x), u.y);
		return r*r;
	}

	float fbm(float2 p)
	{
		float f = 0.0;
		f += 0.500000*(0.5 + 0.5*noise(p));
		return f;
	}

	float fbm2(float2 p)
	{
		float f = 0.0;
		f += 0.500000*(0.6 + 0.45*noise(p)); p = p*2.02; p = mul(p, m);
		f += 0.250000*(0.6 + 0.36*noise(p));
		return f;
	}


	void surf(Input IN, inout SurfaceOutputStandard o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

		
		o.Metallic = _Metallic;
		o.Smoothness = _Smoothness;
		//o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_BumpMap));
		o.Alpha = 1;

		float t = fbm2(float2(IN.uv_MainTex.x*scaleX, IN.uv_MainTex.y*scaleY));

		float4 distortion = tex2D(_Distortion, IN.uv_Distortion);

		float fbmMask = smoothstep(t, 0.05, _Smooth)*_Intensity;
			o.Albedo = c.rgb * 0.5*fbmMask;
			o.Emission = texCUBE(_Cube, IN.worldRefl*distortion).rgb*_ReflectAlpha*fbmMask;
		
			o.Albedo = float4(1.0, 1.0, 1.0, 1.0)*tex2Dlod(_MainTex, float4(IN.uv_MainTex, 0.0, 0.0));
		

	}
	ENDCG
	}
		Fallback "Diffuse"
}