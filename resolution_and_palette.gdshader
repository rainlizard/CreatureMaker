// This is a shader that is applied to a 2D pixel art image. The pixel art image was converted from 3D, so this shader fixes up the result.

shader_type canvas_item;
uniform sampler2D palette_image : filter_nearest;
const ivec2 paletteImgSize = ivec2(16,16);

uniform float sobel_intensity : hint_range(0.0, 10.0);
uniform float sobel_threshold : hint_range(0.0, 10.0);
uniform float dither_strength : hint_range(0.0, 1.0) = 0.05; // New uniform for dithering strength

uniform vec3 minimum_dark_color : source_color = vec3(0,0,0);

uniform vec3 outline_color : source_color = vec3(1,0,0);
uniform float outline_intensity = 0.0; // Amount of outline_darkening (0.0 to 1.0)

// Sobel kernels
const mat3 sobelX = mat3(
    vec3(-1, 0, 1),
    vec3(-2, 0, 2),
    vec3(-1, 0, 1)
);

const mat3 sobelY = mat3(
    vec3(-1, -2, -1),
    vec3(0, 0, 0),
    vec3(1, 2, 1)
);

// Dithering Matrices
const mat2 dither2x2 = mat2(
    vec2(1.0, 4.0),
    vec2(3.0, 2.0)
) / 5.0;

const mat4 dither4x4 = mat4(
    vec4(0.0, 12.0, 3.0, 15.0),
    vec4(8.0, 4.0, 11.0, 7.0),
    vec4(2.0, 14.0, 1.0, 13.0),
    vec4(10.0, 6.0, 9.0, 5.0)
) / 16.0;

const mat4 clusterDot8x8_1 = mat4(
    vec4( 0.0, 32.0,  8.0, 40.0),
    vec4(48.0, 16.0, 56.0, 24.0),
    vec4(12.0, 44.0,  4.0, 36.0),
    vec4(60.0, 28.0, 52.0, 20.0)
) / 64.0;

const mat4 clusterDot8x8_2 = mat4(
    vec4( 2.0, 34.0, 10.0, 42.0),
    vec4(50.0, 18.0, 58.0, 26.0),
    vec4(14.0, 46.0,  6.0, 38.0),
    vec4(62.0, 30.0, 54.0, 22.0)
) / 64.0;

const mat4 clusterDot8x8_3 = mat4(
    vec4( 3.0, 35.0, 11.0, 43.0),
    vec4(51.0, 19.0, 59.0, 27.0),
    vec4(15.0, 47.0,  7.0, 39.0),
    vec4(63.0, 31.0, 55.0, 23.0)
) / 64.0;

const mat4 clusterDot8x8_4 = mat4(
    vec4( 1.0, 33.0,  9.0, 41.0),
    vec4(49.0, 17.0, 57.0, 25.0),
    vec4(13.0, 45.0,  5.0, 37.0),
    vec4(61.0, 29.0, 53.0, 21.0)
) / 64.0;

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 adjust_black_point(vec3 color) {
	return max(color, minimum_dark_color);
}


vec4 add_outline(sampler2D tex, vec2 psize, vec4 color, vec2 uv) {
    // Check if the current pixel is transparent
    if (color.a == 0.0 && outline_intensity != 0.0) {
        // Check if any of the 4 neighboring pixels (left, right, up, down) are opaque
        vec4 pixel_left = texture(tex, uv + vec2(-psize.x, 0.0));
        vec4 pixel_right = texture(tex, uv + vec2(psize.x, 0.0));
        vec4 pixel_up = texture(tex, uv + vec2(0.0, -psize.y));
        vec4 pixel_down = texture(tex, uv + vec2(0.0, psize.y));
		
        if (pixel_left.a > 0.0 || pixel_right.a > 0.0 || pixel_up.a > 0.0 || pixel_down.a > 0.0) {
            const int num_samples = 8;
            const vec2 sample_directions[num_samples] = vec2[](
                vec2(-1.0, 0.0),   // Left
                vec2(1.0, 0.0),    // Right
                vec2(0.0, -1.0),   // Up
                vec2(0.0, 1.0),    // Down
                vec2(-1.0, -1.0),  // Top-left
                vec2(1.0, -1.0),   // Top-right
                vec2(-1.0, 1.0),   // Bottom-left
                vec2(1.0, 1.0)     // Bottom-right
            );

            // Sample neighboring pixels
            vec4 sample_colors[num_samples];
            float sample_count = 0.0;

            for (int i = 0; i < num_samples; i++) {
                vec2 sample_uv = uv + sample_directions[i] * psize;
                vec4 sample_color = texture(tex, sample_uv);
				
				if (sample_color.a > 0.0) {
                    sample_colors[int(sample_count)] = sample_color;
                    sample_count += 1.0;
                }
            }

            // If any neighboring pixel is opaque, calculate the outline color
            if (sample_count > 0.0) {
                vec4 average_color = vec4(0.0);

                for (int i = 0; i < int(sample_count); i++) {
                    average_color += sample_colors[i];
                }
                average_color /= sample_count;

                // Mix the average color towards the outline color based on outline_intensity
                vec3 outline_color_mixed = mix(average_color.rgb, outline_color, outline_intensity);

                return vec4(outline_color_mixed, 1.0);
            }
        }
    }

    return color;
}

// Dithering Helper
float getDitherValue(vec2 position) {
    vec2 ditherPos = mod(position, 8.0);
    float ditherValue;
    if (ditherPos.y < 4.0) {
        if (ditherPos.x < 4.0) {
            ditherValue = clusterDot8x8_1[int(ditherPos.y)][int(ditherPos.x)];
        } else {
            ditherValue = clusterDot8x8_2[int(ditherPos.y)][int(ditherPos.x - 4.0)];
        }
    } else {
        if (ditherPos.x < 4.0) {
            ditherValue = clusterDot8x8_3[int(ditherPos.y - 4.0)][int(ditherPos.x)];
        } else {
            ditherValue = clusterDot8x8_4[int(ditherPos.y - 4.0)][int(ditherPos.x - 4.0)];
        }
    }
    return ditherValue - 0.5; // Center the dither value around 0.5
}



// Sobel Edge Detection
vec3 applySobel(sampler2D image, vec2 uv, vec2 resolution) {
	vec3 gradientX = vec3(0.0);
	vec3 gradientY = vec3(0.0);

	vec2 basePixelUV = round(uv * resolution) / resolution; // Rounding to nearest pixel

	for(int y = -1; y <= 1; y++) {
		for(int x = -1; x <= 1; x++) {
			vec2 offset = vec2(float(x), float(y)) / resolution;
			vec2 pixelated_uv = basePixelUV + offset;
			vec3 color = texture(image, pixelated_uv).rgb;
			gradientX += color * sobelX[y+1][x+1];
			gradientY += color * sobelY[y+1][x+1];
		}
	}

	vec3 gradientMagnitude = sqrt(gradientX * gradientX + gradientY * gradientY);
	return gradientMagnitude;
}

// Palette Quantization
vec3 getNearestPaletteColor(vec3 color) {
    vec3 nearest_colour;
    float nearest_distance = 100000.0;
    for (int y = 0; y < paletteImgSize.y; y++) {
        for (int x = 0; x < paletteImgSize.x; x++) {
            vec2 pixelCoord = vec2(float(x)+0.5,float(y)+0.5) / vec2(paletteImgSize);
            vec3 paletteColour = textureLod(palette_image, pixelCoord, 0).rgb;
            float check_distance = distance(color, paletteColour);
            if (check_distance < nearest_distance)
            {
                nearest_distance = check_distance;
                nearest_colour = paletteColour;
            }
        }
    }
    return nearest_colour;
}


void fragment() {
	vec2 resolution = vec2(1.0) / TEXTURE_PIXEL_SIZE;
	vec4 col = texture(TEXTURE, UV);

	// Apply Sobel edge detection
	vec3 sobelResult = applySobel(TEXTURE, UV, resolution);
	float edgeStrength = length(sobelResult);
	edgeStrength = smoothstep(0.0, sobel_threshold, edgeStrength);  // Use smoothstep for smoother transitions
	vec3 edgeColor = col.rgb * sobel_intensity;
	// Blend between the original color and the Sobel result based on edge strength
	col.rgb = mix(col.rgb, edgeColor, edgeStrength);

	// Apply dithering
	col.rgb = mix(col.rgb, col.rgb + getDitherValue(FRAGCOORD.xy), dither_strength);
	
	// Outline goes after other stuff, because the outline function uses existing colours to build the outline
	col = add_outline(TEXTURE, TEXTURE_PIXEL_SIZE, col, UV);
	
	// Apply minimum dark
	col.rgb = adjust_black_point(col.rgb);
	
	// Quantize to nearest palette color
	col.rgb = getNearestPaletteColor(col.rgb);
	// Finalize
	COLOR = col;
}

//uniform ivec2 resolution;

	/*vec2 res = vec2(resolution);
	vec2 partial_pixel = 0.5/res;
	vec2 pixelated_uv = (round((UV-partial_pixel) * res) / res)+partial_pixel;
	vec4 baseCol = textureLod(TEXTURE, pixelated_uv, 0);
	COLOR = baseCol;
	*/