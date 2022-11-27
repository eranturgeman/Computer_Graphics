using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class MeshData
{
    public List<Vector3> vertices; // The vertices of the mesh 
    public List<int> triangles; // Indices of vertices that make up the mesh faces
    public Vector3[] normals; // The normals of the mesh, one per vertex

    // Class initializer
    public MeshData()
    {
        vertices = new List<Vector3>();
        triangles = new List<int>();
    }

    // Returns a Unity Mesh of this MeshData that can be rendered
    public Mesh ToUnityMesh()
    {
        Mesh mesh = new Mesh
        {
            vertices = vertices.ToArray(),
            triangles = triangles.ToArray(),
            normals = normals
        };

        return mesh;
    }

    // Calculates surface normals for each vertex, according to face orientation
    public void CalculateNormals()
    {
        //list containing for each vertex 3 normals of the surfaces touching the vertex
        List<List<Vector3>> vertexSurfaceNormals = new List<List<Vector3>>(vertices.Count);
        normals = new Vector3[vertices.Count];

        for (int i = 0; i < vertices.Count; i++)
        {
            vertexSurfaceNormals.Add(new List<Vector3>());
        }

        for (int i = 0; i < triangles.Count; i += 3)
        {
            Vector3 v1 = vertices[triangles[i]];
            Vector3 v2 = vertices[triangles[i + 1]];
            Vector3 v3 = vertices[triangles[i + 2]];
            Vector3 surfaceNormal = GetSurfaceNormal(v1, v2, v3);

            vertexSurfaceNormals[triangles[i]].Add(surfaceNormal);
            vertexSurfaceNormals[triangles[i + 1]].Add(surfaceNormal);
            vertexSurfaceNormals[triangles[i + 2]].Add(surfaceNormal);
        }
        for(int i = 0; i < vertices.Count; i++)
        {
            List<Vector3> vertexNormals = vertexSurfaceNormals[i];
            normals[i] = (vertexNormals[0] + vertexNormals[1] + vertexNormals[2]).normalized;
        }
    }

    // Edits mesh such that each face has a unique set of 3 vertices
    public void MakeFlatShaded()
    {
        // Your implementation
    }

    // returns a normalized surface normal for the surface composed by v1, v2 and v3
    private Vector3 GetSurfaceNormal(Vector3 v1, Vector3 v2, Vector3 v3)
    {
        return Vector3.Cross(v1 - v3, v2 - v3).normalized;
    }
}