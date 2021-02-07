// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/learnShader2/009_Water" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_Magnitude ("Distortion Magnitude", Float) = 1
 		_Frequency ("Distortion Frequency", Float) = 1
 		_InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
 		_Speed ("Speed", Float) = 0.5
	}
	SubShader {
		// Need to disable batching because of the vertex animation
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
		
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			
			CGPROGRAM  
			#pragma vertex vert 
			#pragma fragment frag
			
			#include "UnityCG.cginc" 
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
				v2f o;
				
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				//offset.x=v.vertex.x*_InvWaveLength;
				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				o.pos = UnityObjectToClipPos(v.vertex + offset);
				//o.pos = UnityObjectToClipPos(v.vertex );
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);//等价于o.uv = v.texcoord.xy;  等价于u//o.uv=v.texcoord.xy*_MainTex_ST+_MainTex_ST.zw;TRANSFORM_TEX主要作用是拿顶点的uv去和材质球的tiling和offset做运算，确保材质球里的缩放和偏移设置是正确的
				o.uv +=  float2(0.0, _Time.y * _Speed);//对uv进行操作

				o.uv.xy=TRANSFORM_TEX(v.texcoord,_MainTex)+frac(float2(_Speed,0.0)*_Time.y);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				return c;
			} 
			
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
