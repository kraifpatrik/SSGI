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
	.FromOBJ("Data/Sponza/Sponza.obj")
	.Freeze();
modelScale = 0.01;
modelMatrix = matrix_build(
	0.0, 0.0, 0.0,
	0.0, 0.0, 0.0,
	modelScale, modelScale, modelScale);

surShadowmap = noone;
surDepth = noone;
surNormal = noone;
surLight = noone;
surWork = noone;
surWork2 = noone;
surWork3 = noone;
surSSGI = noone;

ssgi = new SSGI();
ssgi.Fov = fov;
ssgi.ClipFar = clipFar;
ssgi.GISteps = 16;
ssgi.GIDistance = 8.0;
ssgi.DepthThickness = 1.0;
ssgi.BlurDepthRange = 0.2;

giMultiplier = 4.0;

sunPosition = [0.0, 0.0, 0.0];
sunDirection = [0.5, 0.0, -1.0];

shadowmapResolution = 2048;
shadowmapArea = 64;
shadowmapNormalOffset = 0.05;
shadowmapBias = 0.0;
shadowmapView = matrix_build_identity();
shadowmapProjection = matrix_build_identity();
shadowmapViewProjection = matrix_build_identity();
