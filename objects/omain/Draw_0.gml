var _windowWidth = window_get_width();
var _windowHeight = window_get_height();
var _shader;

////////////////////////////////////////////////////////////////////////////////
// G-buffer
SSGI_SurfaceCheck(application_surface, _windowWidth, _windowHeight);
surDepth = SSGI_SurfaceCheck(surDepth, _windowWidth, _windowHeight);
surNormal = SSGI_SurfaceCheck(surNormal, _windowWidth, _windowHeight);

gpu_push_state();
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);

surface_set_target_ext(0, application_surface);
surface_set_target_ext(1, surDepth);
surface_set_target_ext(2, surNormal);
draw_clear(c_black);

camera_apply(camera);
ssgi.MatrixView = matrix_get(matrix_view);
ssgi.MatrixProjection = matrix_get(matrix_projection);

_shader = ShGBuffer;
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"),
	clipFar);
texture_set_stage(shader_get_sampler_index(_shader, "u_texBestFitNormals"),
	sprite_get_texture(SprBestFitNormals, 0));

model.Submit();
shader_reset();

surface_reset_target();

gpu_pop_state();

////////////////////////////////////////////////////////////////////////////////
// SSGI
surSSGI = SSGI_SurfaceCheck(surSSGI, _windowWidth, _windowHeight);
surWork = SSGI_SurfaceCheck(surWork, _windowWidth / 2, _windowHeight / 2);
surWork2 = SSGI_SurfaceCheck(surWork2, _windowWidth / 4, _windowHeight / 4);
surWork3 = SSGI_SurfaceCheck(surWork3, _windowWidth / 8, _windowHeight / 8);

ssgi.SurLight = application_surface;
ssgi.TextureDepth = surface_get_texture(surDepth);
ssgi.TextureNormals = surface_get_texture(surNormal);
ssgi.SurResult = surSSGI;
ssgi.SurHalf = surWork;
ssgi.SurQuarter = surWork2;
ssgi.SurEighth = surWork3;
ssgi.Render();
