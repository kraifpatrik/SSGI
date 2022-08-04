#define u_texBaseColor gm_BaseTexture
uniform sampler2D u_texLight;
uniform sampler2D u_texSSGI;
uniform float u_fMultiplier;

varying vec2 v_vTexCoord;

#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
vec3 xGammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(X_GAMMA));
}

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

vec3 TonemapReinhard(vec3 color)
{
	return (color / (color + vec3(1.0)));
}

void main()
{
	gl_FragColor.rgb = xGammaToLinear(texture2D(u_texLight, v_vTexCoord).rgb)
		+ (xGammaToLinear(texture2D(u_texBaseColor, v_vTexCoord).rgb)
		* xGammaToLinear(texture2D(u_texSSGI, v_vTexCoord).rgb) * u_fMultiplier);
	//gl_FragColor.rgb = TonemapReinhard(gl_FragColor.rgb);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
	gl_FragColor.a = 1.0;
}
