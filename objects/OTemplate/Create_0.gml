draw_set_font(FntOpenSans10);

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

gui = new CGUI();
guiShow = false;
screenshotMode = false;

model = new CModel()
	.FromOBJ("Data/Sponza/Sponza.obj")
	.Freeze();
modelScale = 0.01;
modelMatrix = matrix_build(
	0.0, 0.0, 0.0,
	0.0, 0.0, 0.0,
	modelScale, modelScale, modelScale);
