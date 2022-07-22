if (!surface_exists(surDepth)
	|| !surface_exists(surNormal))
{
	exit;
}

var _windowWidth = window_get_width();
var _windowHeight = window_get_height();

////////////////////////////////////////////////////////////////////////////////
//
// SSGI
//
surSSGI = SurfaceCheck(surSSGI, _windowWidth, _windowHeight);

surface_set_target(surSSGI);
draw_clear(c_black);

gpu_push_state();

var _shader = SSGI_ShSSRT;
shader_set(_shader);

texture_set_stage(shader_get_sampler_index(_shader, "u_sDepth"), surface_get_texture(surDepth));
texture_set_stage(shader_get_sampler_index(_shader, "u_sNormal"), surface_get_texture(surNormal));

var _uNoise = shader_get_sampler_index(_shader, "u_sNoise");
texture_set_stage(_uNoise, textureNoise);
gpu_set_tex_repeat_ext(_uNoise, true);
gpu_set_tex_filter_ext(_uNoise, false);

shader_set_uniform_f(shader_get_uniform(_shader, "u_vNoiseScale"), _windowWidth / SSGI_KERNEL_SIZE, _windowHeight / SSGI_KERNEL_SIZE);

shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"), clipFar);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTanAspect"), dtan(fov * 0.5) * (_windowWidth / _windowHeight), -dtan(fov * 0.5));
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), 1.0 / _windowWidth, 1.0 / _windowHeight);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fThickness"), 0.2);

shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mView"), matrixView);
shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mProjection"), matrixProjection);

draw_surface(application_surface, 0, 0);
shader_reset();

gpu_pop_state();

surface_reset_target();

////////////////////////////////////////////////////////////////////////////////
// Blur
gpu_push_state();
gpu_set_tex_filter(false);
gpu_set_tex_repeat(false);

surWork = SurfaceCheck(surWork, _windowWidth / 2, _windowHeight / 2);
surWork2 = SurfaceCheck(surWork2, _windowWidth / 4, _windowHeight / 4);
surWork3 = SurfaceCheck(surWork3, _windowWidth / 8, _windowHeight / 8);

surface_set_target(surWork);
shader_set(SSGI_ShDownsample);
shader_set_uniform_f(shader_get_uniform(SSGI_ShDownsample, "u_vTexel"), 1.0 / _windowWidth, 1.0 / _windowHeight);
draw_surface(surSSGI, 0, 0);
shader_reset();
surface_reset_target();

surface_set_target(surWork2);
shader_set(SSGI_ShDownsample);
shader_set_uniform_f(shader_get_uniform(SSGI_ShDownsample, "u_vTexel"), 1.0 / (_windowWidth / 2), 1.0 / (_windowHeight / 2));
draw_surface(surWork, 0, 0);
shader_reset();
surface_reset_target();

surface_set_target(surWork3);
shader_set(SSGI_ShDownsample);
shader_set_uniform_f(shader_get_uniform(SSGI_ShDownsample, "u_vTexel"), 1.0 / (_windowWidth / 4), 1.0 / (_windowHeight / 4));
draw_surface(surWork2, 0, 0);
shader_reset();
surface_reset_target();


gpu_set_tex_filter(true);

var _shader;

_shader = SSGI_ShUpsample8;
surface_set_target(surWork2);
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), 1.0 / (_windowWidth / 8), 1.0 / (_windowHeight / 8));
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"), clipFar);
texture_set_stage(shader_get_sampler_index(_shader, "u_sDepth"), surface_get_texture(surDepth));
texture_set_stage(shader_get_sampler_index(_shader, "u_sNormal"), surface_get_texture(surNormal));
draw_surface_stretched(surWork3, 0, 0, _windowWidth / 4, _windowHeight / 4);
shader_reset();
surface_reset_target();

_shader = SSGI_ShUpsample4;
surface_set_target(surWork);
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), 1.0 / (_windowWidth / 4), 1.0 / (_windowHeight / 4));
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"), clipFar);
texture_set_stage(shader_get_sampler_index(_shader, "u_sDepth"), surface_get_texture(surDepth));
texture_set_stage(shader_get_sampler_index(_shader, "u_sNormal"), surface_get_texture(surNormal));
draw_surface_stretched(surWork2, 0, 0, _windowWidth / 2, _windowHeight / 2);
shader_reset();
surface_reset_target();

_shader = SSGI_ShUpsample2;
surface_set_target(surSSGI);
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), 1.0 / (_windowWidth / 2), 1.0 / (_windowHeight / 2));
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"), clipFar);
texture_set_stage(shader_get_sampler_index(_shader, "u_sDepth"), surface_get_texture(surDepth));
texture_set_stage(shader_get_sampler_index(_shader, "u_sNormal"), surface_get_texture(surNormal));
draw_surface_stretched(surWork, 0, 0, _windowWidth, _windowHeight);
shader_reset();
surface_reset_target();

gpu_pop_state();

//gpu_push_state();
//gpu_set_tex_filter(true);
draw_surface_stretched(surSSGI, 0, 0, _windowWidth, _windowHeight);
//gpu_pop_state();


////////////////////////////////////////////////////////////////////////////////
//
// Debug
//
if (!debug)
{
	exit;
}

var _x = 0;
var _y = 0;
var _width = _windowWidth / 4;
var _height = _windowHeight / 4;

draw_surface_stretched(application_surface, _x, _y, _width, _height);
_x += _width;

draw_surface_stretched(surDepth, _x, _y, _width, _height);
_x += _width;

draw_surface_stretched(surNormal, _x, _y, _width, _height);
_x += _width;
