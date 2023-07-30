/// @macro {Real} Size of the SSAO noise texture. Must be the same as in shaders!
/// @private
#macro __SSAO_NOISE_TEXTURE_SIZE 4

/// @macro {Real} The size of SSAO sampling kernel. The higher the better quality,
/// but lower performance. Must be the same as in shaders!
/// @private
#macro __SSAO_KERNEL_SIZE 8

/// @func SSAO()
///
/// @desc
function SSAO() constructor
{
	/// @var {Real} Screen-space radius of the occlusion effect. Default value is
	/// 16.
	Radius = 16.0;

	/// @var {Real} Strength of the occlusion effect. Should be greater than 0.
	/// Default value is 1.
	Power = 1.0;

	/// @var {Real} Angle bias in radians. Default value is 0.03.
	AngleBias = 0.03;

	/// @var {Real} Maximum depth difference of SSAO samples. Default value is 1.
	DepthRange = 1.0;

	/// @var {Real} Maximum depth difference of samples when blurring SSAO.
	/// Default value is 0.2.
	BlurDepthRange = 0.2;

	/// @var {Id.Sprite}
	/// @private
	__SpriteNoise = MakeNoiseSprite(__SSAO_NOISE_TEXTURE_SIZE);

	/// @var {Array<Real>}
	/// @private
	__Kernel = CreateKernel(__SSAO_KERNEL_SIZE);

	/// @var {Id.Surface} The surface to draw the SSAO to.
	SurResult = -1;

	/// @var {Id.Surface} A working surface used for blurring the SSAO.
	SurWork = -1;

	/// @var {Id.Surface} A surface containing scene depth.
	SurDepth = -1;

	/// @var {Array<Real>} The projection matrix used when rendering the scene.
	MatrixProjection = matrix_build_identity();

	/// @var {Real} Distance to the far clipping plane used when rendering the
	/// scene.
	ClipFar = 1.0;

	////////////////////////////////////////////////////////////////////////////
	// Shaders and uniforms
	static __ShaderMain = SSAO_ShMain;
	static __UMainTexNoise = shader_get_sampler_index(__ShaderMain, "u_texNoise");
	static __UMainTexel = shader_get_uniform(__ShaderMain, "u_vTexel");
	static __UMainClipFar = shader_get_uniform(__ShaderMain, "u_fClipFar");
	static __UMainTanAspect = shader_get_uniform(__ShaderMain, "u_vTanAspect");
	static __UMainSampleKernel = shader_get_uniform(__ShaderMain, "u_vSampleKernel");
	static __UMainRadius = shader_get_uniform(__ShaderMain, "u_fRadius");
	static __UMainPower = shader_get_uniform(__ShaderMain, "u_fPower");
	static __UMainNoiseScale = shader_get_uniform(__ShaderMain, "u_vNoiseScale");
	static __UMainAngleBias = shader_get_uniform(__ShaderMain, "u_fAngleBias");
	static __UMainDepthRange = shader_get_uniform(__ShaderMain, "u_fDepthRange");

	static __ShaderBlur = SSAO_ShBlur;
	static __UBlurTexel = shader_get_uniform(__ShaderBlur, "u_vTexel");
	static __UBlurTexDepth = shader_get_sampler_index(__ShaderBlur, "u_texDepth");
	static __UBlurClipFar = shader_get_uniform(__ShaderBlur, "u_fClipFar");
	static __UBlurDepthRange = shader_get_uniform(__ShaderBlur, "u_fDepthRange");

	/// @func MakeNoiseSprite(_size)
	///
	/// @desc Creates a sprite containing a random noise for the SSAO.
	///
	/// @param {Real} _size The size of the sprite.
	///
	/// @return {Asset.GMSprite} The created noise sprite.
	static MakeNoiseSprite = function (_size)
	{
		var _seed = random_get_seed();
		randomize();
		var _sur = surface_create(_size, _size);
		surface_set_target(_sur);
		draw_clear(0);
		var _dir = 0;
		var _dirStep = 180.0 / (_size * _size);
		for (var i = 0; i < _size; ++i)
		{
			for (var j = 0; j < _size; ++j)
			{
				var _col = make_colour_rgb(
					(dcos(_dir) * 0.5 + 0.5) * 255,
					(dsin(_dir) * 0.5 + 0.5) * 255,
					0);
				draw_point_colour(i, j, _col);
				_dir += _dirStep;
			}
		}
		surface_reset_target();
		random_set_seed(_seed);
		var _sprite = sprite_create_from_surface(
			_sur, 0, 0, _size, _size, false, false, 0, 0);
		surface_free(_sur);
		return _sprite;
	};

	/// @func CreateKernel(_size)
	///
	/// @desc Generates a kernel of random vectors to be used for the SSAO.
	///
	/// @param {Real} _size Number of vectors in the kernel.
	///
	/// @return {Array<Real>} The created kernel as
	/// `[v1X, v1Y, v1Z, v2X, v2Y, v2Z, ..., vnX, vnY, vnZ]`.
	static CreateKernel = function (_size)
	{
		var _seed = random_get_seed();
		randomize();
		var _kernel = array_create(_size * 2, 0.0);
		var _dir = 0;
		var _dirStep = 360 / _size;
		for (var i = _size - 1; i >= 0; --i)
		{
			var _len = (i + 1) / _size;
			_kernel[i * 2 + 0] = lengthdir_x(_len, _dir);
			_kernel[i * 2 + 1] = lengthdir_y(_len, _dir);
			_dir += _dirStep;
		}
		random_set_seed(_seed);
		return _kernel;
	};

	/// @func Render()
	///
	/// @desc
	///
	/// @return {Struct.SSAO} Returns `self`.
	static Render = function ()
	{
		var _tanAspect = [1.0 / MatrixProjection[0], -1.0 / MatrixProjection[5]];
		var _width = surface_get_width(SurResult);
		var _height = surface_get_height(SurResult);

		gpu_push_state();
		gpu_set_tex_repeat(false);
		gpu_set_tex_filter(false);

		surface_set_target(SurResult);
		draw_clear(c_white);
		shader_set(__ShaderMain);
		texture_set_stage(__UMainTexNoise, sprite_get_texture(__SpriteNoise, 0));
		gpu_set_texrepeat_ext(__UMainTexNoise, true);
		shader_set_uniform_f(__UMainTexel, 1.0 / _width, 1.0 / _height);
		shader_set_uniform_f(__UMainClipFar, ClipFar);
		shader_set_uniform_f_array(__UMainTanAspect, _tanAspect);
		shader_set_uniform_f_array(__UMainSampleKernel, __Kernel);
		shader_set_uniform_f(__UMainRadius, Radius);
		shader_set_uniform_f(__UMainPower, Power);
		shader_set_uniform_f(__UMainNoiseScale,
			_width / __SSAO_NOISE_TEXTURE_SIZE,
			_height / __SSAO_NOISE_TEXTURE_SIZE);
		shader_set_uniform_f(__UMainAngleBias, AngleBias);
		shader_set_uniform_f(__UMainDepthRange, DepthRange);
		draw_surface_stretched(SurDepth, 0, 0, _width, _height);
		shader_reset();
		surface_reset_target();

		gpu_set_tex_filter(true);

		shader_set(__ShaderBlur);
		shader_set_uniform_f(__UBlurClipFar, ClipFar);
		texture_set_stage(__UBlurTexDepth, surface_get_texture(SurDepth));
		gpu_set_tex_filter_ext(__UBlurTexDepth, false);
		shader_set_uniform_f(__UBlurDepthRange, BlurDepthRange);

		surface_set_target(SurWork);
		draw_clear(c_black);
		shader_set_uniform_f(__UBlurTexel, 1.0 / _width, 0.0);
		draw_surface(SurResult, 0, 0);
		surface_reset_target();

		surface_set_target(SurResult);
		draw_clear(c_black);
		shader_set_uniform_f(__UBlurTexel, 0.0, 1.0 / _height);
		draw_surface(SurWork, 0, 0);
		surface_reset_target();

		shader_reset();

		gpu_pop_state();

		return self;
	};

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function ()
	{
		sprite_delete(__SpriteNoise);
		return undefined;
	};
}
