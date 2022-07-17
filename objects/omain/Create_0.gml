debug = false;

clipFar = 32.0;

camera = camera_create();

camera_set_view_mat(camera, matrix_build_lookat(
	3.0, 0.0, 1.0,
	0.0, 0.0, 1.0,
	0.0, 0.0, 1.0));
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(
	-60.0, -16.0 / 9.0, 0.1, clipFar));

model = new CModel()
	.FromOBJ("Data/CornellBox.obj")
	.Freeze();

texture = sprite_add("Data/CornellBox.png", 1, false, false, 0, 0);
model.Texture = sprite_get_texture(texture, 0);

application_surface_enable(true);

surDepth = noone;
surNormal = noone;
surLight = noone;
