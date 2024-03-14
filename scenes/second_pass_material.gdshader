shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;
uniform float reduce_noise;
uniform float edge_depth_threshold : hint_range(0.0, 2.0, 0.01) = 0.0;
uniform float edge_normal_threshold : hint_range(0.0, 2.0, 0.01) = 0.0;
uniform float edge_highlight_strength : hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float edge_shadow_strength : hint_range(0.0, 1.0, 0.001) = 0.0;
uniform vec3 edge_highlight_color : source_color = vec3(0.0);
uniform vec3 edge_shadow_color : source_color = vec3(0.0);

const int samples = 8;


vec4 noise_reduction(vec4 originalColor, vec2 uv) {
    vec4 mergedColor = vec4(0.0);
    float totalWeight = 0.0;

    int kernelSize = 3;
    int kernelOffset = kernelSize / 2;

    for (int i = -kernelOffset; i <= kernelOffset; i++) {
        for (int j = -kernelOffset; j <= kernelOffset; j++) {
            vec2 sampleUV = uv + vec2(float(i) / float(textureSize(SCREEN_TEXTURE, 0).x),
                                       float(j) / float(textureSize(SCREEN_TEXTURE, 0).y));

            vec4 sampleColor = texture(SCREEN_TEXTURE, sampleUV);

            float colorDiff = distance(originalColor, sampleColor);

            float weight = 1.0 - smoothstep(0.0, reduce_noise, colorDiff);

            mergedColor += sampleColor * weight;
            totalWeight += weight;
        }
    }

    mergedColor /= totalWeight;

    return mergedColor;
}

vec3 calculate_edges(vec4 col, vec2 uv, vec2 view_size) {
    float depth = texture(DEPTH_TEXTURE, uv).r;
    vec3 normal = texture(NORMAL_TEXTURE, uv).rgb;
    vec2 offset = 1.0 / view_size;
    float depth_avg = 0.0;
    float normal_avg = 0.0;
    vec2 offsets[samples];

    offsets[0] = vec2(offset.x, 0.0);
    offsets[1] = vec2(-offset.x, 0.0);
    offsets[2] = vec2(0.0, offset.y);
    offsets[3] = vec2(0.0, -offset.y);
    offsets[4] = vec2(offset.x, offset.y);
    offsets[5] = vec2(-offset.x, -offset.y);
    offsets[6] = vec2(offset.x, -offset.y);
    offsets[7] = vec2(-offset.x, offset.y);

    for (int i = 0; i < samples; i++) {
        depth_avg += abs(texture(DEPTH_TEXTURE, uv + offsets[i]).r - depth);
        normal_avg += length(texture(NORMAL_TEXTURE, uv + offsets[i]).rgb - normal);
    }

    depth_avg /= float(samples);
    normal_avg /= float(samples);

    float edge_strength = max(
        smoothstep(1.0 - edge_depth_threshold, 1.0, depth_avg),
        smoothstep(1.0 - edge_normal_threshold, 1.0, normal_avg)
    );

    vec3 blah = mix(col.rgb, edge_highlight_color, edge_strength * edge_highlight_strength);
    vec3 edgeblah = mix(blah, edge_shadow_color, (1.0 - edge_strength) * edge_shadow_strength);

    return edgeblah;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = texture(SCREEN_TEXTURE, uv);

	col = noise_reduction(col, uv);

    col.rgb = calculate_edges(col, uv, VIEWPORT_SIZE);
    ALBEDO = col.rgb;
}