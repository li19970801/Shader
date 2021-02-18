// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Chapter6-Rotation"
{
	Properties
	{
		_RotateAngle("旋转的角度",Range(0,360))=36
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
 
		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			o.uv.y = 1 - o.uv.y;
			return o;
		}
 
		//坐标变换：旋转
		fixed4 frag(v2f i) : SV_Target
		{
			float2 r = 2.0 * (i.uv - 0.5);
			float aspectRatio = _ScreenParams.x / _ScreenParams.y;
			r.x *= aspectRatio;
 
			fixed3 bgCol = float3(1.0, 1.0, 1.0); // white
 
			fixed3 col1 = float3(0.216, 0.471, 0.698); // blue
			fixed3 col2 = float3(1.00, 0.329, 0.298); // red
			fixed3 col3 = float3(0.867, 0.910, 0.247); // yellow
 
			fixed3 ret;
			float2 q;
			float angle;
			//angle = 0.2*PI; // 旋转36度
			angle = _RotateAngle / PI;
			q.x = cos(angle)*r.x + sin(angle)*r.y;
			q.y = -sin(angle)*r.x + cos(angle)*r.y;
 
			ret = bgCol;
			// 画出这两个坐标系
 
			//底色浅一点为固定轴
			ret = lerp(ret, col1, coordinateGrid(r)*0.4);
 
			//要旋转的坐标轴
			ret = lerp(ret, col2, coordinateGrid(q));
 
			// 画出各种图形
 
			//在固定坐标系的图形
			ret = lerp(ret, col1, disk(r, float2(1.0, 0.0), 0.2));
			ret = lerp(ret, col1, rectangle(r, float2(-0.8, 0.2), float2(-0.5, 0.4)));
 
			//在可旋转坐标系的图形
			ret = lerp(ret, col2, disk(q, float2(1.0, 0.0), 0.2));			
			ret = lerp(ret, col2, rectangle(q, float2(-0.8, 0.2),float2(-0.5, 0.4)));
 
			fixed3 pixel = ret;
			return fixed4(pixel, 1.0);
		}
 
 
		ENDCG
		}
	}
}