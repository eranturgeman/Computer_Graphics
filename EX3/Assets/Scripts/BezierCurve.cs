﻿using System.Collections.Generic;
using System.Linq;
using UnityEngine;


public class BezierCurve : MonoBehaviour
{
    // Bezier control points
    public Vector3 p0;
    public Vector3 p1;
    public Vector3 p2;
    public Vector3 p3;

    private float[] cumLengths; // Cumulative lengths lookup table
    private readonly int numSteps = 128; // Number of points to sample for the cumLengths LUT

    // Returns position B(t) on the Bezier curve for given parameter 0 <= t <= 1
    public Vector3 GetPoint(float t)
    {
        Vector3 point = p0 * Mathf.Pow(1 - t, 3);
        point += 3 * t * Mathf.Pow(1 - t, 2) * p1;
        point += 3 * (1 - t) * t * t * p2;
        return point + Mathf.Pow(t, 3) * p3;
    }

    // Returns first derivative B'(t) for given parameter 0 <= t <= 1
    public Vector3 GetFirstDerivative(float t)
    {
        //simplified derevative
        return 3 * ((p3 - 3 * p2 + 3 * p1 - p0) * Mathf.Pow(t, 2) + 2 * (p2 - 2 * p1 + p0) * t + p1 - p0);
    }

    // Returns second derivative B''(t) for given parameter 0 <= t <= 1
    public Vector3 GetSecondDerivative(float t)
    {
        //simplified derevative
        return 6 * ((p3 - 3 * p2 + 3 * p1 - p0) * t + p2 - 2 * p1 + p0);
    }

    // Returns the tangent vector to the curve at point B(t) for a given 0 <= t <= 1
    public Vector3 GetTangent(float t)
    {
        return GetFirstDerivative(t).normalized;
    }

    // Returns the Frenet normal to the curve at point B(t) for a given 0 <= t <= 1
    public Vector3 GetNormal(float t)
    {
        return Vector3.Cross(GetTangent(t), GetBinormal(t)).normalized;
    }

    // Returns the Frenet binormal to the curve at point B(t) for a given 0 <= t <= 1
    public Vector3 GetBinormal(float t)
    {
        Vector3 tTag = (GetFirstDerivative(t) + GetSecondDerivative(t)).normalized;
        Vector3 tangent = GetTangent(t);
        return Vector3.Cross(tangent, tTag).normalized;
    }

    // Calculates the arc-lengths lookup table
    public void CalcCumLengths()
    {
        // Your implementation here...
    }

    // Returns the total arc-length of the Bezier curve
    public float ArcLength()
    {
        return 0;
    }

    // Returns approximate t s.t. the arc-length to B(t) = arcLength
    public float ArcLengthToT(float a)
    {
        return 0;
    }

    // Start is called before the first frame update
    public void Start()
    {
        Refresh();
    }

    // Update the curve and send a message to other components on the GameObject
    public void Refresh()
    {
        CalcCumLengths();
        if (Application.isPlaying)
        {
            SendMessage("CurveUpdated", SendMessageOptions.DontRequireReceiver);
        }
    }

    // Set default values in editor
    public void Reset()
    {
        p0 = new Vector3(1f, 0f, 1f);
        p1 = new Vector3(1f, 0f, -1f);
        p2 = new Vector3(-1f, 0f, -1f);
        p3 = new Vector3(-1f, 0f, 1f);

        Refresh();
    }
}



