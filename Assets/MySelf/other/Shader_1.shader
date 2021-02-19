Shader "Unlit/Shader_1"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_MainTexture("Main Texture",2D) = "white"{}
		_DissolveTexture("DissolveTexture",2D) = "whiter"{}
		_DissolveCutoff("DissolveCutoff",Range(0,1)) = 1
		_ExtrudeAmount("Extrue Amount",float)=0
	}
		SubShader
	{
		Pass{
		CGPROGRAM
		#pragma vertex vertexFunction//顶点函数
		#pragma fragment fragmentFunction//片元函数
		#pragma enable_d3d11_debug_symbols
		#include "UnityCG.cginc"

		//从CG中获取属性
		float4 _Color;
		sampler2D _MainTexture;
		sampler2D _DissolveTexture;
		float _DissolveCutoff;
		float _ExtrudeAmount;
		//将a2v作为参数传递给顶点函数
		struct a2v
		{
			float4 vertex:POSITION;//获取顶点坐标
			float2 uv:TEXCOORD0;//获取UV纹理坐标
			float3 normal:NORMAl;//获取模型的法线
		};
	//代表从vertex to fragment 顶点数据传递到片元 将vertex中包含的数据传递到片元函数 同时确保 vertexFunction返回v2f的数据类型 在我们使用它时穿件并返回一个空白数据
		struct v2f
		{
			float4 position:SV_POSITION;//SV代表"System value" 在v2f结构中表示最终渲染的顶点的位置
			float2 uv:TEXCOORD0;
		};
	//当传递一个参数到vertexFunction中，unity将解析这个函数的结构体，并基于正在绘制的对象模型传递值。我们可以传递一些自定义的数据，即 a2v
		v2f vertexFunction(a2v v)
		{
			v2f o;
			//在将顶点转换成模型空间之前，我们将通过增加他们的法线方向来抵消他们的外加量  _Time代表是的变量被包含在UnityCG.cginc中 y代表秒
			//_Time是一个四维变量(x,y,z,w) (t/20,t,t*2,t*3),其中t是秒
			v.vertex.xyz+=v.normal.xyz*_ExtrudeAmount*sin(_Time.y);
			o.position = UnityObjectToClipPos(v.vertex);//获取点点的位置  这个函数的作用是将世界空间的模型坐标转换到裁剪空间 函数内部封装了实现顶点坐标变换的具体细节
			o.uv = v.uv;
	
			return o;
		}
		//输出的片元函数是一个有(R,G,B,A)代表的颜色值 最后为片元函数添加一个SV_TARFER的输出语义  float4和fixed4的区别是精度的区别 float4的精度更高计算是消耗更大
		fixed4  fragmentFunction(v2f i):SV_TARGET
		{
			float4 textureColor = tex2D(_MainTexture,i.uv);//tex2D()用来在一张贴图中对一个点进行采样的方法。返回一个float4  
			float4 dissolveColor = tex2D(_DissolveTexture, i.uv);
			clip(dissolveColor.rgb-_DissolveCutoff);//clip函数检查这个给定的值是否小于0，如果小于0就不进行绘制，如果大于0就正常的绘制

			//clip(dissolveColor.rgb - _DissolveCutoff);
			//return tex2D(_MainTexture,i.uv);//
			return textureColor*_Color;
		}




		ENDCG
		}
	}
}
