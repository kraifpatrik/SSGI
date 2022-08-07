uniform vec2 u_vTexel;

varying vec2 v_vTexCoord;

void main()
{
	float weightSum = 0.0001;
	gl_FragColor.rgb = vec3(0.0);
	gl_FragColor.a = 1.0;

	vec3 sample = texture2D(gm_BaseTexture, v_vTexCoord).rgb;
	weightSum += (length(sample) > 0.0) ? 1.0 : 0.0;
	gl_FragColor.rgb += sample;

	sample = texture2D(gm_BaseTexture, v_vTexCoord + vec2(1.0, 0.0) * u_vTexel).rgb;
	weightSum += (length(sample) > 0.0) ? 1.0 : 0.0;
	gl_FragColor.rgb += sample;

	sample = texture2D(gm_BaseTexture, v_vTexCoord + vec2(0.0, 1.0) * u_vTexel).rgb;
	weightSum += (length(sample) > 0.0) ? 1.0 : 0.0;
	gl_FragColor.rgb += sample;

	sample = texture2D(gm_BaseTexture, v_vTexCoord + vec2(1.0, 1.0) * u_vTexel).rgb;
	weightSum += (length(sample) > 0.0) ? 1.0 : 0.0;
	gl_FragColor.rgb += sample;

	gl_FragColor.rgb /= weightSum;
}
