// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SingleTexture"
{
    Properties
    {
        _Color("Color Tint",Color)=(1,1,1,1)
		_MainTex("Mian Tex",2D)="white"{}
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8,256))=20
    }
    SubShader
    {
       Pass
	   {
	   Tags{"LightMode"="ForwardBase"}
	   CGPROGRAM
	   #pragma vertex vert
	   #pragma fragment frag
	   #include "Lighting.cginc"

	   fixed4 _Color;
	   sampler2D _MainTex;
	   float4 _MainTex_ST;
	   fixed4 _Specular;
	   float _Gloss;


	   struct a2v{
	   float4 vertex :POSITION;
	   float3 normal:NORMAL;
	   float4 texcoord:TEXCOORD0;//使用语义声明了一个新的变量，这样unity就会将模型的第一组纹理坐标储存在改变量中
	   };
	   struct v2f{
	   float4 pos:SV_POSITION;
	   float3 worldNormal:TEXCOORD0;
	   float3 worldPos:TEXCOORD1;
	   float2 uv:TEXCOORD2;//用于储存纹理坐标的变量uv,以便在片元着色器中使用该坐标进行纹理采样
	   };
	   v2f vert(a2v v)
	   {
			v2f o;
			o.pos=UnityObjectToClipPos(v.vertex);
			o.worldNormal=UnityObjectToWorldNormal(v.normal);
			o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
			o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
			return o;
	   }
	   fixed4 frag(v2f i):SV_Target
	   {
			fixed3 worldNormal=normalize(i.worldNormal);
			fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
			fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;//对贴图进行采样
			fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//环境光
			fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));//漫反射
			fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
			fixed3 halfDir=normalize(worldLightDir+viewDir);
			fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);//反射
			return fixed4(ambient+diffuse+specular ,1.0);
	   }
	   ENDCG
	   }
    }
    FallBack "Specular"
}
