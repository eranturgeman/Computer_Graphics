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

        //new points array will be: newPoints, facePoints, edgePoint
        int facePointsIndent = meshData.newPoints.Count;
        int edgePointsIndent = facePointsIndent + meshData.facePoints.Count;

        List<Vector3> newVertices = buildNewVerticesArray(meshData);
       
        List<Vector4> newQuads = buildNewQuadsArray(meshData, getRunningIndices(), facePointsIndent, edgePointsIndent);

        return new QuadMeshData(newVertices, newQuads);
    }


    private static List<Vector2> getRunningIndices()
    {
        List<Vector2> indices = new List<Vector2>();
        indices.Add(new Vector2(0, 2));
        indices.Add(new Vector2(0, 3));
        indices.Add(new Vector2(1, 2));
        indices.Add(new Vector2(1, 3));

        return indices;
    }


    //builds the new vertices array
    private static List<Vector3> buildNewVerticesArray(CCMeshData meshData)
    {
        List<Vector3> newVertices = meshData.newPoints;
        newVertices.AddRange(meshData.facePoints);
        newVertices.AddRange(meshData.edgePoints);
        return newVertices;
    }


    // builds the new quads array
    private static List<Vector4> buildNewQuadsArray(CCMeshData meshData, List<Vector2> indices, int facePointsIndent, int edgePointsIndent)
    {
        Dictionary<Tuple<int, int>, int> newPointFacePoint2EdgePoint = new Dictionary<Tuple<int, int>, int>();
        List<Vector4> newQuads = new List<Vector4>();

        for (int i = 0; i < meshData.edges.Count; ++i)
        {
            Vector4 edge = meshData.edges[i];
            foreach (Vector2 curInd in indices)
            {
                Tuple<int, int> key = new Tuple<int, int>((int)edge[(int)curInd[0]], (int)edge[(int)curInd[1]]);
                if (key.Item2 == NO_FACE)
                {
                    continue;
                }

                if (newPointFacePoint2EdgePoint.ContainsKey(key)) {
                    if (curInd[1] - curInd[0] != 2)
                    {
                        newQuads.Add(new Vector4(facePointsIndent + key.Item2, edgePointsIndent + i, key.Item1, edgePointsIndent + newPointFacePoint2EdgePoint[key]));
                    }
                    else
                    {
                        newQuads.Add(new Vector4(facePointsIndent + key.Item2, edgePointsIndent + newPointFacePoint2EdgePoint[key], key.Item1, edgePointsIndent + i));

                    }
                }
                else
                {
                    //if this is the first pair for this key
                    newPointFacePoint2EdgePoint[key] = i;
                }
            }

        }
        return newQuads;
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
                int v1 = (int)face[j];
                int v2 = (int)face[(j + 1) % 4];

                Tuple<int, int> key = new Tuple<int, int>(v1, v2);
                Tuple<int, int> revKey = new Tuple<int, int>(v2, v1);

                bool keyExists = pointsToFace.ContainsKey(key);
                bool revKeyExists = pointsToFace.ContainsKey(revKey);

                if (!(keyExists || revKeyExists))
                {
                    pointsToFace[key] = i;
                }
                if (revKeyExists)
                {
                    edges.Add(new Vector4(v2, v1, pointsToFace[revKey], i));
                    pointsToFace.Remove(revKey);
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
        List<Vector3> facePoints = new List<Vector3>();
        for(int i = 0; i < mesh.faces.Count; ++i)
        {
            Vector3 sumVertices = new Vector3();
            
            for(int j = 0; j < 4; ++j)
            {
                sumVertices += mesh.points[(int)mesh.faces[i][j]];
            }
            facePoints.Add(sumVertices / 4);
        }

        return facePoints; //ordered by mesh.faces array
    }

    // Returns a list of "edge points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetEdgePoints(CCMeshData mesh)
    {
        List<Vector3> edgePoints = new List<Vector3>();
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
                edgePoints.Add(sumVertices / 4);
            }
            else
            {
                edgePoints.Add(sumVertices / 3);
            }
        }
        return edgePoints; //ordered by mesh.edges
    }

    // Returns a list of new locations of the original points for the given CCMeshData, as described in the CC algorithm 
    public static List<Vector3> GetNewPoints(CCMeshData mesh)
    {
        Dictionary<int, Vector3> unnormalizedF2R = new Dictionary<int, Vector3>();
        int[] pointsToAdjacentCount = new int[mesh.points.Count]; //for each point- how many edges/faces touching it
        List<Vector3> newPoints = new List<Vector3>();

        addFComponent(mesh, unnormalizedF2R, pointsToAdjacentCount);

        add2RComponent(mesh, unnormalizedF2R);

        for (int i = 0; i < mesh.points.Count; ++i)
        {
            int n = pointsToAdjacentCount[i];
            Vector3 p = mesh.points[i];
            newPoints.Add(((unnormalizedF2R[i] / n) + ((n - 3) * p)) / n);
        }
        return newPoints; //ordered by mesh.points
    }

    // summing of all face points for each point (f component)
    private static void addFComponent(CCMeshData mesh, Dictionary<int, Vector3> unnormalizedF2R, int[] pointsToAdjacentCount)
    {
        for (int i = 0; i < mesh.faces.Count; ++i)
        {
            Vector4 face = mesh.faces[i];
            for (int j = 0; j < 4; ++j)
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
    }

    // summing of all edge midpoints (r components)
    private static void add2RComponent(CCMeshData mesh, Dictionary<int, Vector3> unnormalizedF2R)
    {
        for (int i = 0; i < mesh.edges.Count; ++i)
        {
            int p1 = (int)mesh.edges[i][0];
            int p2 = (int)mesh.edges[i][1];
            unnormalizedF2R[p1] += mesh.points[p1] + mesh.points[p2];
            unnormalizedF2R[p2] += mesh.points[p1] + mesh.points[p2];
        }
    }
}
