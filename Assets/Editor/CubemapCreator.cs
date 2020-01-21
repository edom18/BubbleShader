using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CubemapCreator
{
    [MenuItem("Assets/Create/CubeMap/128x128")]
    static public void CreateCubeMap128()
    {
        CreateCubeMap(128);
    }

    [MenuItem("Assets/Create/CubeMap/256x256")]
    static public void CreateCubeMap256()
    {
        CreateCubeMap(256);
    }

    [MenuItem("Assets/Create/CubeMap/512x512")]
    static public void CreateCubeMap512()
    {
        CreateCubeMap(512);
    }

    static private void CreateCubeMap(int px)
    {
        // Set reflection probe.
        GameObject probeGo = new GameObject("CubeMap Capture Probe");
        ReflectionProbe probe = probeGo.AddComponent<ReflectionProbe>();
        SerializedObject probeSo = new SerializedObject(probe);
        probeGo.transform.position = Vector3.zero;
        probeGo.transform.rotation = Quaternion.identity;

        // Some Settings here if you want.
        probe.mode = UnityEngine.Rendering.ReflectionProbeMode.Custom;
        probe.resolution = px;
        probe.hdr = false;
        probe.boxProjection = false;

        probeSo.Update();
        probeSo.FindProperty("m_RenderDynamicObjects").boolValue = true;
        probeSo.ApplyModifiedProperties();

        // Create default path.
        string ext = probe.hdr ? "exr" : "png";
        string path = UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene().path;

        if (!string.IsNullOrEmpty(path))
        {
            path = System.IO.Path.GetDirectoryName(path);
        }

        if (string.IsNullOrEmpty(path))
        {
            path = "Assets";
        }
        else if (System.IO.Directory.Exists(path))
        {
            System.IO.Directory.CreateDirectory(path);
        }

        // Show the file saving panel.
        string filename = "name" + ext;
        filename = System.IO.Path.GetFileNameWithoutExtension(AssetDatabase.GenerateUniqueAssetPath(System.IO.Path.Combine(path, filename)));
        path = EditorUtility.SaveFilePanelInProject("Save CubeMap", filename, ext, "", path);

        if (!string.IsNullOrEmpty(path))
        {
            // Bake
            EditorUtility.DisplayProgressBar("CubeMap", "Baking...", 0.5f);
            if (!Lightmapping.BakeReflectionProbe(probe, path))
            {
                Debug.LogError("Failed to bake cubemap");
            }
            EditorUtility.ClearProgressBar();
        }

        GameObject.DestroyImmediate(probeGo);
    }
}
