varying vec2 v_vTexCoord;

#define u_texBaseColor gm_BaseTexture
uniform sampler2D u_texDepth;
uniform sampler2D u_texNormal;

uniform float u_fClipFar;
uniform vec2 u_vTanAspect;

uniform mat4 u_mViewInverse;

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}

/// @param tanAspect (tanFovY*(screenWidth/screenHeight),-tanFovY), where
///                  tanFovY = dtan(fov*0.5)
/// @param texCoord  Sceen-space UV.
/// @param depth     Scene depth at texCoord.
/// @return Point projected to view-space.
vec3 xProject(vec2 tanAspect, vec2 texCoord, float depth)
{
	return vec3(tanAspect * (texCoord * 2.0 - 1.0) * depth, depth);
}

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
	vec3 baseColor = xGammaToLinear(texture2D(u_texBaseColor, v_vTexCoord).rgb);
	float depth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord).rgb) * u_fClipFar;
	vec3 normal = normalize(texture2D(u_texNormal, v_vTexCoord).rgb * 2.0 - 1.0);
	vec3 vertexView = xProject(u_vTanAspect, v_vTexCoord, depth);
	vec3 vertexWorld = (u_mViewInverse * vec4(vertexView, 1.0)).xyz;
	vec3 L = normalize(-vec3(-1.0));
	gl_FragColor.rgb = baseColor * max(dot(normal, L), 0.0);
	gl_FragColor.rgb = TonemapReinhard(gl_FragColor.rgb);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
	gl_FragColor.a = 1.0;
}
