Shader "Unlit/ShiningShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Speed ("Speed", float) = 1
		_Slope ("Slope", float) = 1
		_Width ("Width", float) = 1
		_IntervalTime ("IntervalTime", float) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha  

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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Speed;
			float _Slope;
			float _Width;
			float _IntervalTime;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

				float delta = _Time.y * _Speed;
				float len = 2 * _Slope + _Speed * _IntervalTime;
				delta = delta - floor(delta / len) * len - _Slope;

				float result = max(((_Slope * i.uv.x + delta) - i.uv.y) / _Width, 0.0) * step(_Slope * i.uv.x + delta - _Width, i.uv.y);
				//float result = step(_Slope * i.uv.x - delta - _Width, i.uv.y) - step(_Slope * i.uv.x - delta, i.uv.y);
				col += 0.5 * result * col * step(1, col.a);

                return col;
            }
            ENDCG
        }
    }
}
