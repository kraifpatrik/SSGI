application_surface_enable(true);
application_surface_draw_enable(false);

debug = false;

camera = camera_create();
clipFar = 512.0;
fov = 60.0;
x = 3.0;
y = 0.0;
z = 1.0;
direction = 180.0;
directionUp = 0.0;
mouseLastX = 0;
mouseLastY = 0;

model = new CModel()
	.FromOBJ("Data/CornellBox.obj")
	.Freeze();

texture = sprite_add("Data/CornellBox.png", 1, false, false, 0, 0);
model.Texture = sprite_get_texture(texture, 0);

surDepth = noone;
surNormal = noone;
surLight = noone;
surWork = noone;
surWork2 = noone;
surWork3 = noone;
surSSGI = noone;

ssgi = new SSGI();
ssgi.Fov = fov;
ssgi.AspectRatio = 16.0 / 9.0;
ssgi.ClipFar = clipFar;
ssgi.GISteps = 32;
ssgi.GIDistance = 3.0;
ssgi.DepthThickness = 0.5;
ssgi.BlurDepthRange = 0.3;
