var _windowWidth = window_get_width();
var _windowHeight = window_get_height();
var _aspectRatio = _windowWidth / _windowHeight;
var _shader;

////////////////////////////////////////////////////////////////////////////////
// G-buffer
SSGI_SurfaceCheck(application_surface, _windowWidth, _windowHeight);
surDepth = SSGI_SurfaceCheck(surDepth, _windowWidth, _windowHeight);
surNormal = SSGI_SurfaceCheck(surNormal, _windowWidth, _windowHeight);

gpu_push_state();
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);
gpu_set_texrepeat(true);

surface_set_target_ext(0, application_surface);
surface_set_target_ext(1, surDepth);
surface_set_target_ext(2, surNormal);
draw_clear(c_black);

camera_apply(camera);

var _matrixView = matrix_get(matrix_view);
ssgi.MatrixView = _matrixView;
ssgi.MatrixProjection = matrix_get(matrix_projection);
var _matrixViewInverse = array_create(16);
MatrixInverse(_matrixView, _matrixViewInverse);

_shader = ShGBuffer;
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"),
	clipFar);
texture_set_stage(shader_get_sampler_index(_shader, "u_texBestFitNormals"),
	sprite_get_texture(SprBestFitNormals, 0));

matrix_set(matrix_world, matrix_build(
	0.0, 0.0, 0.0,
	0.0, 0.0, 0.0,
	modelScale, modelScale, modelScale));
model.Submit();
matrix_set(matrix_world, matrix_build_identity());
shader_reset();

surface_reset_target();

gpu_pop_state();

////////////////////////////////////////////////////////////////////////////////
// Deferred lighting
surLight = SSGI_SurfaceCheck(surLight, _windowWidth, _windowHeight);

surface_set_target(surLight);
draw_clear(c_black);

_shader = ShDeferredLighting;
shader_set(_shader);
texture_set_stage(shader_get_sampler_index(_shader, "u_texDepth"),
	surface_get_texture(surDepth));
texture_set_stage(shader_get_sampler_index(_shader, "u_texNormal"),
	surface_get_texture(surNormal));
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"),
	clipFar);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTanAspect"),
	dtan(fov * 0.5) * _aspectRatio, -dtan(fov * 0.5));
shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mViewInverse"),
	_matrixViewInverse);
draw_surface(application_surface, 0, 0);
shader_reset();

surface_reset_target();

////////////////////////////////////////////////////////////////////////////////
// SSGI
surSSGI = SSGI_SurfaceCheck(surSSGI, _windowWidth, _windowHeight);
surWork = SSGI_SurfaceCheck(surWork, _windowWidth / 2, _windowHeight / 2);
surWork2 = SSGI_SurfaceCheck(surWork2, _windowWidth / 4, _windowHeight / 4);
surWork3 = SSGI_SurfaceCheck(surWork3, _windowWidth / 8, _windowHeight / 8);

ssgi.SurLight = surLight;
ssgi.TextureDepth = surface_get_texture(surDepth);
ssgi.TextureNormals = surface_get_texture(surNormal);
ssgi.SurResult = surSSGI;
ssgi.SurHalf = surWork;
ssgi.SurQuarter = surWork2;
ssgi.SurEighth = surWork3;
ssgi.Render();
