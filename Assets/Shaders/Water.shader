Shader "Unlit/Fbm"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	_Size("Size",Float) = 1 
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};




float random (in fixed2 st) {
    return frac(sin(dot(st.xy,
                         fixed2(12.9898,78.233)))*
        43758.5453123);
}

float noise (in fixed2 st) {
    fixed2 i = floor(st);
    fixed2 f = frac(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + fixed2(1.0, 0.0));
    float c = random(i + fixed2(0.0, 1.0));
    float d = random(i + fixed2(1.0, 1.0));

    fixed2 u = f * f * (3.0 - 2.0 * f);

    return lerp(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define OCTAVES 6
float fbm (in fixed2 st) {
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st *= 2.;
        amplitude *= .5;
    }
    return value;
}


			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Size;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);



    fixed2 st = i.uv;

    fixed3 color = fixed3(0,0,0);
    color += fbm(st*_Size);

    float4 result = fixed4(color,1.0);
	float4 dissolve = smoothstep(result.x,0.1,0.45);


				return dissolve;
			}
			ENDCG
		}
	}
}
