varying vec2 v_vTexCoord;

#define u_texBaseColor gm_BaseTexture
uniform sampler2D u_texDepth;
uniform sampler2D u_texNormal;

uniform float u_fClipFar;
uniform vec2 u_vTanAspect;

uniform mat4 u_mViewInverse;

uniform vec3 u_vSunDirection;

#define SHADOWMAP_SAMPLE_COUNT 12
uniform sampler2D u_texShadowmap;
uniform vec2 u_vShadowmapTexel;
uniform float u_fShadowmapArea;
uniform float u_fShadowmapNormalOffset;
uniform float u_fShadowmapBias;
uniform mat4 u_mShadowmap;

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

// Shadowmap filtering source: https://www.gamedev.net/tutorials/programming/graphics/contact-hardening-soft-shadows-made-fast-r4906/
float InterleavedGradientNoise(vec2 positionScreen)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(positionScreen, magic.xy)));
}

vec2 VogelDiskSample(int sampleIndex, int samplesCount, float phi)
{
	float GoldenAngle = 2.4;
	float r = sqrt(float(sampleIndex) + 0.5) / sqrt(float(samplesCount));
	float theta = float(sampleIndex) * GoldenAngle + phi;
	float sine = sin(theta);
	float cosine = cos(theta);
	return vec2(r * cosine, r * sine);
}

float ShadowMap(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	if (clamp(uv.xy, vec2(0.0), vec2(1.0)) != uv.xy)
	{
		return 0.0;
	}
	float shadow = 0.0;
	float noise = 6.28 * InterleavedGradientNoise(gl_FragCoord.xy);
	float bias = u_fShadowmapBias / u_fShadowmapArea;
	for (int i = 0; i < SHADOWMAP_SAMPLE_COUNT; ++i)
	{
		vec2 uv2 = uv + VogelDiskSample(i, SHADOWMAP_SAMPLE_COUNT, noise) * texel * 4.0;
		float depth = xDecodeDepth(texture2D(shadowMap, uv2).rgb);
		if (bias != 0.0)
		{
			shadow += clamp((compareZ - depth) / bias, 0.0, 1.0);
		}
		else
		{
			shadow += step(depth, compareZ);
		}
	}
	return (shadow / float(SHADOWMAP_SAMPLE_COUNT));
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
	vec3 L = normalize(-u_vSunDirection);
	vec3 vertexShadowmap = (u_mShadowmap * vec4(vertexWorld + normal * u_fShadowmapNormalOffset, 1.0)).xyz;
	vertexShadowmap.xy = vertexShadowmap.xy * 0.5 + 0.5;
	vertexShadowmap.y = 1.0 - vertexShadowmap.y;
	vertexShadowmap.z /= u_fShadowmapArea;
	float shadow = ShadowMap(u_texShadowmap, u_vShadowmapTexel, vertexShadowmap.xy, vertexShadowmap.z);
	gl_FragColor.rgb = baseColor * max(dot(normal, L), 0.0) * (1.0 - shadow);
	gl_FragColor.rgb = TonemapReinhard(gl_FragColor.rgb);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
	gl_FragColor.a = 1.0;
}
