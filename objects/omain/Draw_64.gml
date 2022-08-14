var _windowWidth = window_get_width();
//var _windowHeight = window_get_height();

switch (displayMode)
{
case EDisplayMode.BaseColor:
	draw_surface(application_surface, 0, 0);
	break;

case EDisplayMode.Depth:
	draw_surface(surDepth, 0, 0);
	break;

case EDisplayMode.Normal:
	draw_surface(surNormal, 0, 0);
	break;

case EDisplayMode.Light:
	draw_surface(surLight, 0, 0);
	break;

case EDisplayMode.SSAO:
	if (ssaoEnabled)
	{
		draw_surface(surSSAO, 0, 0);
	}
	else
	{
		draw_clear(c_black);
	}
	break;

case EDisplayMode.SSGI:
	if (ssgiEnabled)
	{
		draw_surface(surSSGI, 0, 0);
	}
	else
	{
		draw_clear(c_black);
	}
	break;

case EDisplayMode.Final:
	var _shader = ShCombineLighting;
	shader_set(_shader);
	texture_set_stage(shader_get_sampler_index(_shader, "u_texLight"),
		surface_get_texture(surLight));
	texture_set_stage(shader_get_sampler_index(_shader, "u_texSSGI"),
		ssgiEnabled ? surface_get_texture(surSSGI) : sprite_get_texture(SprBlack, 0));
	shader_set_uniform_f(shader_get_uniform(_shader, "u_fMultiplier"),
		ssgiMultiplier);
	texture_set_stage(shader_get_sampler_index(_shader, "u_texSSAO"),
		ssaoEnabled ? surface_get_texture(surSSAO) : sprite_get_texture(SprWhite, 0));
	shader_set_uniform_f(shader_get_uniform(_shader, "u_vAmbientColor"),
		ambientColor[0] / 255.0,
		ambientColor[1] / 255.0,
		ambientColor[2] / 255.0,
		ambientColor[3]);
	draw_surface(application_surface, 0, 0);
	shader_reset();
	break;
}

////////////////////////////////////////////////////////////////////////////////
//
// GUI
//
if (screenshotMode)
{
	exit;
}

var _text = "FPS: " + string(fps) + " (" + string(fps_real) + ")";
draw_text_color(_windowWidth - string_width(_text) - 8, 8, _text,
	c_silver, c_silver, c_silver, c_silver, 1.0);

gui.SetPosition(8, 8)
	.Checkbox(guiShow, {
		Label: "Show UI (F1)",
		OnChange: method(self, function (_value) { guiShow = _value; }),
	})
	.Newline();

if (guiShow)
{
	gui.Slider("camera-fov", fov, {
			Label: "Camera FoV",
			Min: 1,
			Max: 90,
			Round: true,
			OnChange: method(self, function (_value) { fov = _value; }),
		})
		.Newline()
		.Button("<", {
			OnClick: method(self, function () {
				if (--displayMode < 0)
				{
					displayMode = EDisplayMode.SIZE - 1;
				}
			}),
		})
		.Move(7)
		.Input(undefined, displayModeNames[displayMode], {
			Width: 156,
		})
		.Move(7)
		.Button(">", {
			OnClick: method(self, function () {
				if (++displayMode >= EDisplayMode.SIZE)
				{
					displayMode = 0;
				}
			}),
		})
		.Move(8)
		.Text("Display mode")
		.Newline()
		;

	////////////////////////////////////////////////////////////////////////////
	// Lighting
	gui.Text("Lighting:")
		.Newline()
		// Directional
		.Slider("sun-direction-x", sunDirection[0], {
			Width: 62,
			Min: -1.0,
			Max: 1.0,
			OnChange: method(self, function (_value) { sunDirection[@ 0] = _value; }),
		})
		.Move(7)
		.Slider("sun-direction-y", sunDirection[1], {
			Width: 62,
			Min: -1.0,
			Max: 1.0,
			OnChange: method(self, function (_value) { sunDirection[@ 1] = _value; }),
		})
		.Move(7)
		.Slider("sun-direction-z", sunDirection[2], {
			Label: "Sun direction",
			Width: 62,
			Min: -1.0,
			Max: 1.0,
			OnChange: method(self, function (_value) { sunDirection[@ 2] = _value; }),
		})
		.Newline()
		.Slider("sun-color-r", sunColor[0], {
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) { sunColor[@ 0] = _value; }),
		})
		.Move(7)
		.Slider("sun-color-g", sunColor[1], {
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) { sunColor[@ 1] = _value; }),
		})
		.Move(7)
		.Slider("sun-color-b", sunColor[2], {
			Label: "Sun color",
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) { sunColor[@ 2] = _value; }),
		})
		.Newline()
		.Slider("sun-color-a", sunColor[3], {
			Label: "Sun intensity",
			OnChange: method(self, function (_value) { sunColor[@ 3] = _value; }),
		})
		.Newline()
		// Ambient
		.Slider("ambient-color-r", ambientColor[0], {
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) { ambientColor[@ 0] = _value; }),
		})
		.Move(7)
		.Slider("ambient-color-g", ambientColor[1], {
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) { ambientColor[@ 1] = _value; }),
		})
		.Move(7)
		.Slider("ambient-color-b", ambientColor[2], {
			Label: "Ambient color",
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) { ambientColor[@ 2] = _value; }),
		})
		.Newline()
		.Slider("ambient-color-a", ambientColor[3], {
			Label: "Ambient intensity",
			OnChange: method(self, function (_value) { ambientColor[@ 3] = _value; }),
		})
		.Newline()
		;

	////////////////////////////////////////////////////////////////////////////
	// SSGI
	gui.Text("SSGI:")
		.Newline()
		.Checkbox(ssgiEnabled, {
			Label: "Enabled (Space)",
			OnChange: method(self, function (_value) { ssgiEnabled = _value; }),
		})
		.Newline()
		.Checkbox(ssgi.HalfRes, {
			Label: "Half resolution",
			OnChange: method(ssgi, function (_value) { HalfRes = _value; }),
		})
		.Newline()
		.Slider("ssgi-distance", ssgi.GIDistance, {
			Label: "Distance",
			Min: 0.01,
			Max: 16.0,
			OnChange: method(ssgi, function (_value) { GIDistance = _value; }),
		})
		.Newline()
		.Slider("ssgi-steps", ssgi.GISteps, {
			Label: "Steps",
			Min: 1,
			Max: 64,
			Round: true,
			OnChange: method(ssgi, function (_value) { GISteps = _value; }),
		})
		.Newline()
		.Slider("ssgi-depth-thickness", ssgi.DepthThickness, {
			Label: "Depth buffer thickness",
			Min: 0.1,
			Max: 2.0,
			OnChange: method(ssgi, function (_value) { DepthThickness = _value; }),
		})
		.Newline()
		.Slider("ssgi-blur-depth-range", ssgi.BlurDepthRange, {
			Label: "Blur depth range",
			Min: 0.1,
			Max: 2.0,
			OnChange: method(ssgi, function (_value) { BlurDepthRange = _value; }),
		})
		.Newline()
		.Slider("gi-multiplier", ssgiMultiplier, {
			Label: "Multiplier",
			Min: 0.0,
			Max: 5.0,
			OnChange: method(self, function (_value) { ssgiMultiplier = _value; }),
		})
		.Newline()
		;

	////////////////////////////////////////////////////////////////////////////
	// SSAO
	gui.Text("SSAO:")
		.Newline()
		.Checkbox(ssaoEnabled, {
			Label: "Enabled",
			OnChange: method(self, function (_value) { ssaoEnabled = _value; }),
		})
		.Newline()
		.Slider("ssao-radius", ssao.Radius, {
			Label: "Radius",
			Min: 1,
			Max: 128,
			Round: true,
			OnChange: method(ssao, function (_value) { Radius = _value; }),
		})
		.Newline()
		.Slider("ssao-power", ssao.Power, {
			Label: "Power",
			Min: 0.1,
			Max: 10.0,
			OnChange: method(ssao, function (_value) { Power = _value; }),
		})
		.Newline()
		.Slider("ssao-angle-bias", ssao.AngleBias, {
			Label: "Angle bias",
			OnChange: method(ssao, function (_value) { AngleBias = _value; }),
		})
		.Newline()
		.Slider("ssao-depth-range", ssao.DepthRange, {
			Label: "Depth range",
			Min: 0.01,
			Max: 10.0,
			OnChange: method(ssao, function (_value) { DepthRange = _value; }),
		})
		.Newline()
		.Slider("ssao-blur-depth-range", ssao.BlurDepthRange, {
			Label: "Blur depth range",
			Min: 0.01,
			Max: 1.0,
			OnChange: method(ssao, function (_value) { BlurDepthRange = _value; }),
		})
		.Newline()
		;

	////////////////////////////////////////////////////////////////////////////
	// Emissive spheres
	var _sphereExists = instance_exists(sphere);

	gui.Text("Emissive spheres:")
		.Newline()
		.Slider("sphere-color-r", _sphereExists ? sphere.color[0] : 0.0, {
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) {
				if (instance_exists(sphere))
				{
					sphere.color[@ 0] = _value;
				}
			}),
		})
		.Move(7)
		.Slider("sphere-color-g", _sphereExists ? sphere.color[1] : 0.0, {
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) {
				if (instance_exists(sphere))
				{
					sphere.color[@ 1] = _value;
				}
			}),
		})
		.Move(7)
		.Slider("sphere-color-b", _sphereExists ? sphere.color[2] : 0.0, {
			Label: "Color",
			Width: 62,
			Min: 0,
			Max: 255,
			Round: true,
			OnChange: method(self, function (_value) {
				if (instance_exists(sphere))
				{
					sphere.color[@ 2] = _value;
				}
			}),
		})
		.Newline()
		.Slider("sphere-color-a", _sphereExists ? sphere.color[3] : 0.0, {
			Label: "Intensity",
			OnChange: method(self, function (_value) {
				if (instance_exists(sphere))
				{
					sphere.color[@ 3] = _value;
				}
			}),
		})
		.Newline()
		.Slider("sphere-distance", sphereDistance, {
			Label: "Distance",
			Min: 1.0,
			Max: 20.0,
			OnChange: method(self, function (_value) { sphereDistance = _value; }),
		})
		.Newline()
		.Button("Spawn", {
			Width: 100,
			OnClick: method(self, function () {
				sphere = instance_create_layer(0, 0, layer, OSphere);
			}),
		})
		.Newline()
		.Button("Place", {
			Width: 100,
			OnClick: method(self, function () {
				sphere = noone;
			}),
		})
		.Newline()
		.Button("Destroy", {
			Width: 100,
			OnClick: method(self, function () {
				if (instance_exists(sphere))
				{
					instance_destroy(sphere);
					sphere = noone;
				}
				else
				{
					with (OSphere)
					{
						instance_destroy();
						break;
					}
				}
			}),
		})
		.Newline()
		.Button("Destroy all", {
			Width: 100,
			OnClick: method(self, function () {
				instance_destroy(OSphere);
				sphere = noone;
			}),
		})
		.Newline()
		;
}
