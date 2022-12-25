using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class BezierMesh : MonoBehaviour
{
    private BezierCurve curve; // The Bezier curve around which to build the mesh

    public float Radius = 0.5f; // The distance of mesh vertices from the curve
    public int NumSteps = 16; // Number of points along the curve to sample
    public int NumSides = 8; // Number of vertices created at each point

    // Awake is called when the script instance is being loaded
    public void Awake()
    {
        curve = GetComponent<BezierCurve>();
        BuildMesh();
    }

    // Returns a "tube" Mesh built around the given Bézier curve
    public static Mesh GetBezierMesh(BezierCurve curve, float radius, int numSteps, int numSides)
    { 
        List<Vector3> samplePoints = GetSamplePoints(curve, numSteps);

        List<Vector3> sidesPoints = GetSidesPoints(curve, samplePoints, radius, numSteps, numSides);

        List<Vector4> quads = GetQuads(curve, numSteps, numSides);

        return new QuadMeshData(sidesPoints, quads).ToUnityMesh();
    }

    private static List<Vector4> GetQuads(BezierCurve curve, int numSteps, int numSides)
    {
        List<Vector4> quads = new List<Vector4>();
        for (int i = 0; i < numSteps; ++i)
        {
            for (int j = 0; j < numSides; ++j)
            {
                int p1 = (i + 1) * numSides + ((j + 1) % numSides);
                int p2 = i * numSides + ((j + 1) % numSides);
                int p3 = i * numSides + j; 
                int p4 = (i + 1) * numSides + j;
                quads.Add(new Vector4(p1, p2, p3, p4));
            }
        }
        return quads;
    }

    private static List<Vector3> GetSidesPoints(BezierCurve curve, List<Vector3> samplePoints, float radius, int numSteps, int numSides)
    {
        List<Vector2> directionPoints = new List<Vector2>();
        for(int j = 0; j < numSides; ++j)
        {
            directionPoints.Add(GetUnitCirclePoint((360 / numSides) * j));
        }

        List<Vector3> sidesPoints = new List<Vector3>();
        for (int i = 0; i <= numSteps; ++i)
        {
            float t = (float)i / (float)numSteps;
            Vector3 normal = curve.GetNormal(t);
            Vector3 biNormal = curve.GetBinormal(t);

            foreach (Vector2 point in directionPoints)
            {
                Vector3 pointOnCircle = normal * point[1] + biNormal * point[0];
                sidesPoints.Add(samplePoints[i] + pointOnCircle * radius);
            }
        }
        return sidesPoints; //sidePoints is continuous list of side points, ordered by circles of sample points. for each sample point we have numSides countinuous cells with its points
    }

    private static List<Vector3> GetSamplePoints(BezierCurve curve, int numSteps)
    {
        List<Vector3> points = new List<Vector3>();
        
        for(int i = 0; i <= numSteps; ++i)
        {
            points.Add(curve.GetPoint((float)i / (float)numSteps));
        }
        return points;
    }


    // Returns 2D coordinates of a point on the unit circle at a given angle from the x-axis
    private static Vector2 GetUnitCirclePoint(float degrees)
    {
        float radians = degrees * Mathf.Deg2Rad;
        return new Vector2(Mathf.Sin(radians), Mathf.Cos(radians));
    }

    public void BuildMesh()
    {
        var meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh = GetBezierMesh(curve, Radius, NumSteps, NumSides);
    }

    // Rebuild mesh when BezierCurve component is changed
    public void CurveUpdated()
    {
        BuildMesh();
    }
}



[CustomEditor(typeof(BezierMesh))]
class BezierMeshEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        if (GUILayout.Button("Update Mesh"))
        {
            var bezierMesh = target as BezierMesh;
            bezierMesh.BuildMesh();
        }
    }
}