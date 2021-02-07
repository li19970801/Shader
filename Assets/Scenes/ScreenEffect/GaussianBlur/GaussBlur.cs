﻿// ---------------------------【高斯模糊】---------------------------
using UnityEngine;

//编辑状态下也运行  
[ExecuteInEditMode]
//继承自PostEffectsbase
public class GaussBlur : PostEffectsBase {
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial = null;

    public Material material {
        get {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial (gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    //模糊半径  
    [Header("模糊半径")]
    [Range (0.2f, 3.0f)]
    public float BlurRadius = 1.0f;
    //降采样次数  
    [Header("降采样次数")]
    [Range (1, 8)]
    public int downSample = 2;
    //迭代次数  
    [Header("迭代次数")]
    [Range (0, 4)]
    public int iteration = 1;
    // [Range (0, 100)]
    // public float sigma = 1;
    //-----------------------------------------【Start()函数】---------------------------------------------    
    void Start () {
        //找到当前的Shader文件  
        gaussianBlurShader = Shader.Find ("lcl/screenEffect/gaussBlur");
    }

    //-------------------------------------【OnRenderImage函数】------------------------------------    
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    //--------------------------------------------------------------------------------------------------------  
    void OnRenderImage (RenderTexture source, RenderTexture destination) {
        if (material) {
            //申请RenderTexture，RT的分辨率按照downSample降低  
            RenderTexture rt1 = RenderTexture.GetTemporary (source.width >> downSample, source.height >> downSample, 0, source.format);
            RenderTexture rt2 = RenderTexture.GetTemporary (source.width >> downSample, source.height >> downSample, 0, source.format);

            //直接将原图拷贝到降分辨率的RT上  
            Graphics.Blit (source, rt1);

            //进行迭代高斯模糊  
            for (int i = 0; i < iteration; i++) {
                //第一次高斯模糊，设置offsets，竖向模糊  
                material.SetVector ("_offsets", new Vector4 (0, BlurRadius, 0, 0));
                // material.SetFloat ("_sigma", sigma);
                Graphics.Blit (rt1, rt2, material);
                //第二次高斯模糊，设置offsets，横向模糊  
                material.SetVector ("_offsets", new Vector4 (BlurRadius, 0, 0, 0));
                // material.SetFloat ("_sigma", sigma);
                Graphics.Blit (rt2, rt1, material);
            }

            //将结果输出  
            Graphics.Blit (rt1, destination);

            //释放申请的RenderBuffer
            RenderTexture.ReleaseTemporary (rt1);
            RenderTexture.ReleaseTemporary (rt2);
        }
    }
}