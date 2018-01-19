using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class RenderToImage : MonoBehaviour {
    public RenderTexture RTex;
    public Texture2D tex;
    public Material mat;

    void Update()
    {
        Graphics.Blit(tex, RTex, mat);
    }
}