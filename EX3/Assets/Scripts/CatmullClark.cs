using System;
using System.Collections.Generic;
using UnityEngine;


public class CCMeshData
{
    public List<Vector3> points; // Original mesh points
    public List<Vector4> faces; // Original mesh quad faces
    public List<Vector4> edges; // Original mesh edges
    public List<Vector3> facePoints; // Face points, as described in the Catmull-Clark algorithm
    public List<Vector3> edgePoints; // Edge points, as described in the Catmull-Clark algorithm
    public List<Vector3> newPoints; // New locations of the original mesh points, according to Catmull-Clark
}


public static class CatmullClark
{
    private static int NO_FACE = -1;

    // Returns a QuadMeshData representing the input mesh after one iteration of Catmull-Clark subdivision.
    public static QuadMeshData Subdivide(QuadMeshData quadMeshData)
    {
        // Create and initialize a CCMeshData corresponding to the given QuadMeshData
        CCMeshData meshData = new CCMeshData();
        meshData.points = quadMeshData.vertices;
        meshData.faces = quadMeshData.quads;
        meshData.edges = GetEdges(meshData);
        meshData.facePoints = GetFacePoints(meshData);
        meshData.edgePoints = GetEdgePoints(meshData);
        meshData.newPoints = GetNewPoints(meshData);

        // Combine facePoints, edgePoints and newPoints into a subdivided QuadMeshData

        // Your implementation here...

        return new QuadMeshData();
    }

    // Returns a list of all edges in the mesh defined by given points and faces.
    // Each edge is represented by Vector4(p1, p2, f1, f2)
    // p1, p2 are the edge vertices
    // f1, f2 are faces incident to the edge. If the edge belongs to one face only, f2 is -1
    public static List<Vector4> GetEdges(CCMeshData mesh)
    {
        Dictionary<Tuple<int, int>, int> pointsToFace = new Dictionary<Tuple<int, int>, int>(); //dict mapping: (p1,p2)->face (by indices)
        List<Vector4> edges = new List<Vector4>();
        for(int i = 0; i < mesh.faces.Count; ++i)
        {
            Vector4 face = mesh.faces[i];
            for(int j = 0; j < 4; ++j)
            {
                int v1 = (int)Math.Min(face[j], face[(j + 1)%4]);
                int v2 = (int)Math.Max(face[j], face[(j + 1)%4]);

                Tuple<int, int> key = new Tuple<int, int>(v1, v2);
                if (pointsToFace.ContainsKey(key))
                {
                    edges.Add(new Vector4(v1, v2, pointsToFace[key], i));
                    pointsToFace.Remove(key);
                }
                else
                {
                    pointsToFace[key] = i;
                }
            }
        }

        foreach(KeyValuePair<Tuple<int, int>, int> entry in pointsToFace)
        {
            edges.Add(new Vector4(entry.Key.Item1, entry.Key.Item2, entry.Value, NO_FACE));
        }

        return edges; //p1 < p2 always, not necessarily for faces
    }

    // Returns a list of "face points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetFacePoints(CCMeshData mesh)
    {
        List<Vector3> facePoints = new List<Vector3>(mesh.faces.Count);
        for(int i = 0; i < mesh.faces.Count; ++i)
        {
            Vector3 sumVertices = new Vector3();
            
            for(int j = 0; j < 4; ++j)
            {
                sumVertices += mesh.points[(int)mesh.faces[i][j]];
            }
            facePoints[i] = sumVertices / 4;
        }

        return facePoints; //ordered by mesh.faces array
    }

    // Returns a list of "edge points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetEdgePoints(CCMeshData mesh)
    {
        List<Vector3> egdePoints = new List<Vector3>(mesh.edges.Count);
        for (int i = 0; i < mesh.edges.Count; ++i)
        {
            Vector3 sumVertices = new Vector3();

            sumVertices += mesh.points[(int)mesh.edges[i][0]];
            sumVertices += mesh.points[(int)mesh.edges[i][1]];
            sumVertices += mesh.facePoints[(int)mesh.edges[i][2]];
            int f2 = (int)mesh.edges[i][3];
            if(f2 != NO_FACE)
            {
                sumVertices += mesh.facePoints[f2];
                egdePoints[i] = sumVertices / 4;
            }
            else
            {
                egdePoints[i] = sumVertices / 3;
            }
        }
        return egdePoints;
    }

    // Returns a list of new locations of the original points for the given CCMeshData, as described in the CC algorithm 
    public static List<Vector3> GetNewPoints(CCMeshData mesh)
    {
        Dictionary<int, Vector3> unnormalizedF2R = new Dictionary<int, Vector3>();
        int[] pointsToAdjacentCount = new int[mesh.points.Count];
        List<Vector3> newPoints = new List<Vector3>(mesh.points.Count);

        //calculating f: later divide unnormlizedF(i) / pointsToAdjacentCount[i]
        for (int i = 0; i < mesh.faces.Count; ++i)
        {
            Vector4 face = mesh.faces[i];
            for(int j = 0; j < 4; ++j)
            {
                pointsToAdjacentCount[(int)face[j]] += 1;
                if (unnormalizedF2R.ContainsKey((int)face[j]))
                {
                    unnormalizedF2R[(int)face[j]] += mesh.facePoints[i];
                }
                else
                {
                    unnormalizedF2R[(int)face[j]] = mesh.facePoints[i];
                }
            } 
        }
        for(int i = 0; i < mesh.edges.Count; ++i)
        {
            int p1 = (int)mesh.edges[i][0];
            int p2 = (int)mesh.edges[i][1];
            unnormalizedF2R[p1] += mesh.points[p1] + mesh.points[p2];
            unnormalizedF2R[p2] += mesh.points[p1] + mesh.points[p2];
        }

        for (int i = 0; i < mesh.points.Count; ++i)
        {
            int n = pointsToAdjacentCount[i];
            Vector3 p = mesh.points[i];
            newPoints[i] = ((unnormalizedF2R[i] / n) + ((n - 3) * p)) / n;
        }
        return newPoints;
    }
}
