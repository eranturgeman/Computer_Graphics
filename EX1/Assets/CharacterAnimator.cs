using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterAnimator : MonoBehaviour
{
    public TextAsset BVHFile; // The BVH file that defines the animation and skeleton
    public bool animate; // Indicates whether or not the animation should be running
    public bool interpolate; // Indicates whether or not frames should be interpolated
    [Range(0.01f, 2f)] public float animationSpeed = 1; // Controls the speed of the animation playback

    public BVHData data; // BVH data of the BVHFile will be loaded here
    public float t = 0; // Value used to interpolate the animation between frames
    public float[] currFrameData; // BVH channel data corresponding to the current keyframe
    public float[] nextFrameData; // BVH vhannel data corresponding to the next keyframe

    public static float DIAMETER = 0.6f;

    // Start is called before the first frame update
    void Start()
    {
        BVHParser parser = new BVHParser();
        data = parser.Parse(BVHFile);
        CreateJoint(data.rootJoint, Vector3.zero);
    }

    // Returns a Matrix4x4 representing a rotation aligning the up direction of an object with the given v
    public Matrix4x4 RotateTowardsVector(Vector3 v)
    {
        v = v.normalized;
        double thetaX = 90 - (Mathf.Rad2Deg * Mathf.Atan2(v[1], v[2]));
        Matrix4x4 Rx = MatrixUtils.RotateX((float)-thetaX);

        double thetaZ = 90 - (Mathf.Rad2Deg * Mathf.Atan2(Mathf.Sqrt((v[1] * v[1]) + (v[2] * v[2])), v[0]));
        Matrix4x4 Rz = MatrixUtils.RotateZ((float)thetaZ);
        return (Rz * Rx).inverse;
    }

    // Creates a Cylinder GameObject between two given points in 3D space
    public GameObject CreateCylinderBetweenPoints(Vector3 p1, Vector3 p2, float diameter)
    {
        GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        double distance = Vector3.Distance(p1, p2) / 2;
        Matrix4x4 scaleMatrix = MatrixUtils.Scale(new Vector3(diameter, (float)distance, diameter));

        Matrix4x4 rotationMatrix = RotateTowardsVector(p2 - p1);

        Matrix4x4 translationMatrix = MatrixUtils.Translate(p2 + (p1 - p2)/2);

        MatrixUtils.ApplyTransform(cylinder, translationMatrix * rotationMatrix * scaleMatrix);

        return cylinder;
    }

    // Creates a GameObject representing a given BVHJoint and recursively creates GameObjects for it's child joints
    public GameObject CreateJoint(BVHJoint joint, Vector3 parentPosition)
    {
        joint.gameObject = new GameObject(joint.name);
        GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        sphere.transform.parent = joint.gameObject.transform;
        Vector3 scaleVec;
        scaleVec = joint.name == "Head" ? new Vector3(8, 8, 8) : new Vector3(2, 2, 2);
   
        Matrix4x4 scaleMatrix = MatrixUtils.Scale(scaleVec);
        MatrixUtils.ApplyTransform(sphere, scaleMatrix);

        Vector3 newPosition = parentPosition + joint.offset;
        Matrix4x4 translationMatrix = MatrixUtils.Translate(newPosition);
        MatrixUtils.ApplyTransform(joint.gameObject, translationMatrix);

        foreach (BVHJoint child in joint.children)
        {
            CreateJoint(child, newPosition);
            GameObject cylinder = CreateCylinderBetweenPoints(newPosition, newPosition + child.offset, DIAMETER);
            cylinder.transform.parent = joint.gameObject.transform;
            
        }
        return joint.gameObject;
    }


    

    // Transforms BVHJoint according to the keyframe channel data, and recursively transforms its children
    public void TransformJoint(BVHJoint joint, Matrix4x4 parentTransform)
    {
        if (joint.isEndSite)
        {
            MatrixUtils.ApplyTransform(joint.gameObject, parentTransform * MatrixUtils.Translate(joint.offset));
            return;
        }

        Matrix4x4 finalMat = parentTransform;

        //translation
        finalMat = finalMat * GetTranslationMatrix(joint);

        // rotation
        finalMat = finalMat * GetRotationMatrix(joint);

        MatrixUtils.ApplyTransform(joint.gameObject, finalMat);
        foreach (BVHJoint child in joint.children)
        {
            TransformJoint(child, finalMat);
        }
    }

    // Returns the frame nunmber of the BVH animation at a given time
    public int GetFrameNumber(float time)
    {
        return (int)(time / data.frameLength) % data.numFrames;
    }

    // Returns the proportion of time elapsed between the last frame and the next one, between 0 and 1
    public float GetFrameIntervalTime(float time)
    {
        return (time % data.frameLength) / data.frameLength;
    }

    // Update is called once per frame
    void Update()
    {
        float time = Time.time * animationSpeed;
        if (animate)
        {
            int currFrame = GetFrameNumber(time);
            t = GetFrameIntervalTime(time);
            currFrameData = data.keyframes[currFrame];
            if (currFrame + 1 != data.numFrames)
            {
                nextFrameData = data.keyframes[currFrame + 1];
            }
            TransformJoint(data.rootJoint, Matrix4x4.identity);
        }
    }

    //produces rotation matrix
    private Matrix4x4 GetRotationMatrix(BVHJoint joint)
    {
        Matrix4x4[] rotationMats = new Matrix4x4[3];
        Matrix4x4[] orderdRotationMats = new Matrix4x4[3];
        Matrix4x4 rotationMat = Matrix4x4.identity;
        Vector3 curAngles = new Vector3();
        Vector3 nextAngles = new Vector3();

        if (interpolate)
        {
            //cur frame quaternions
            curAngles[0] = currFrameData[joint.rotationChannels.x];
            curAngles[1] = currFrameData[joint.rotationChannels.y];
            curAngles[2] = currFrameData[joint.rotationChannels.z];
            Vector4 curQ = QuaternionUtils.FromEuler(curAngles, joint.rotationOrder).normalized;

            //next frame quaternions
            nextAngles[0] = nextFrameData[joint.rotationChannels.x];
            nextAngles[1] = nextFrameData[joint.rotationChannels.y];
            nextAngles[2] = nextFrameData[joint.rotationChannels.z];
            Vector4 nextQ = QuaternionUtils.FromEuler(nextAngles, joint.rotationOrder).normalized;

            //slerp
            Vector4 slerped = QuaternionUtils.Slerp(curQ, nextQ, t).normalized;
            rotationMat = MatrixUtils.RotateFromQuaternion(slerped);
        }
        else
        {
            rotationMats[0] = MatrixUtils.RotateX(currFrameData[joint.rotationChannels.x]);
            rotationMats[1] = MatrixUtils.RotateY(currFrameData[joint.rotationChannels.y]);
            rotationMats[2] = MatrixUtils.RotateZ(currFrameData[joint.rotationChannels.z]);
            for (int i = 0; i < 3; i++)
            {
                orderdRotationMats[joint.rotationOrder[i]] = rotationMats[i];
            }
            foreach (Matrix4x4 mat in orderdRotationMats)
            {
                rotationMat = rotationMat * mat;
            }
        }
        return rotationMat;
    }

    //produces translation matrix
    private Matrix4x4 GetTranslationMatrix(BVHJoint joint)
    {
        if (joint == data.rootJoint)
        {
            Vector3 translationParms = new Vector3();
            translationParms[0] = currFrameData[joint.positionChannels.x];
            translationParms[1] = currFrameData[joint.positionChannels.y];
            translationParms[2] = currFrameData[joint.positionChannels.z];
            if (interpolate)
            {
                Vector3 translationParmsNext = new Vector3();
                translationParmsNext[0] = nextFrameData[joint.positionChannels.x];
                translationParmsNext[1] = nextFrameData[joint.positionChannels.y];
                translationParmsNext[2] = nextFrameData[joint.positionChannels.z];
                translationParms = Vector3.Lerp(translationParms, translationParmsNext, t);
            }

            return MatrixUtils.Translate(translationParms);
        }
        else
        {
            return MatrixUtils.Translate(joint.offset);
        }
    }
}
