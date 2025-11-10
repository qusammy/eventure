#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_main(uint vertexID [[vertex_id]]) {
    float2 pos[3] = { float2(-1.0, -1.0),
                      float2( 3.0, -1.0),
                      float2(-1.0,  3.0) };
    VertexOut out;
    out.position = float4(pos[vertexID], 0.0, 1.0);
    out.uv = (pos[vertexID] + 1.0) * 0.5;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant float &time [[buffer(0)]],
                              constant float2 &resolution [[buffer(1)]],
                              constant float3 &baseColor [[buffer(2)]],
                              constant float &amplitude [[buffer(3)]],
                              constant float &freqX [[buffer(4)]],
                              constant float &freqY [[buffer(5)]],
                              constant float2 &mouse [[buffer(6)]])
{
    float2 uv = in.uv;
    float2 fragCoord = uv * resolution;
    float2 p = (2.0 * fragCoord - resolution) / min(resolution.x, resolution.y);

    for (float i = 1.0; i < 10.0; i += 1.0) {
        p.x += amplitude / i * cos(i * freqX * p.y + time + mouse.x * 3.14159);
        p.y += amplitude / i * cos(i * freqY * p.x + time + mouse.y * 3.14159);
    }

    float3 color = baseColor / fabs(sin(time - p.y - p.x));
    return float4(color, 1.0);
}
