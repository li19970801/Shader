// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/xuanzhuan"
{
	Properties
	{
		_SpeedX("_SpeedX",Range(0,1))=0
		_SpeedY("_SpeedY",Range(0,1))=0
		_SpeedZ("_SpeedZ",Range(0,1))=0
		_MainTex("Main Texture",2D) = "white"{}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
 
		// 
		CGINCLUDE
 
		#define PI 3.14159
 
		// 使用函数来创建网格，返回的值再乘以颜色及得到网格图形
		float coordinateGrid(float2 r) 
		{
			//float3 axisCol = float3(0.0, 0.0, 1.0);
			//float3 gridCol = float3(0.5, 0.5, 0.5);
			float ret = 0.0;
 
			// 画线
			const float tickWidth = 0.1;
			for (float i = -2.0; i<2.0; i += tickWidth) {
				ret += 1.0 - smoothstep(0.0, 0.008, abs(r.x - i));
				ret += 1.0 - smoothstep(0.0, 0.008, abs(r.y - i));
			}
 
			// 画坐标轴
			ret += 1.0 - smoothstep(0.001, 0.015, abs(r.x));
			ret += 1.0 - smoothstep(0.001, 0.015, abs(r.y));
			return ret;
		}
 
	// 在圆盘里面的都返回1
	float disk(float2 r, float2 center, float radius) {
		return 1.0 - smoothstep(radius - 0.005, radius + 0.005, length(r - center));
	}
 
	// 在长方形里面的都返回1
	float rectangle(float2 r, float2 bottomLeft, float2 topRight) {
		float ret;
		float d = 0.005;
		ret = smoothstep(bottomLeft.x - d, bottomLeft.x + d, r.x);
		ret *= smoothstep(bottomLeft.y - d, bottomLeft.y + d, r.y);
		ret *= 1.0 - smoothstep(topRight.y - d, topRight.y + d, r.y);
		ret *= 1.0 - smoothstep(topRight.x - d, topRight.x + d, r.x);
		return ret;
	}
	ENDCG
 
 
	Pass
	{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
 
		#include "UnityCG.cginc"

		float _SpeedX;
		float _SpeedY;
		float _SpeedZ;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		
		uniform float _RotateAngle;
		
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
 
		 
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.vertex += float4(_SpeedX, _SpeedY, 0, _SpeedZ)*_Time.y;
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv=v.uv;
				
				return o;
			}
 
					fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed2 UV = i.uv;
				fixed xV = _SpeedX * _Time.x;
				fixed yV = _SpeedY * _Time.y;
				UV += fixed2(xV, yV);
				fixed4 col = tex2D(_MainTex, UV);
				return col;
			}
 
		ENDCG
		}
	}
}