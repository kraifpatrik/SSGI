#macro __SSGI_KERNEL_SIZE 32

/// @func SSGI()
///
/// @desc
function SSGI() constructor
{
	/// @var {Bool} If `true` then global illumination is raytraced at
	/// half-resolution, which can greatly improve performance at the cost of
	/// visual quality. Default value is `true`.
	HalfRes = true;

	/// @var {Real} The maximum distance in world units a ray can travel when
	/// sampling global illumination. Default value is 1.
	GIDistance = 1.0;

	/// @var {Real} The maximum number of steps a ray can do to reach the
	/// maximum sampling distance. Default value is 32. Increasing this value
	/// improves quality but has a negative impact on performance.
	GISteps = 32.0;

	/// @var {Real} The maximum depth difference in world units between two
	/// samples when blurring raytraced image. Default value is 1. Fine-tune
	/// this value to prevent blurring over large depth discontinuities.
	BlurDepthRange = 1.0;

	/// @var {Real} The minimum required value of a dot product between normal
	/// vectors of two samples when blurring raytraced image. Default value is 1.
	/// Fine-tune this value to prevent blurring over sharp edges.
	BlurNormalThreshold = 0.5;

	/// @var {Id.Surface} A surface containing lit scene.
	SurLight = noone;

	/// @var {Pointer.Texture} A texture containing scene depth.
	TextureDepth = pointer_null;

	/// @var {Real} Thickness of the depth buffer in world units. Must be
	/// greater than 0. Default value is 1. Increasing this value can reduce
	/// flickering when moving the camera.
	DepthThickness = 1.0;

	/// @var {Pointer.Texture} A texture containing world-space normals.
	TextureNormals = pointer_null;

	/// @var {Asset.GMSprite}
	/// @private
	__SpriteKernel = MakeKernelSprite();

	/// @var {Real} Aspect ratio used when rendering the scene.
	AspectRatio = 1.0;

	/// @var {Real} Field of view used when rendering the scene.
	Fov = 1.0;

	/// @var {Real} Distance to the far clipping plane used when rendering the
	/// scene.
	ClipFar = 1.0;

	/// @var {Array<Real>} View matrix used when rendering the scene.
	MatrixView = matrix_build_identity();

	/// @var {Array<Real>} Projection matrix used when rendering the scene.
	MatrixProjection = matrix_build_identity();

	/// @var {Id.Surface} A full resolution surface to render the global
	/// illumination into.
	SurResult = noone;

	/// @var {Id.Surface} A 1/2-resolution temporary surface used for rendering
	/// the global illumination.
	SurHalf = noone;

	/// @var {Id.Surface} A 1/4-resolution temporary surface used for rendering
	/// the global illumination.
	SurQuarter = noone;

	/// @var {Id.Surface} A 1/8-resolution temporary surface used for rendering
	/// the global illumination.
	SurEighth = noone;

	////////////////////////////////////////////////////////////////////////////
	// Shaders and uniforms
	static __ShaderMain = SSGI_ShMain;
	static __UMainDepth = shader_get_sampler_index(__ShaderMain, "u_texDepth");
	static __UMainNormal = shader_get_sampler_index(__ShaderMain, "u_texNormal");
	static __UMainKernel = shader_get_sampler_index(__ShaderMain, "u_texKernel");
	static __UMainKernelScale = shader_get_uniform(__ShaderMain, "u_vKernelScale");
	static __UMainClipFar = shader_get_uniform(__ShaderMain, "u_fClipFar");
	static __UMainTanAspect = shader_get_uniform(__ShaderMain, "u_vTanAspect");
	static __UMainTexel = shader_get_uniform(__ShaderMain, "u_vTexel");
	static __UMainThickness = shader_get_uniform(__ShaderMain, "u_fThickness");
	static __UMainSteps = shader_get_uniform(__ShaderMain, "u_fSteps");
	static __UMainDistance = shader_get_uniform(__ShaderMain, "u_fDistance");
	static __UMainView = shader_get_uniform(__ShaderMain, "u_mView");
	static __UMainProjection = shader_get_uniform(__ShaderMain, "u_mProjection");

	static __ShaderDownsample = SSGI_ShDownsample;
	static __UDownsampleTexel = shader_get_uniform(__ShaderDownsample, "u_vTexel");

	static __ShaderUpsample = SSGI_ShUpsample;
	static __UUpsampleDepth = shader_get_sampler_index(__ShaderUpsample, "u_texDepth");
	static __UUpsampleNormal = shader_get_sampler_index(__ShaderUpsample, "u_texNormal");
	static __UUpsampleTexel = shader_get_uniform(__ShaderUpsample, "u_vTexel");
	static __UUpsampleClipFar = shader_get_uniform(__ShaderUpsample, "u_fClipFar");
	static __UUpsampleDepthRange = shader_get_uniform(__ShaderUpsample, "u_fDepthRange");
	static __UUpsampleNormalThreshold = shader_get_uniform(__ShaderUpsample, "u_fNormalThreshold");
	static __UUpsampleBlurSize = shader_get_uniform(__ShaderUpsample, "u_fBlurSize");
	static __UUpsampleBlurStep = shader_get_uniform(__ShaderUpsample, "u_fBlurStep");

	/// @func MakeKernelSprite()
	///
	/// @desc
	///
	/// @return {Asset.GMSprite}
	static MakeKernelSprite = function () {
		var _size = __SSGI_KERNEL_SIZE;
		var _indices = ds_list_create();
		for (var i = 0; i < _size * _size; ++i)
		{
			ds_list_add(_indices, i);
		}
		ds_list_shuffle(_indices);
		//var _dest = array_create(2);
		var _surface = surface_create(_size, _size);
		surface_set_target(_surface);
		draw_clear(c_black);
		var k = 0;
		for (var i = 0; i < _size; ++i)
		{
			for (var j = 0; j < _size; ++j)
			{
				//SSGI_Hammersley2D(_indices[| k++], _size * _size, _dest);
				draw_point_color(i, j, make_color_rgb(_indices[| k++], 0, 0));
			}
		}
		surface_reset_target();
		ds_list_destroy(_indices);
		return sprite_create_from_surface(
			_surface, 0, 0, _size, _size, false, false, 0, 0);
	};

	/// @func Render()
	///
	/// @desc
	///
	/// @return {Struct.SSGI} Returns `self`.
	static Render = function () {
		if (!surface_exists(SurResult)
			|| !surface_exists(SurHalf)
			|| !surface_exists(SurQuarter)
			|| !surface_exists(SurEighth))
		{
			show_debug_message("[SSGI] WARNING: Surfaces not set or corrupted! Skipping...");
			return self;
		}

		var _surfaceWidth = surface_get_width(SurResult);
		var _surfaceHeight = surface_get_height(SurResult);
		var _texelWidth = 1.0 / _surfaceWidth;
		var _texelHeight = 1.0 / _surfaceHeight;

		////////////////////////////////////////////////////////////////////////////////
		// Raytrace at half resolution
		surface_set_target(HalfRes ? SurHalf : SurResult);
		draw_clear(c_black);
		gpu_push_state();
		shader_set(__ShaderMain);
		texture_set_stage(__UMainDepth, TextureDepth);
		gpu_set_tex_filter_ext(__UMainDepth, false);
		texture_set_stage(__UMainNormal, TextureNormals);
		gpu_set_tex_filter_ext(__UMainNormal, false);
		texture_set_stage(__UMainKernel, sprite_get_texture(__SpriteKernel, 0));
		gpu_set_tex_repeat_ext(__UMainKernel, true);
		gpu_set_tex_filter_ext(__UMainKernel, false);
		shader_set_uniform_f(__UMainKernelScale,
			_surfaceWidth / __SSGI_KERNEL_SIZE, _surfaceHeight / __SSGI_KERNEL_SIZE);
		shader_set_uniform_f(__UMainClipFar, ClipFar);
		shader_set_uniform_f(__UMainTanAspect,
			dtan(Fov * 0.5) * AspectRatio, -dtan(Fov * 0.5));
		shader_set_uniform_f(__UMainTexel, _texelWidth, _texelHeight);
		shader_set_uniform_f(__UMainThickness, DepthThickness);
		shader_set_uniform_f(__UMainSteps, GISteps);
		shader_set_uniform_f(__UMainDistance, GIDistance);
		shader_set_uniform_matrix_array(__UMainView, MatrixView);
		shader_set_uniform_matrix_array(__UMainProjection, MatrixProjection);
		draw_surface_ext(SurLight, 0, 0, HalfRes ? 0.5 : 1.0, HalfRes ? 0.5 : 1.0, 0.0, c_white, 1.0);
		shader_reset();
		gpu_pop_state();
		surface_reset_target();

		gpu_push_state(); // <-- Push state!

		////////////////////////////////////////////////////////////////////////////////
		// Downsample
		gpu_set_tex_filter(false);
		gpu_set_tex_repeat(false);

		shader_set(__ShaderDownsample);

		if (!HalfRes)
		{
			surface_set_target(SurHalf);
			shader_set_uniform_f(__UDownsampleTexel, _texelWidth, _texelHeight);
			draw_surface(SurResult, 0, 0);
			surface_reset_target();
		}

		surface_set_target(SurQuarter);
		shader_set_uniform_f(__UDownsampleTexel, _texelWidth * 2.0, _texelHeight * 2.0);
		draw_surface(SurHalf, 0, 0);
		surface_reset_target();

		surface_set_target(SurEighth);
		shader_set_uniform_f(__UDownsampleTexel, _texelWidth * 4.0, _texelHeight * 4.0);
		draw_surface(SurQuarter, 0, 0);
		surface_reset_target();

		shader_reset();

		gpu_set_tex_filter(true);

		////////////////////////////////////////////////////////////////////////////////
		// Upsample
		shader_set(__ShaderUpsample);

		texture_set_stage(__UUpsampleDepth, TextureDepth);
		texture_set_stage(__UUpsampleNormal, TextureNormals);
		shader_set_uniform_f(__UUpsampleClipFar, ClipFar);
		shader_set_uniform_f(__UUpsampleDepthRange, BlurDepthRange);
		shader_set_uniform_f(__UUpsampleNormalThreshold, BlurNormalThreshold);
		shader_set_uniform_f(__UUpsampleBlurStep, 1.0);

		surface_set_target(SurQuarter);
		shader_set_uniform_f(__UUpsampleTexel, _texelWidth * 8.0, _texelHeight * 8.0);
		shader_set_uniform_f(__UUpsampleBlurSize, HalfRes ? 6.0 : 8.0);
		draw_surface_stretched(SurEighth, 0, 0, _surfaceWidth * 0.25, _surfaceHeight * 0.25);
		surface_reset_target();

		surface_set_target(SurHalf);
		shader_set_uniform_f(__UUpsampleTexel, _texelWidth * 4.0, _texelHeight * 4.0);
		shader_set_uniform_f(__UUpsampleBlurSize, HalfRes ? 3.0 : 4.0);
		draw_surface_stretched(SurQuarter, 0, 0, _surfaceWidth * 0.5, _surfaceHeight * 0.5);
		surface_reset_target();

		surface_set_target(SurResult);
		shader_set_uniform_f(__UUpsampleTexel, _texelWidth * 2.0, _texelHeight * 2.0);
		shader_set_uniform_f(__UUpsampleBlurSize, HalfRes ? 1.0 : 2.0);
		draw_surface_stretched(SurHalf, 0, 0, _surfaceWidth, _surfaceHeight);
		surface_reset_target();

		shader_reset();

		gpu_pop_state(); // <-- Pop state!

		return self;
	};

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function () {
		sprite_delete(__SpriteKernel);
		return undefined;
	};
}

/// @func SSGI_SurfaceCheck(_surface, _width, _height)
///
/// @desc
///
/// @param {Id.Surface} _surface
/// @param {Real} _width
/// @param {Real} _height
///
/// @return {Id.Surface}
function SSGI_SurfaceCheck(_surface, _width, _height)
{
	_width = max(_width, 1);
	_height = max(_height, 1);
	if (!surface_exists(_surface))
	{
		_surface = surface_create(_width, _height);
	}
	else if (surface_get_width(_surface) != _width
		|| surface_get_height(_surface) != _height)
	{
		surface_resize(_surface, _width, _height);
	}
	return _surface;
}

/// @func SSGI_Hammersley2D(_i, _n[, _dest])
///
/// @desc Gets i-th point from sequence of uniformly distributed points on a
/// unit square.
///
/// @param {Real} _i The point index in sequence.
/// @param {Real} _n The total size of the sequence.
/// @param {Array<Real>} [_dest] The array to write the point coordinates to.
///
/// @return {Array<Real>} The destination array.
///
/// @source http://holger.dammertz.org/stuff/notes__hammersley_on_hemisphere.html
function SSGI_Hammersley2D(_i, _n, _dest=[])
{
	var _b = (_n << 16) | (_n >> 16);
	_b = ((_b & 0x55555555) << 1) | ((_b & 0xAAAAAAAA) >> 1);
	_b = ((_b & 0x33333333) << 2) | ((_b & 0xCCCCCCCC) >> 2);
	_b = ((_b & 0x0F0F0F0F) << 4) | ((_b & 0xF0F0F0F0) >> 4);
	_b = ((_b & 0x00FF00FF) << 8) | ((_b & 0xFF00FF00) >> 8);
	_dest[@ 0] = _i / _n;
	_dest[@ 1] = _b * 2.3283064365386963 * 0.0000000001;
	return _dest;
}

/// @func SSGI_EncodeFloat16(_real[, _dest])
///
/// @desc
///
/// @param {Real} _real
/// @param {Array<Real>} [_dest]
///
/// @return {Array<Real>}
function SSGI_EncodeFloat16(_real, _dest=[])
{
	_dest[@ 0] = frac(_real);
	_dest[@ 1] = frac(_real * 255.0);
	_dest[@ 0] -= _dest[1] / 255.0;
	return _dest;
}
