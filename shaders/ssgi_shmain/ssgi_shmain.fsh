#define KERNEL_SIZE 32

varying vec2 v_vTexCoord;

#define u_texLight gm_BaseTexture
uniform sampler2D u_texDepth;
uniform sampler2D u_texNormal;

uniform sampler2D u_texKernel;
uniform vec2 u_vKernelScale;

uniform float u_fClipFar;
uniform vec2 u_vTanAspect;
uniform vec2 u_vTexel;
uniform float u_fThickness;

uniform mat4 u_mView;
uniform mat4 u_mProjection;

uniform float u_fDistance;
uniform float u_fSteps;

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

/// @param p A point in clip space (transformed by projection matrix, but not
///          normalized).
/// @return P's UV coordinates on the screen.
vec2 xUnproject(vec4 p)
{
	vec2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
	uv.y = 1.0 - uv.y;
	return uv;
}

#define X_PI 3.14159265359

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 xImportanceSample(float phi, float cosTheta, float sinTheta, vec3 N)
{
	vec3 H = vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
	vec3 upVector = abs(N.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
	vec3 tangentX = normalize(cross(upVector, N));
	vec3 tangentY = cross(N, tangentX);
	return normalize(tangentX * H.x + tangentY * H.y + N * H.z);
}

/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
vec3 xImportanceSample_Lambert(vec2 Xi, vec3 N)
{
	float phi = 2.0 * X_PI * Xi.y;
	float cosTheta = sqrt(1.0 - Xi.x);
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	return xImportanceSample(phi, cosTheta, sinTheta, N);
}

/// @source https://learnopengl.com/PBR/IBL/Specular-IBL
float xVanDerCorpus(int n, int base)
{
	float invBase = 1.0 / float(base);
	float denom = 1.0;
	float result = 0.0;
	for (int i = 0; i < 32; ++i)
	{
		if (n > 0)
		{
			denom = mod(float(n), 2.0);
			result += denom * invBase;
			invBase = invBase / 2.0;
			n = int(float(n) / 2.0);
		}
	}
	return result;
}

/// @desc Gets i-th point from sequence of uniformly distributed points on a unit square.
/// @param i The point index in sequence.
/// @param n The total size of the sequence.
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
vec2 xHammersley2D(int i, int n)
{
	return vec2(float(i) / float(n), xVanDerCorpus(i, 2));
}

// TODO: Optimize
void main()
{
	// TODO: Use DDA

	gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);

	float originDepth = xDecodeDepth(texture2D(u_texDepth, v_vTexCoord).rgb) * u_fClipFar;
	if (originDepth == 0.0 || originDepth == u_fClipFar)
	{
		return;
	}
	vec3 originView = xProject(u_vTanAspect, v_vTexCoord, originDepth);

	vec3 originNormalWorld = normalize(texture2D(u_texNormal, v_vTexCoord).rgb * 2.0 - 1.0);
	vec3 originNormalView = normalize((u_mView * vec4(originNormalWorld, 0.0)).xyz);

	// TODO: Encode Hammersley points into texture
	int u = int(texture2D(u_texKernel, v_vTexCoord * u_vKernelScale).x * 255.0);
	vec2 hammersley2D = xHammersley2D(u, KERNEL_SIZE * KERNEL_SIZE);
	vec3 sampleDir = xImportanceSample_Lambert(hammersley2D, originNormalView);

	vec3 endView = originView + sampleDir * u_fDistance;

	for (float i = 1.0; i <= u_fSteps; ++i)
	{
		vec3 sampleView = mix(originView, endView, i / u_fSteps);
		vec2 sampleScreen = xUnproject(u_mProjection * vec4(sampleView, 1.0));

		if (sampleScreen.x < 0.0 || sampleScreen.x > 1.0
			|| sampleScreen.y < 0.0 || sampleScreen.y > 1.0)
		{
			break;
		}

		float sampleDepth = xDecodeDepth(texture2D(u_texDepth, sampleScreen).rgb) * u_fClipFar;

		if (sampleDepth == 0.0 || sampleDepth == u_fClipFar)
		{
			break;
		}
	
		if (sampleView.z > sampleDepth)
		{
			vec3 sampleNormalWorld = normalize(texture2D(u_texNormal, sampleScreen).rgb * 2.0 - 1.0);
			//float dist = length(sampleView - originView);
			gl_FragColor = texture2D(u_texLight, sampleScreen)
				* (1.0 - clamp(length(originView - sampleView) / u_fDistance, 0.0, 1.0))
				* (((sampleView.z - sampleDepth) < u_fThickness) ? 1.0 : 0.0)
				* (dot(originNormalWorld, -sampleNormalWorld) > -0.1 ? 1.0 : 0.0)
				//* 1.0 / (dist * dist)
				;
			break;
		}
	}
}
