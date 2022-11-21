﻿using System;
using UnityEngine;

public class QuaternionUtils
{
    // The default rotation order of Unity. May be used for testing
    public static readonly Vector3Int UNITY_ROTATION_ORDER = new Vector3Int(1,2,0);

    // Returns the product of 2 given quaternions
    public static Vector4 Multiply(Vector4 q1, Vector4 q2)
    {
        return new Vector4(
            q1.w*q2.x + q1.x*q2.w + q1.y*q2.z - q1.z*q2.y,
            q1.w*q2.y + q1.y*q2.w + q1.z*q2.x - q1.x*q2.z,
            q1.w*q2.z + q1.z*q2.w + q1.x*q2.y - q1.y*q2.x,
            q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z
        );
    }

    // Returns the conjugate of the given quaternion q
    public static Vector4 Conjugate(Vector4 q)
    {
        return new Vector4(-q.x, -q.y, -q.z, q.w);
    }

    // Returns the Hamilton product of given quaternions q and v
    public static Vector4 HamiltonProduct(Vector4 q, Vector4 v)
    {
        return Multiply(Multiply(q, v), Conjugate(q));
    }

    // Returns a quaternion representing a rotation of theta degrees around the given axis
    public static Vector4 AxisAngle(Vector3 axis, float theta)
    {
        return new Vector4(
            Mathf.Sin(Mathf.Deg2Rad * theta / 2) * axis.x,
            Mathf.Sin(Mathf.Deg2Rad * theta / 2) * axis.y,
            Mathf.Sin(Mathf.Deg2Rad * theta / 2) * axis.z,
            Mathf.Cos(Mathf.Deg2Rad * theta / 2)).normalized;
    }

    // Returns a quaternion representing the given Euler angles applied in the given rotation order
    public static Vector4 FromEuler(Vector3 euler, Vector3Int rotationOrder)
    {
        Vector4[] rotationVectors = new Vector4[3];
        Vector4[] orderedVectors = new Vector4[3];
        rotationVectors[0] = AxisAngle(Vector3.right, euler.x);
        rotationVectors[1] = AxisAngle(Vector3.up, euler.y);
        rotationVectors[2] = AxisAngle(Vector3.forward, euler.z);

        for(int i = 0; i < 3; i++)
        {
            orderedVectors[rotationOrder[i]] = rotationVectors[i];
        }

        return Multiply(Multiply(orderedVectors[0], orderedVectors[1]), orderedVectors[2]);
    }

    //returns half the angle between q1 and q2
    private static float AngleBetweenQuaternions(Vector4 q1, Vector4 q2)
    {
        Vector4 quatMult = Multiply(q1, Conjugate(q2));
        float theta = 2 * Mathf.Acos(Mathf.Clamp(quatMult.w, -1, 1));
        return theta > Mathf.PI ? (2 * Mathf.PI - theta) / 2 : theta / 2;
    }

    // Returns a spherically interpolated quaternion between q1 and q2 at time t in [0,1]
    public static Vector4 Slerp(Vector4 q1, Vector4 q2, float t)
    {
        float theta = AngleBetweenQuaternions(q1, q2);

        if (Mathf.Sin(theta) == 0)
        {
            return q1;
        }

        float firstParam = Mathf.Sin((1 - t) * theta) / Mathf.Sin(theta);
        float secondParam = Mathf.Sin(t * theta) / Mathf.Sin(theta);

        return firstParam * q1 + secondParam * q2;
    }
}