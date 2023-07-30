event_inherited();

randomize();
application_surface_enable(true);
application_surface_draw_enable(false);

surShadowmap = -1;
surDepth = -1;
surNormal = -1;
surLight = -1;
surWork = -1;
surWork2 = -1;
surWork3 = -1;
surSSAO = -1;
surSSGI = -1;

ssgi = new SSGI();
ssgi.ClipFar = clipFar;
ssgi.GIDistance = 2.5;
ssgi.GISteps = 12;
ssgi.DepthThickness = 0.8;
ssgi.BlurDepthRange = 1.0;
ssgiEnabled = true;
ssgiMultiplier = 1.0;

ssao = new SSAO();
ssao.Radius = 64.0;
ssao.Power = 2.0;
ssao.ClipFar = clipFar;
ssaoEnabled = true;

ambientColor = [255, 255, 255, 0.2];

sunPosition = [0.0, 0.0, 0.0];
sunDirection = [0.5, 0.0, -1.0];
sunColor = [255, 255, 255, 1.0];

shadowmapResolution = 2048;
shadowmapArea = 64;
shadowmapNormalOffset = 0.03;
shadowmapBias = 0.0;
shadowmapView = matrix_build_identity();
shadowmapProjection = matrix_build_identity();
shadowmapViewProjection = matrix_build_identity();

modelSphere = new CModel()
	.FromOBJ("Data/Sphere.obj")
	.Freeze();

sphere = noone;
sphereDistance = 2.0;

enum EDisplayMode
{
	BaseColor,
	Metallic,
	Normal,
	Roughness,
	Depth,
	Light,
	SSAO,
	SSGI,
	Final,
	SIZE
};

displayModeNames = [
	"BaseColor",
	"Metallic",
	"Normal",
	"Roughness",
	"Depth",
	"Light",
	"SSAO",
	"SSGI",
	"Final",
];

displayMode = EDisplayMode.Final;
