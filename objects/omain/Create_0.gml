debug = false;

clipFar = 32.0;

camera = camera_create();

fov = 60.0;

matrixView = matrix_build_identity();
matrixProjection = matrix_build_identity();

camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(
	-fov, -16.0 / 9.0, 0.1, clipFar));

model = new CModel()
	.FromOBJ("Data/CornellBox.obj")
	.Freeze();

texture = sprite_add("Data/CornellBox.png", 1, false, false, 0, 0);
model.Texture = sprite_get_texture(texture, 0);

application_surface_enable(true);
application_surface_draw_enable(false);

surDepth = noone;
surNormal = noone;
surLight = noone;
surWork = noone;
surWork2 = noone;
surWork3 = noone;
surSSGI = noone;

textureNoise = SSGI_GetKernelTexture();
