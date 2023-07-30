varying vec2 v_vTexCoord;

#define u_texBaseColor gm_BaseTexture
uniform sampler2D u_texDepth;
uniform sampler2D u_texNormal;

uniform float u_fClipFar;
uniform vec2 u_vTanAspect;

uniform mat4 u_mViewInverse;

uniform vec3 u_vSunDirection;
uniform vec4 u_vSunColor;

#define SHADOWMAP_SAMPLE_COUNT 12
uniform sampler2D u_texShadowmap;
uniform vec2 u_vShadowmapTexel;
uniform float u_fShadowmapArea;
uniform float u_fShadowmapNormalOffset;
uniform float u_fShadowmapBias;
uniform mat4 u_mShadowmap;

uniform vec3 u_vCameraPosition;

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

/////////////////////


#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
#define xPow2(x) ((x) * (x))

/// @return x^3
#define xPow3(x) ((x) * (x) * (x))

/// @return x^4
#define xPow4(x) ((x) * (x) * (x) * (x))

/// @return x^5
#define xPow5(x) ((x) * (x) * (x) * (x) * (x))

/// @return arctan2(x,y)
#define xAtan2(x, y) atan(y, x)

/// @return Direction from point `from` to point `to` in degrees (0-360 range).
float xPointDirection(vec2 from, vec2 to)
{
	float x = xAtan2(from.x - to.x, from.y - to.y);
	return ((x > 0.0) ? x : (2.0 * X_PI + x)) * 180.0 / X_PI;
}

/// @desc Default specular color for dielectrics
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
#define X_F0_DEFAULT vec3(0.04, 0.04, 0.04)

/// @desc Normal distribution function
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularD_GGX(float roughness, float NdotH)
{
	float r = xPow4(roughness);
	float a = NdotH * NdotH * (r - 1.0) + 1.0;
	return r / (X_PI * a * a);
}

/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
float xSpecularD_Approx(float roughness, float RdotL)
{
	float a = roughness * roughness;
	float a2 = a * a;
	float rcp_a2 = 1.0 / a2;
	// 0.5 / ln(2), 0.275 / ln(2)
	float c = (0.72134752 * rcp_a2) + 0.39674113;
	return (rcp_a2 * exp2((c * RdotL) - c));
}

/// @desc Roughness remapping for analytic lights.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xK_Analytic(float roughness)
{
	return xPow2(roughness + 1.0) * 0.125;
}

/// @desc Roughness remapping for IBL lights.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xK_IBL(float roughness)
{
	return xPow2(roughness) * 0.5;
}

/// @desc Geometric attenuation
/// @param k Use either xK_Analytic for analytic lights or xK_IBL for image based lighting.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularG_Schlick(float k, float NdotL, float NdotV)
{
	return (NdotL / (NdotL * (1.0 - k) + k))
		* (NdotV / (NdotV * (1.0 - k) + k));
}

/// @desc Fresnel
/// @source https://en.wikipedia.org/wiki/Schlick%27s_approximation
vec3 xSpecularF_Schlick(vec3 f0, float VdotH)
{
	return f0 + (1.0 - f0) * xPow5(1.0 - VdotH);
}

/// @desc Cook-Torrance microfacet specular shading
/// @note N = normalize(vertexNormal)
///       L = normalize(light - vertex)
///       V = normalize(camera - vertex)
///       H = normalize(L + V)
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 xBRDF(vec3 f0, float roughness, float NdotL, float NdotV, float NdotH, float VdotH)
{
	vec3 specular = xSpecularD_GGX(roughness, NdotH)
		* xSpecularF_Schlick(f0, VdotH)
		* xSpecularG_Schlick(xK_Analytic(roughness), NdotL, NdotH);
	return specular / ((4.0 * NdotL * NdotV) + 0.1);
}


////////////////////

void main()
{
	vec4 baseColorMetallic = texture2D(u_texBaseColor, v_vTexCoord);
	vec3 baseColor = xGammaToLinear(baseColorMetallic.rgb);
	float metallic = baseColorMetallic.a;
	vec3 specularColor = mix(vec3(0.04), baseColor, metallic);
	baseColor *= (1.0 - metallic);
	float depth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord).rgb) * u_fClipFar;
	vec4 normalRoughness = texture2D(u_texNormal, v_vTexCoord);
	vec3 normal = normalize(normalRoughness.rgb * 2.0 - 1.0);
	float roughness = normalRoughness.a;
	vec3 vertexView = xProject(u_vTanAspect, v_vTexCoord, depth);
	vec3 vertexWorld = (u_mViewInverse * vec4(vertexView, 1.0)).xyz;

	vec3 lightDiffuse = vec3(0.0);
	vec3 lightSpecular = vec3(0.0);
	vec3 L;

	L = normalize(-u_vSunDirection);
	vec3 vertexShadowmap = (u_mShadowmap * vec4(vertexWorld + normal * u_fShadowmapNormalOffset, 1.0)).xyz;
	vertexShadowmap.xy = vertexShadowmap.xy * 0.5 + 0.5;
#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	vertexShadowmap.y = 1.0 - vertexShadowmap.y;
#endif
	vertexShadowmap.z /= u_fShadowmapArea;
	float shadow = ShadowMap(u_texShadowmap, u_vShadowmapTexel, vertexShadowmap.xy, vertexShadowmap.z);
	vec3 sunColor = xGammaToLinear(u_vSunColor.rgb * u_vSunColor.a);
	float NdotL = max(dot(normal, L), 0.0);
	lightDiffuse += sunColor * NdotL * (1.0 - shadow);

	vec3 V = normalize(u_vCameraPosition - vertexWorld);
	vec3 H = normalize(L + V);
	float NdotV = max(dot(normal, V), 0.0);
	float NdotH = max(dot(normal, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	lightSpecular += sunColor * xBRDF(specularColor, roughness, NdotL, NdotV, NdotH, VdotH) * (1.0 - shadow);

	//L = u_vCameraPosition - vertexWorld;
	//float dist = length(L);
	//L = normalize(L);
	//float att = 1.0 / (dist * dist);
	//lightDiffuse += vec3(1.0) * 0.25 * max(dot(normal, L), 0.0) * att;

	gl_FragColor.rgb = baseColor * lightDiffuse + lightSpecular;
	gl_FragColor.rgb = TonemapReinhard(gl_FragColor.rgb);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
	gl_FragColor.a = 1.0;
}
