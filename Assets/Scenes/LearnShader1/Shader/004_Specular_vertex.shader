﻿//create by 长生但酒狂
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//高光反射 - 顶点着色器计算
Shader "lcl/learnShader1/004_Specular_vertex" {

	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Specular("_Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,200)) = 10
	}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			fixed4 _Diffuse;
			half _Gloss;
			fixed4 _Specular;


			struct a2v {
				float4 vertex : POSITION;
				float3 normal: NORMAL;
			};

			struct v2f{
				float4 position:SV_POSITION;
				fixed3 color:COLOR;
			};

			v2f vert(a2v v){
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 normalDir = normalize(mul(v.normal,(float3x3) unity_WorldToObject));
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
				//高光反射
				fixed3 reflectDir = reflect(-lightDir,normalDir);//反射光
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(v.vertex,unity_WorldToObject).xyz);
				fixed3 specular = _LightColor0.rgb * pow(max(0,dot(viewDir,reflectDir)),_Gloss) *_Specular;
				f.color = diffuse+ambient+specular;
				return f;
			};


			fixed4 frag(v2f f):SV_TARGET{
				return fixed4(f.color,1);
			};
		
			ENDCG
		}
	}
	FallBack "VertexLit"
}