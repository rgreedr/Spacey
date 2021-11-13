#include <HLSLSupport.cginc>
#include <UnityCG.cginc>


// ================================================================
// ========================= CLIP TO _ ============================
// ================================================================
//
// vertex function
inline float4 thc_clip_to_screen_position(float4 clipPosition)
{
    return ComputeScreenPos(clipPosition);
}

// ================================================================
// ========================= TANGENT TO _ =========================
// ================================================================
// vertex function
inline float4x4 thc_tangent_to_world_matrix(float3 normal, float4 tangent)
{
    fixed3 worldNormal = UnityObjectToWorldNormal(normal);
    fixed3 worldTangent = UnityObjectToWorldDir(tangent.xyz);
    fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangent.w;
    return float4x4(
        worldTangent.x, worldBinormal.x, worldNormal.x, 0.0,
        worldTangent.y, worldBinormal.y, worldNormal.y, 0.0,
        worldTangent.z, worldBinormal.z, worldNormal.z, 0.0,
        0.0, 0.0, 0.0, 1.0);
}

// ================================================================
// ========================= OBJECT TO _ ==========================
// ================================================================

// vertex function
inline float3 thc_object_to_world_position_with_offset(float3 vertexPosition)
{
    return mul(unity_ObjectToWorld, vertexPosition);
}

inline float4 thc_object_to_clip_position(float3 vertexPosition)
{
    return UnityObjectToClipPos(vertexPosition);
}

// vertex function
inline float3 thc_object_to_world_position(float3 vertexPosition)
{
    return mul(unity_ObjectToWorld, float4(vertexPosition, 1.0)).xyz;
}

inline float3 thc_object_to_world_direction(float3 objectDirection)
{
    return UnityObjectToWorldDir(objectDirection);
}


/*float3 thc_object_to_world_position(float3 vertexPosition, sampler2D _DepthTexture)
{
    float4 clipPosition = UnityObjectToClipPos(vertexPosition);
    float4 projectionPosition = ComputeScreenPos(clipPosition);
    float3 cameraRelativeWorldPosition = mul(unity_ObjectToWorld, float4(vertexPosition, 1.0)).xyz -
        _WorldSpaceCameraPos;
    float2 screenPosition = projectionPosition.xy / projectionPosition.w;

    float depth = SAMPLE_DEPTH_TEXTURE(_DepthTexture, screenPosition);
    float linearEyeDepth = LinearEyeDepth(depth);

    float3 viewPlane = cameraRelativeWorldPosition / dot(cameraRelativeWorldPosition, unity_WorldToCamera._m20_m21_m22);
    float3 worldPosition = viewPlane * linearEyeDepth + _WorldSpaceCameraPos;
    worldPosition = mul(unity_CameraToWorld, float4(worldPosition, 1.0));

    return worldPosition;
}*/

// ================================================================
// ========================= WORLD TO _ ===========================
// ================================================================


inline float3 thc_world_to_object_direction(float3 worldDirection)
{
    return mul((float3x3)unity_WorldToObject, worldDirection);
}

// might be tricky, shows inverted y, or maybe im just stupid
inline float3 thc_world_to_screen_direction(float3 worldDirection)
{
    return mul((float3x3)UNITY_MATRIX_VP, worldDirection);
}

// vertex function
inline float3 thc_world_to_tangent_direction(float3 worldDirection, float3 normal, float4 tangent)
{
    float3 objectDirection = thc_world_to_object_direction(worldDirection);
    float3 binormal = cross(normal, tangent.xyz) * tangent.w;
    float3x3 rotation = float3x3(tangent.xyz, binormal, normal);
    float3 tangentDirection = mul(rotation, objectDirection);
    return tangentDirection;
}

inline fixed4 thc_world_to_screen_position(float3 worldPosition)
{
    float4 clipPosition = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0));
    float4 screenPosition = ComputeScreenPos(clipPosition);
    return screenPosition;
}

inline fixed2 thc_world_to_screen_position2(float3 worldPosition)
{
    float4 clipPosition = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0));
    float4 screenPosition = ComputeScreenPos(clipPosition);
    return screenPosition.xy / screenPosition.w;
}
