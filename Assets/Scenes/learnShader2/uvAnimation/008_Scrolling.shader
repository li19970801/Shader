// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lcl/learnShader2/Scrolling" {
	Properties {
		_MainTex ("Base Layer (RGB)", 2D) = "white" {}
		_DetailTex ("2nd Layer (RGB)", 2D) = "white" {}
		_ScrollX ("Base layer Scroll Speed", Float) = 1.0
		_Scroll2X ("2nd layer Scroll Speed", Float) = 1.0
		_Multiplier ("Layer Multiplier", Float) = 1
		_Color("Color",Color)=(1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _DetailTex;
			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;
			float4 _Color;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			}; //��˼�����ݴ�Ӧ�ý׶δ��ݵ�������ɫ���С�
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};
			
			float fract(float x) {
				return x-floor(x);
			}

			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.x = TRANSFORM_TEX(v.texcoord, _MainTex).x + frac(_ScrollX*_Time.y);
				o.uv.y = TRANSFORM_TEX(v.texcoord, _MainTex).y;
				//frac�������ر�������ÿ��ʸ���и�������С������
				//o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0).x * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
				//o.uv=v.texcoord;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
				fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
				//fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);//lerp(a,b,w)����w����a��b֮��Ĳ�ֵ���൱��return a+w*(b-a)
				fixed4 c = secondLayer*secondLayer.a + firstLayer*(1-secondLayer.a);

				//fixed4 c=tex2D(_MainTex,i.uv);
				//c.rgb *= _Multiplier;
				
				return c;
			}
			
			ENDCG
		}
	}
	FallBack "VertexLit"
}
