varying vec2 v_vTexCoord;

uniform sampler2D u_sDepth;
uniform sampler2D u_sNormal;
uniform vec2 u_vTexel;
uniform float u_fClipFar;

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}

void main()
{
	gl_FragColor = vec4(0.0);
	float depth = xDecodeDepth(texture2D(u_sDepth, v_vTexCoord).rgb) * u_fClipFar;
	vec3 normal = normalize(texture2D(u_sNormal, v_vTexCoord).rgb * 2.0 - 1.0);
	float weightSum = 0.001;
	for (float i = -4.0; i <= 4.0; i += 1.0)
	{
		for (float j = -4.0; j <= 4.0; j += 1.0)
		{
			vec2 uv = v_vTexCoord + vec2(i, j) * u_vTexel;
			float sampleDepth = xDecodeDepth(texture2D(u_sDepth, uv).rgb) * u_fClipFar;
			vec3 sampleNormal = normalize(texture2D(u_sNormal, uv).rgb * 2.0 - 1.0);
			float weight = 1.0
				* (1.0 - clamp(abs(depth - sampleDepth) / 0.2, 0.0, 1.0)) // TODO: Configurable blur depth range?
				* (dot(normal, sampleNormal) > 0.99 ? 1.0 : 0.0)
				;
			gl_FragColor.rgb += texture2D(gm_BaseTexture, uv).rgb * weight;
			weightSum += weight;
		}
	}
	gl_FragColor.rgb /= weightSum;
	gl_FragColor.a = 1.0;
}
